//
//  SidebarFilter.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/7/25.
//


import UIKit

enum SidebarFilter: Hashable {
    case all
    case state(CoverLetterState)
    
    var title: String {
        switch self {
        case .all:
            return "전체 보기"
        case .state(let state):
            return state.koreanName
        }
    }
    
    func contains(_ letter: CoverLetter) -> Bool {
        switch self {
        case .all:
            return true
        case .state(let state):
            return letter.state == state
        }
    }
}