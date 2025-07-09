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
}
