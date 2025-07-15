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
    var isLoggedIn: Bool {
        return client.auth.currentUser != nil
    }
    private weak var presentingViewController: UIViewController?

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
            break // TODO
        }
    }
    
    private func handleAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email] // TODO: 범위 확정
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func handleGoogleLogin() {
        // 여기에 Google Sign-In 로직 구현
        // completion?(...) 호출 필수
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
}

// MARK: - Apple Login Delegate

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            completion?(.failure(AuthError.invalidCredential))
            return
        }
        
        Task {
            do {
                _ = try await client.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: tokenString)
                )
                completion?(.success(()))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Apple 로그인 실패: \(error.localizedDescription)")
        completion?(.failure(error))
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presentingViewController?.view.window ?? ASPresentationAnchor()
    }
}

enum AuthError: Error {
    case invalidCredential
}
