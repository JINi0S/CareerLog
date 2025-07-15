//
//  MockCoverLetterFactory.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/11/25.
//

struct MockCoverLetterFactory {
    static func makeMockData() -> [CoverLetter] {
        return [
            CoverLetter(
                id: -1,
                company: "ABC 회사",
                title: "개발자 자기소개서",
                contents: [.init(id: 02, coverLetterId: -1, question: "지원동기를 작성해주세요", tag: [], answers: ["ABC 회사에 관심을 가지게 된 계기는..."], createdAt: .now)],
                state: .draft,
                isBookmarked: false,
                dueDate: nil,
                jobPosition: "iOS Developer",
                memo: "",
                createdAt: .now,
                updatedAt: .now
            )
        ]
    }
}
