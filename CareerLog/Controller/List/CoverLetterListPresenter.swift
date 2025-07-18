//
//  CoverLetterListPresenter.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/15/25.
//

// TODO: 업데이트 동작 되고 있는지 최종 확인 필요
final class CoverLetterListPresenter {
    weak var view: CoverLetterListViewProtocol?
    private let service = CoverLetterService()
    var selectedFilter: SidebarFilter = .all
    private var selectedId: Int?
    
    private(set) var allItems: [CoverLetter] = []
    
    private func filteredItems() -> [CoverLetter] {
        allItems.filter { selectedFilter.contains($0) }
    }
    
    required init(view: CoverLetterListViewProtocol) {
        self.view = view
    }
    
    // MARK: - View Life Cycle
    func viewDidLoad() {
        let isLoggedIn = AuthService.shared.isLoggedIn
        view?.updateLoginUI(isLoggedIn: isLoggedIn)
        if isLoggedIn {
            fetchCoverLetters()
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
    
    func didToggleBookmark(for item: CoverLetter) {
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        allItems[index].isBookmarked.toggle()
        let updatedItem = allItems[index]
        
        Task {
            do {
                try await saveCoverLetter(updatedItem)
                view?.reloadRow(withId: item.id)
            } catch {
                view?.showError(message: "북마크를 저장하지 못했어요.")
                print("자기소개서 북마크 업데이트 실패:", error.localizedDescription)
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
                
                updateFilteredList()
            } catch {
                view?.showError(message: "삭제 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func didSelectFilter(_ filter: SidebarFilter) {
        self.selectedFilter = filter
        updateFilteredList()
    }
    
    func didUpdateCoverLetter(_ item: CoverLetter) {
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        allItems[index] = item
        selectedId = item.id
        updateFilteredList()
        
        Task {
            try await saveCoverLetter(item) // 필요한지 재확인
        }
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
    private func updateFilteredList() {
        view?.showCoverLetters(filteredItems(), selectedId: selectedId)
    }
    
    private func loadMockCoverLetters() {
        self.allItems = MockCoverLetterFactory.makeMockData()
        updateFilteredList()
    }
    
    private func fetchCoverLetters() {
        Task {
            do {
                var items = try await service.fetchAll()
                if items.isEmpty {
                    let defaults = try await createDefaultTemplates()
                    items = defaults
                }
                let contentsList = try await items.parallelMap {
                    try await self.service.fetchContentsWithTags(for: $0.id)
                }
                for (index, contents) in contentsList.enumerated() {
                    items[index].contents = contents
                }
                self.allItems = items
                updateFilteredList()
            } catch {
                view?.showError(message: "자기소개서 로딩 실패")
            }
        }
    }
    
    private func insertNewCoverLetter() async {
        let request = CoverLetterInsertRequest(company: "회사명", title: "자기소개서", job_position: "직무명")
        do {
            let saved = try await service.insert(coverLetter: request)
            allItems.insert(saved, at: 0)
            selectedId = saved.id
            updateFilteredList()
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
