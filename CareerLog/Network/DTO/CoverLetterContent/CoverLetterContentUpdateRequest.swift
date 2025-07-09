//
//  CoverLetterContentUpdateRequest.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/4/25.
//


import UIKit

struct CoverLetterContentUpdateRequest: Encodable {
    var id: Int
    var cover_letter_id: Int
    var question: String
    var answer: [String]
    var character_limit: Int?
}
