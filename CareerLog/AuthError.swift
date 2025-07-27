//
//  AuthError.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/27/25.
//

import Foundation

enum CLAuthError: Error, LocalizedError {
    case invalidCredential
    case invalidURL
    case failedLogin
    case revokeTokenFailed
    case noProviderToken
    case networkError
    case serverError(Int)
    case unsupportedProvider
    case withdrawalFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidCredential:
            return "잘못된 인증 정보입니다."
        case .invalidURL:
            return "잘못된 URL입니다."
        case .failedLogin:
            return "재로그인에 실패했습니다."
        case .revokeTokenFailed:
            return "토큰 해제에 실패했습니다."
        case .noProviderToken:
            return "제공자 토큰을 찾을 수 없습니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다."
        case .serverError(let code):
            return "서버 오류가 발생했습니다. (코드: \(code))"
        case .unsupportedProvider:
            return "지원하지 않는 로그인 방식입니다."
        case .withdrawalFailed(let message):
            return "회원탈퇴에 실패했습니다: \(message)"
        }
    }
}
