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
    
    func signIn(with provider: AuthProvider, completion: @escaping (Result<Void, Error>) -> Void) {
        self.completion = completion
        
        switch provider {
        case .apple:
            handleAppleLogin()
        case .google:
            handleGoogleLogin() // TOOO: 추후 구현
        }
    }
    
    private func handleAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email] // TODO: 범위 확정
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        DispatchQueue.global(qos: .background).async {
            controller.performRequests()
        }
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
        completion?(.failure(error))
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("⚠️ No active window found for Apple Sign-In presentation.")
        }
        return window
    }
}

enum AuthError: Error {
    case invalidCredential
}
