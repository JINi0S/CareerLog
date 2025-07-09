//
//  CoverLetterInsertRequest.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/4/25.
//


import Foundation

struct CoverLetterInsertRequest: Encodable {
    let company: String
    let title: String
    let job_position: String
}
