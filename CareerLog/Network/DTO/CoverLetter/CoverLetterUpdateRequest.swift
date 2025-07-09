//
//  CoverLetterUpdateRequest.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/4/25.
//


import UIKit

struct CoverLetterUpdateRequest: Encodable {
    let id: Int
    var company: String
    var title: String
    var state: String
    var is_bookmarked: Bool
    var due_date: Date?
    var job_position: String?
    var memo: String?
    var updated_at: Date
    var includes_whitespace: Bool
}
