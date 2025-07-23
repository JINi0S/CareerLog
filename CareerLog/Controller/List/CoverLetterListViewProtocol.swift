//
//  CoverLetterListViewProtocol.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/15/25.
//


protocol CoverLetterListViewProtocol: AnyObject {
    func showCoverLetters(_ items: [CoverLetter], selectedId: Int?, selectionSource: SelectionSource)
    func updateLoginUI(isLoggedIn: Bool)
    func updateFilteringBookmarkButton(isFiltering: Bool)
    func reloadRow(withId id: Int)
    func showLoginModal(reason: String?)
    func showError(message: String)
}
