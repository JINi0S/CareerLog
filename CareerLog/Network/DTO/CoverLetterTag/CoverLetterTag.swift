//
//  CoverLetterContentTag.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/9/25.
//

import Foundation

// 태그 추가
// 태그 조회
// 태그 수정
// 태그 삭제 -> 릴레이션 테이블 삭제
// 콘텐츠에 태그 추가 -> 릴레이션 테이블에서 row 추가
// 콘텐츠에 태그 수정 -> 릴레이션 테이블에서 기존 row 삭제 & 새로운 row 추가
// 콘텐츠에서 태그 삭제 -> 릴레이션 테이블에서 row 삭제

// 확인할 것
// 삭제 시 연결된 부분 잘 삭제되는지


// TODO: 파일 분리
struct CoverLetterTag: Identifiable, Hashable, Decodable {
    let id: Int
    var name: String
    let createdAt: Date
    let updatedAt: Date
}

struct CoverLetterTagResponse: Codable {
    let id: Int
    let name: String
    let created_at: Date
    let updated_at: Date
}

extension CoverLetterTagResponse {
    func toDomain() -> CoverLetterTag {
        return CoverLetterTag(
            id: id,
            name: name,
            createdAt: created_at,
            updatedAt: updated_at
        )
    }
}

struct CoverLetterTagInsertRequest: Codable {
    let name: String
}

struct CoverLetterTagRelationInsertRequest: Codable {
    let cover_letter_content_id: Int
    let tag_id: Int
}
