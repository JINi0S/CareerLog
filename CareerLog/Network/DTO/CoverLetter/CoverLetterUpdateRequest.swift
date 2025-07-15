//
//  CoverLetterUpdateRequest.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/4/25.
//


import UIKit

struct CoverLetterUpdateRequest: Encodable {
    let id: Int
    let company: String
    let title: String
    let state: String
    let is_bookmarked: Bool
    let due_date: Date?
    let job_position: String?
    let memo: String?
    let updated_at: Date
    let includes_whitespace: Bool
}

extension CoverLetterUpdateRequest {
    init(from coverLetter: CoverLetter) {
        self.init(
            id: coverLetter.id,
            company: coverLetter.company,
            title: coverLetter.title,
            state: coverLetter.state.rawValue,
            is_bookmarked: coverLetter.isBookmarked,
            due_date: coverLetter.dueDate,
            job_position: coverLetter.jobPosition,
            memo: coverLetter.memo,
            updated_at: coverLetter.updatedAt,
            includes_whitespace: coverLetter.includesWhitespace
        )
    }
}
