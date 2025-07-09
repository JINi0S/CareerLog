//
//  CoverLetterContentResponse.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/7/25.
//


import UIKit

struct CoverLetterContentResponse: Decodable {
    let id: Int
    let coverLetterId: Int
    var question: String
    var answers: [String]
    var characterLimit: Int?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case coverLetterId = "cover_letter_id"
        case question
        case answers = "answer"
        case characterLimit = "character_limit"
        case createdAt = "created_at"
    }
    
    func toDomain() -> CoverLetterContent {
        return CoverLetterContent(
            id: id,
            coverLetterId: coverLetterId,
            question: question,
            tag: [],
            answers: answers,
            characterLimit: characterLimit,
            createdAt: createdAt
        )
    }
}
