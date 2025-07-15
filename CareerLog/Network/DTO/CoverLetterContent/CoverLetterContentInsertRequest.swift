//
//  CoverLetterContentInsertRequest.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/4/25.
//


import UIKit

struct CoverLetterContentInsertRequest: Encodable {
    var cover_letter_id: Int
    var question: String
    var tag: String?
    var answer: [String]
    var character_limit: Int?
    
    static func makeManageGuideRequests(coverLetterId: Int) -> [CoverLetterContentInsertRequest] {
        [
            CoverLetterContentInsertRequest(
                cover_letter_id: coverLetterId,
                question: "✦  자기소개서를 삭제하려면 어떻게 하나요?",
                answer: [
                    "화면 왼쪽의 자기소개서 목록에서 삭제할 항목을 우클릭해보세요!",
                    "나타나는 메뉴에서 삭제를 선택하면 자기소개서 항목과 답변들이 전부 삭제돼요 ₊⋆ ☾"
                ]
            ),
            CoverLetterContentInsertRequest(
                cover_letter_id: coverLetterId,
                question: "✦  자기소개서 제목을 바꾸고 싶어요!",
                answer: [
                    "상단의 자기소개서 제목 영역을 클릭하면 제목을 자유롭게 수정할 수 있어요 ✦",
                    "더욱 적절한 제목으로 바꿔보는 건 어떨까요? ᯓ♡"
                ]
            ),
            CoverLetterContentInsertRequest(
                cover_letter_id: coverLetterId,
                question: "✦  자기소개서와 관련된 정보는 어디에 기록하나요?",
                answer: [
                    "오른쪽 패널에 회사 정보나 직무 정보, 메모를 자유롭게 기록할 수 있어요 ɞ",
                    "지원 마감일, 포지션, 준비하고 싶은 내용들을 적어두면 나중에 찾아보기 편하답니다 ☁︎"
                ]
            )
        ]
    }
    
    static func makeQnAGuideRequests(coverLetterId: Int) -> [CoverLetterContentInsertRequest] {
        [
            CoverLetterContentInsertRequest(
                cover_letter_id: coverLetterId,
                question: "✦  답변은 하나만 작성할 수 있나요?",
                answer: [
                    "아니요!\n문항 하단의 ‘답변 추가’ 버튼을 누르면 여러 개의 답변을 자유롭게 작성할 수 있어요 ₊⋆⟡"
                ]
            ),
            CoverLetterContentInsertRequest(
                cover_letter_id: coverLetterId,
                question: "✦  문항을 삭제하려면 어떻게 하나요?",
                answer: [
                    "문항 우측의 ··· 버튼을 눌러 삭제할 수 있어요 ₊⋆✦"
                ]
            ),
            CoverLetterContentInsertRequest(
                cover_letter_id: coverLetterId,
                question: "✦  새로운 문항을 추가하고 싶어요!",
                answer: [
                    "화면 우측 상단의 + 버튼을 눌러 새 문항을 추가할 수 있어요. 원하는 만큼 자유롭게 작성해보세요 ᯓ★"
                ]
            ),
            CoverLetterContentInsertRequest(
                cover_letter_id: coverLetterId,
                question: "✦  답변의 순서를 바꾸고 싶어요!",
                answer: [
                    "답변 항목을 꾹 누른 뒤 위아래로 드래그해보세요 ᯓ★\n원하는 순서대로 자유롭게 정렬할 수 있어요 ₊⋆ ☾"
                ]
            ),
            CoverLetterContentInsertRequest(
                cover_letter_id: coverLetterId,
                question: "✦  자기소개서 내용은 저장되나요?",
                answer: [
                    "작성한 내용은 일정 시간 후 자동으로 저장돼요 ₊⋆⟡",
                    "앱을 종료해도 작성 중이던 내용은 그대로 남아 있어요 ♡ミ"
                ]
            )
        ]
    }
}
