//
//  SelfIntroduce.swift
//  CareerLog
//
//  Created by Lee Jinhee on 5/29/25.
//

import UIKit

// 각 CoverLetter는 하나의 회사에 대한 자기소개서이며,
// CoverLetterSection에는 여러 질문(CoverLetterContent)이 있고,
// 각 질문에는 복수의 답변이 담겨 있어요.
class CoverLetter {
    let id: Int
    var company: Company
    var title: String
    var contents: [CoverLetterContent]
    var state: CoverLetterState
    var isBookmarked: Bool
    var dueDate: Date?
    var jobPosition: String?
    var memo: String?
    var createdAt: Date
    var updatedAt: Date
    var includesWhitespace: Bool
        
    init(
        id: Int,
        company: Company,
        title: String,
        contents: [CoverLetterContent],
        state: CoverLetterState,
        isBookmarked: Bool = false,
        dueDate: Date? = nil,
        jobPosition: String,
        memo: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        includesWhitespace: Bool = false
    ) {
        self.id = id
        self.company = company
        self.title = title
        self.contents = contents
        self.state = state
        self.isBookmarked = isBookmarked
        self.dueDate = dueDate
        self.jobPosition = jobPosition
        self.memo = memo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.includesWhitespace = includesWhitespace
    }
}

struct CoverLetterContent {
    let id: Int
    var question: String
    var tag: String?
    var answers: [String]
    var characterLimit: Int
}

struct Company {
    let id: Int
    var name: String
}

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

// MARK: - mockdata

extension Company {
    static let naver = Company(id: 1, name: "NAVER")
    static let kakao = Company(id: 2, name: "Kakao")
    static let toss = Company(id: 3, name: "Toss")
}

extension CoverLetterContent {
    // 질문 + 답변 데이터
    static let naverContents = [
        CoverLetterContent(
            id: 1,
            question: "NAVER에 지원한 동기는 무엇인가요?",
            tag: "지원동기",
            answers: [
                "NAVER의 기술 중심 문화와 개발자 성장 환경이 저의 성장 방향과 일치한다고 생각했습니다.",
                "AI와 클라우드 등 미래 기술에 적극 투자하는 모습에서 함께 성장할 수 있겠다는 확신이 들었습니다."
            ],
            characterLimit: 1000
        ),
        CoverLetterContent(
            id: 2,
            question: "본인의 역량을 설명해주세요.",
            answers: [
                "SwiftUI 기반의 iOS 앱 개발 프로젝트 경험이 있으며, 팀 내 코드 리뷰 문화를 주도한 경험이 있습니다.",
                "Create ML을 활용한 사용자 맞춤형 기능 구현 경험이 있어 데이터를 활용한 서비스 개선에도 기여할 수 있습니다."
            ],
            characterLimit: 1000
        )
    ]
    
    static let kakaoContents = [
        CoverLetterContent(
            id: 3,
            question: "협업 경험 중 어려움을 극복한 사례를 소개해주세요.",
            tag: "어려움극복",
            answers: [
                "백엔드 API 오류로 인해 iOS 기능 개발에 어려움을 겪었지만, 백엔드와 지속적으로 소통하며 API 명세를 재정비하여 문제를 해결했습니다.",
                "PR 리뷰 과정에서 기능 누락이 반복되는 문제를 팀 내 커뮤니케이션 프로세스 개선으로 해결했습니다."
            ],
            characterLimit: 1000
        )
    ]
    
    static let tossContents = [
        CoverLetterContent(
            id: 4,
            question: "본인의 성장 경험을 알려주세요.",
            answers: [
                "Apple Developer Academy에서 다양한 직군과 협업하며 실전 프로젝트를 주도적으로 진행했습니다.",
                "반복적인 실패 속에서도 피드백을 통해 성과를 만들어낸 경험이 제 성장의 밑거름이 되었습니다."
            ],
            characterLimit: 1000
        )
    ]
}

extension CoverLetter {
    // 자기소개서 인스턴스
    static let coverLetter1 = CoverLetter(id: 1, company: Company.naver, title: "네이버 백엔드 자기소개서", contents: CoverLetterContent.naverContents, state: .draft, isBookmarked: true, dueDate: .now, jobPosition: "iOS 개발자")
    static let coverLetter2 = CoverLetter(id: 2, company: Company.kakao, title: "카카오 iOS 자기소개서", contents: CoverLetterContent.kakaoContents, state: .submitted, dueDate: .now, jobPosition: "iOS 개발자")
    static let coverLetter3 = CoverLetter(id: 3, company: Company.toss, title: "토스 신입 개발자 자기소개서", contents: CoverLetterContent.tossContents, state: .unwrite, dueDate: .now, jobPosition: "iOS 개발자")
    static let coverLetter4 = CoverLetter(id: 4, company: Company.toss, title: "코오롱 신입 개발자 자기소개서", contents: CoverLetterContent.tossContents, state: .passed, dueDate: .now, jobPosition: "iOS 개발자")
    static let coverLetter5 = CoverLetter(id: 5, company: Company.toss, title: "쿠팡 신입 개발자 자기소개서", contents: CoverLetterContent.tossContents, state: .failed, dueDate: .now, jobPosition: "iOS 개발자")
    
    static let mockCoverLetters = [coverLetter1, coverLetter2, coverLetter3, coverLetter4, coverLetter5]
}
