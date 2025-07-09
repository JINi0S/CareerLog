//
//  CoverLetterState.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/7/25.
//


import UIKit

enum CoverLetterState: String, CaseIterable {
    case unwrite
    case draft
    case submitted
    case passed
    case failed
    
    var koreanName: String {
        switch self {
        case .unwrite: "미작성"
        case .draft: "작성 중"
        case .submitted: "제출 완료"
        case .passed: "서류 합격"
        case .failed: "서류 불합격"
        }
    }
    
    var imageName: String {
        switch self {
        case .unwrite: return "doc"
        case .draft: return "pencil"
        case .submitted: return "doc.on.doc.fill" // paperplane.fill
        case .passed: return "checkmark.seal.fill"
        case .failed: return "xmark.seal.fill"
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .unwrite: return .systemGray
        case .draft: return .systemOrange
        case .submitted: return .systemBlue
        case .passed: return .systemGreen
        case .failed: return .systemRed
        }
    }
}