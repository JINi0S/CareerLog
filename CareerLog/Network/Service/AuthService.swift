//
//  AuthService.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/2/25.
//

import AuthenticationServices
import Supabase

// 확장 가능하도록 설정
enum AuthProvider {
    case apple
    case google
}

final class AuthService: NSObject {
    static let shared = AuthService()
    private let client = SupabaseClientProvider.shared
    private var completion: ((Result<Void, Error>) -> Void)?
    private var appleTokenDelegate: AppleTokenDelegate?
    var isLoggedIn: Bool {
        return client.auth.currentUser != nil
    }
    private weak var presentingViewController: UIViewController?

    // MARK: - Public Methods

    func signIn(
        with provider: AuthProvider,
        from viewController: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.completion = completion
        self.presentingViewController = viewController

        switch provider {
        case .apple:
            handleAppleLogin()
        case .google:
            break // TODO: 구글 로그인 구현
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await client.auth.signOut()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: 회원탈퇴
    /// 1. 재로그인으로 토큰 얻기
    /// 2. 소셜 서비스에서 unlink / revoke 수행
    /// 3. supabase에서 사용자 삭제
    func deleteUserInSupabase() async -> Result<Void, Error> {
        do {
            // 1) 현재 세션을 가져와서, 어떤 provider(apple, google, ..)인지 판별
            let session = try await client.auth.session
            guard let rawProvider = session.user.appMetadata["provider"]?.rawValue,
                  let socialProvider = Provider(rawValue: rawProvider) else {
                return .failure(CLAuthError.unsupportedProvider)
            }
            
            // 2) provider에 따라 호출할 함수 결정
            let performUnlinkOrRevoke: (String) async throws -> Void
            switch socialProvider {
            case .apple:
                performUnlinkOrRevoke = revokeAppleAccessToken(_:)
            default:
                return .failure(CLAuthError.unsupportedProvider)
            }
            
            // 3) 현재 세션의 providerToken 확인 또는 재로그인
            let providerToken: String
            if let existingToken = session.providerToken {
                providerToken = existingToken
            } else {
                providerToken = try await performNewAppleLogin()
            }
            
            // 4) providerToken을 이용해 unlink 또는 revoke 호출
            try await performUnlinkOrRevoke(providerToken)
            
            // 5) Supabase 측 사용자 삭제 Edge Function 호출
            try await client
                .rpc("delete_user")
                .execute()
            
            try await client.auth.signOut()
            return .success(())
        } catch {
            print("회원탈퇴 프로세스 실패:", error.localizedDescription)
            return .failure(error)
        }
    }
    
    // MARK: - Apple 로그인
    
    private func handleAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email] // TODO: 범위 확정
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func performNewAppleLogin() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                self.appleTokenDelegate = AppleTokenDelegate { [weak self] result in
                    continuation.resume(with: result)
                    self?.appleTokenDelegate = nil
                }
                
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName, .email]
                
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self.appleTokenDelegate
                controller.presentationContextProvider = self
                controller.performRequests()
            }
        }
    }
    
    private func revokeAppleAccessToken(_ token: String) async throws {
        guard let url = URL(string: "https://appleid.apple.com/auth/revoke") else {
            throw CLAuthError.invalidURL
        }
        let clientID = "com.leejinhee.CareerLog" // 서비스 아이디
        let clientSecret = try await requestSecret() // Edge Functions으로 가져오기
        
        let params: [String: String] = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "token": token,
            "token_type_hint": "access_token"
        ]
        
        try await sendAppleTokenRevokeRequest(url: url, params: params)
    }
    
    private func sendAppleTokenRevokeRequest(url: URL, params: [String: String]) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = params
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("애플 토큰 리보크 실패: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200..<300).contains(httpResponse.statusCode) {
                    print("애플 토큰 리보크 성공. 상태 코드: \(httpResponse.statusCode)")
                } else {
                    print("애플 토큰 리보크 실패. 상태 코드: \(httpResponse.statusCode)")
                }
            }
        }

        task.resume()
    }
    
    private func requestSecret() async throws -> String {
        let functionName = "client-secret"  // 호출할 Edge Function 이름
        
        guard let token = KeychainHelper.load(forKey: "access_token") else {
            throw CLAuthError.invalidCredential
        }

        let response: SecretResponse = try await client.functions.invoke(
            functionName,
            options: FunctionInvokeOptions(
                method: .get,
                headers: ["authorization": "\(token)"]
            )
        )
        return response.client_secret
    }
   
    private func handleGoogleLogin() {
        // 여기에 Google Sign-In 로직 구현
        // completion?(...) 호출 필수
    }
}

// MARK: - Apple Login Delegate

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            completion?(.failure(CLAuthError.invalidCredential))
            return
        }
        
        Task {
            do {
                let session = try await client.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: tokenString)
                )
                // 액세스 토큰 저장
                let accessToken = session.accessToken
                KeychainHelper.save(accessToken, forKey: "access_token")
                completion?(.success(()))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple 로그인 실패: \(error.localizedDescription)")
        completion?(.failure(error))
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presentingViewController?.view.window ?? ASPresentationAnchor()
    }
}


// MARK: - AppleTokenDelegate

@MainActor
class AppleTokenDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let completion: (Result<String, Error>) -> Void
    
    init(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            completion(.failure(CLAuthError.invalidCredential))
            return
        }
        
        completion(.success(tokenString)) // Identity Token 반환
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}

// MARK: - SecretResponse

struct SecretResponse: Codable {
    let client_secret: String
}
