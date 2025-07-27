//
//  CoverLetterListPresenter.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/15/25.
//

import Foundation

// TODO: 업데이트 동작 되고 있는지 최종 확인 필요
protocol CoverLetterListPresenterProtocol {
    func viewDidLoad()
    func didTapAddButton()
    func didTapLoginButton()
    func didTapLogoutButton()
    func didTapWithdrawButton()
    func didToggleBookmark(for item: CoverLetter)
    func didDeleteCoverLetter(_ item: CoverLetter)
    func didSelectFilter(_ filter: SidebarFilter)
    func updateSearchText(_ text: String)
    func didUpdateCoverLetter(_ item: CoverLetter)
}

final class CoverLetterListPresenter: CoverLetterListPresenterProtocol {
    weak var view: CoverLetterListViewProtocol?
    private let service: CoverLetterServiceProtocol
    
    // 상태 관리
    private var isFilteringBookmark: Bool = false
    private var searchText: String = ""
    var selectedFilter: SidebarFilter = .all
    private(set) var selectedTags: Set<String> = []
    private var selectedId: Int?
    private(set) var allItems: [CoverLetter] = []
    private(set) var allTags: [CoverLetterTag] = []
    
    init(view: CoverLetterListViewProtocol, service: CoverLetterServiceProtocol) {
        self.view = view
        self.service = service
    }
    
    // MARK: - View Life Cycle
    func viewDidLoad() {
        updateLoginUI()
        
        if AuthService.shared.isLoggedIn {
            Task { await fetchCoverLetters() }
        } else {
            loadMockCoverLetters()
        }
    }
    
    // MARK: - User Actions
    func didTapAddButton() {
        guard AuthService.shared.isLoggedIn else {
            view?.showLoginModal(reason: "새로운 자기소개서를 작성하려면 로그인이 필요해요.")
            return
        }
        Task { await insertNewCoverLetter() }
    }
    
    func didTapLoginButton() {
        guard AuthService.shared.isLoggedIn else {
            view?.showLoginModal(reason: nil)
            return
        }
    }
    
    func didTapLogoutButton() {
        AuthService.shared.signOut { [weak self] result in
            switch result {
            case .success:
                self?.viewDidLoad()
                self?.view?.showLoginModal(reason: nil)
            case .failure(let error):
                self?.view?.showError(message: "로그아웃 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func didTapWithdrawButton() {
        Task {
            let result = await AuthService.shared.deleteUserInSupabase()
            
            await MainActor.run {
                switch result {
                case .success:
                    // 회원탈퇴 성공 - 로그인 화면으로 이동
                    viewDidLoad()
                    view?.showLoginModal(reason: "회원탈퇴가 완료되었습니다.")
                case .failure(let error):
                    // 회원탈퇴 실패 - 에러 메시지 표시
                    view?.showError(message: "회원탈퇴 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func didTapFilteringBookmarkButton() {
        isFilteringBookmark.toggle()
        view?.updateFilteringBookmarkButton(isFiltering: isFilteringBookmark)
        updateFilteredList(selectionSource: .userInitiated)
    }
    
    func didTapFilteringTagButton() {
        let tagNames = allTags.map { $0.name }
        let selectedTagNames = selectedTags
        print(allTags, tagNames, selectedTagNames)

        view?.showTagFilter(tags: tagNames, selected: selectedTagNames)
    }
    
    func didToggleBookmark(for item: CoverLetter) {
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        allItems[index].isBookmarked.toggle() // 상태 업데이트
        let updatedItem = allItems[index]
        
        view?.reloadRow(withId: item.id) // UI 즉시 반영
        
        // 서버 동기화
        Task {
            do {
                try await saveCoverLetter(updatedItem)
            } catch {
                // 실패 시 롤백
                print("자기소개서 북마크 업데이트 실패:", error.localizedDescription)
                allItems[index].isBookmarked.toggle() // 상태 업데이트
                view?.showError(message: "북마크를 저장하지 못했어요.")
                view?.reloadRow(withId: item.id)
                
            }
        }
    }
    
    func didDeleteCoverLetter(_ item: CoverLetter) {
        guard AuthService.shared.isLoggedIn else {
            view?.showError(message: "로그인이 필요합니다.")
            return
        }
        
        Task {
            do {
                try await service.deleteCoverLetter(coverLetterId: item.id)
                print("자기소개서 삭제 성공")
                
                if let index = allItems.firstIndex(where: { $0.id == item.id }) {
                    allItems.remove(at: index)
                }
                
                if selectedId == item.id {
                    selectedId = nil
                }
                
                updateFilteredList(selectionSource: .systemAuto)
            } catch {
                view?.showError(message: "삭제 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func updateSearchText(_ text: String) {
        self.searchText = text
        updateFilteredList(selectionSource: .none)
    }
    
    func didSelectFilter(_ filter: SidebarFilter) {
        self.selectedFilter = filter
        updateFilteredList(selectionSource: .userInitiated)
    }
       
    func didSelectTags(_ tags: [String]) {
        self.selectedTags = Set(tags) // presenter가 태그 상태 관리
        view?.updateSelectedTags(tags)
        updateFilteredList(selectionSource: .none)
    }
    
    func didUpdateCoverLetter(_ item: CoverLetter) {
        // 로컬 상태 업데이트
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        allItems[index] = item
        selectedId = item.id
        updateFilteredList(selectionSource: .none)
        
        // 서버 동기화
        Task { try await saveCoverLetter(item) }
    }
    
    func saveCoverLetter(_ coverLetter: CoverLetter) async throws {
        guard AuthService.shared.isLoggedIn else {
            view?.showError(message: "미로그인 상태입니다.")
            return
        }
        let request = CoverLetterUpdateRequest(from: coverLetter)
        try await service.updateCoverLetter(coverLetter: request)
    }
    
    // MARK: - Private Helpers
    private func updateLoginUI() {
        let isLoggedIn = AuthService.shared.isLoggedIn
        view?.updateLoginUI(isLoggedIn: isLoggedIn)
    }
    
    private func updateFilteredList(selectionSource: SelectionSource) {
        Task {
            let filteredItems = await filteredItemsAsync()
            await MainActor.run {
                view?.showCoverLetters(filteredItems, selectedId: selectedId, selectionSource: selectionSource)
            }
        }
    }
    
    // 필터링 로직을 async로 만들어서 메인 스레드 블로킹 방지
    private func filteredItemsAsync() async -> [CoverLetter] {
        return await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return [] }
            return self.performFiltering()
        }.value
    }
    
    private func performFiltering() -> [CoverLetter] {
        var filtered = allItems.filter { selectedFilter.contains($0) }
        
        if isFilteringBookmark {
            filtered = filtered.filter { $0.isBookmarked }
        }
        
        if !selectedTags.isEmpty {
            filtered = filtered.filter { coverLetter in
                let tagNames = Set(
                    coverLetter.contents.flatMap { $0.tag }.map { $0.name }
                )
                return !selectedTags.isDisjoint(with: tagNames)
            }
        }
        
        guard !searchText.isEmpty else { return filtered }
        
        return filtered.filter { coverLetter in
            let inTitleOrCompany =
            coverLetter.title.localizedCaseInsensitiveContains(searchText) ||
            coverLetter.company.localizedCaseInsensitiveContains(searchText)
            
            let inContents = coverLetter.contents.contains { content in
                content.question.localizedCaseInsensitiveContains(searchText) ||
                content.answers.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
            
            return inTitleOrCompany || inContents
        }
    }
    
    private func loadMockCoverLetters() {
        self.allItems = MockCoverLetterFactory.makeMockData()
        updateFilteredList(selectionSource: .systemAuto)
    }
    
    private func fetchCoverLetters() async {
        do {
            var items = try await service.fetchAll()
            if items.isEmpty {
                items = try await createDefaultTemplates()
            }
            let contentsList = try await items.parallelMap {
                try await self.service.fetchContentsWithTags(for: $0.id)
            }
            for (index, contents) in contentsList.enumerated() {
                items[index].contents = contents
            }
            self.allItems = items
            self.allTags = extractTags(from: items)
            updateFilteredList(selectionSource: .systemAuto)
        } catch {
            view?.showError(message: "자기소개서 로딩 실패")
        }
    }
    
    private func extractTags(from coverLetters: [CoverLetter]) -> [CoverLetterTag] {
        let all = coverLetters
            .flatMap { $0.contents }
            .flatMap { $0.tag }

        let unique = Array(Set(all))
        return unique.sorted { $0.name < $1.name }
    }
    
    private func insertNewCoverLetter() async {
        let request = CoverLetterInsertRequest(company: "회사명", title: "자기소개서", job_position: "직무명")
        do {
            let saved = try await service.insert(coverLetter: request)
            allItems.insert(saved, at: 0)
            selectedId = saved.id
            updateFilteredList(selectionSource: .systemAuto)
        } catch {
            view?.showError(message: "자기소개서 추가 실패")
        }
    }
    
    // MARK: - Template 생성
    private func createDefaultTemplates() async throws -> [CoverLetter] {
        async let guide = insertGuideTemplate()
        async let manage = insertManageTemplate()
        return try await [guide, manage]
    }
    
    private func insertGuideTemplate() async throws -> CoverLetter {
        let request = CoverLetterInsertRequest(company: "회사명", title: "커리어 로그 가이드 - 자기소개서 작성", job_position: "지원 직무")
        let created = try await service.insert(coverLetter: request)
        let contents = CoverLetterContentInsertRequest.makeQnAGuideRequests(coverLetterId: created.id)
        created.contents = try await contents.parallelMap { try await self.service.insertContent($0) }
        return created
    }
    
    private func insertManageTemplate() async throws -> CoverLetter {
        let request = CoverLetterInsertRequest(company: "회사명", title: "커리어 로그 가이드 - 자기소개서 관리", job_position: "지원 직무")
        let created = try await service.insert(coverLetter: request)
        let contents = CoverLetterContentInsertRequest.makeManageGuideRequests(coverLetterId: created.id)
        created.contents = try await contents.parallelMap { try await self.service.insertContent($0) }
        return created
    }
}
