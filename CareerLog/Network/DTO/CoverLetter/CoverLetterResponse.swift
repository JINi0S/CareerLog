//
//  CoverLetterResponse.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/7/25.
//


import UIKit

struct CoverLetterResponse: Decodable {
    let id: Int
    var company: String?
    var title: String
    var state: String
    var isBookmarked: Bool
    var dueDate: Date?
    var jobPosition: String?
    var memo: String?
    var createdAt: Date
    var updatedAt: Date
    var includesWhitespace: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case company
        case title
        case state
        case isBookmarked = "is_bookmarked"
        case dueDate = "due_date"
        case jobPosition = "job_position"
        case memo
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case includesWhitespace = "includes_whitespace"
    }
    
    func toDomain() -> CoverLetter {
        return CoverLetter(
            id: id,
            company: company ?? "",
            title: title,
            contents: [],
            state: CoverLetterState(rawValue: state) ?? .unwrite,
            isBookmarked: isBookmarked,
            dueDate: dueDate,
            jobPosition: jobPosition ?? "",
            memo: memo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            includesWhitespace: includesWhitespace
        )
    }
}
