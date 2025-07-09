//
//  SupabaseError.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/9/25.
//


import Foundation

enum SupabaseError: LocalizedError {
    case insertFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .insertFailed(let table):
            return "🚫 \(table)에 insert 실패했습니다."
        }
    }
}
