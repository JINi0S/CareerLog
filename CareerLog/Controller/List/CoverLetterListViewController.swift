//
//  ViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 5/25/25.
//

import UIKit

protocol CoverLetterSelectionDelegate: AnyObject {
    func didSelectCoverLetter(_ coverLetter: CoverLetter)
}

class CoverLetterListViewController: UIViewController {
    var allItems: [CoverLetter] = []

    private var selectedFilter: SidebarFilter = .all
    private var selectedId: Int?

    let tableVC: CoverLetterTableViewController
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setTitle("자기소개서 추가하기", for: .normal)
        button.tintColor = .tintColor
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.tintColor = .tintColor
        return button
    }()
    
    private let service = CoverLetterService()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.tableVC = CoverLetterTableViewController()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tableVC.mainTableDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLoginUI()
        fetchCoverLetters()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !AuthService.shared.isLoggedIn {
            presentLoginModal(reason: "로그인 후 자기소개서를 저장하거나 불러올 수 있어요.")
        }
    }

    func setupLayout() {
        view.backgroundColor = .backgroundBlue
        navigationItem.title = "자기소개서 목록"
        // 테이블뷰 컨트롤러 추가
        addChild(tableVC)
        view.addSubview(tableVC.view)
        tableVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalStack = UIStackView(arrangedSubviews: [
            addButton,
            loginButton,
            logoutButton
        ])
        verticalStack.axis = .vertical
        verticalStack.spacing = 14
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalStack)
        
        addButton.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableVC.view.bottomAnchor.constraint(equalTo: verticalStack.topAnchor, constant: -8),
            
            verticalStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
        tableVC.didMove(toParent: self)
    }
    
    @objc func handleAddButtonTap() {
        guard AuthService.shared.isLoggedIn else {
            presentLoginModal(reason: "새로운 자기소개서를 작성하려면 로그인이 필요해요.")
            return
        }
        Task { await insertNewEmptyCoverLetter() }
    }
    
    private func insertNewEmptyCoverLetter() async {
        let request = CoverLetterInsertRequest(
            company: "회사명",
            title: "자기소개서",
            job_position: "직무명"
        )
        
        do {
            let saved = try await service.insert(coverLetter: request)
            allItems.insert(saved, at: 0)
            selectedId = saved.id
            updateList()
        } catch {
            // TODO: 사용자에게 에러 알림 처리
            print("자기소개서 저장 실패: \(error)")
        }
    }
    
    func fetchCoverLetters() {
        Task {
            if AuthService.shared.isLoggedIn {
                do {
                    var items = try await service.fetchAll()
                    
                    // 처음 로그인 후 자기소개서가 없으면 기본 템플릿 하나 생성
                    if items.isEmpty {
                        let defaultItems = try await createDefaultCoverLettersIfEmpty()
                        items = defaultItems
                    }
                    
                    let contentsList = try await items.parallelMap() { [weak self] item -> [CoverLetterContent] in
                        return (try await self?.service.fetchContentsWithTags(for: item.id)) ?? []
                    }

                    for (index, contents) in contentsList.enumerated() {
                        items[index].contents = contents
                    }
                    self.allItems = items
                    updateList()
                } catch {
                    print("🚨 자기소개서 로드 실패: \(error)")
                }
            } else {
                // 비로그인 상태: 목데이터 사용
                self.allItems = MockCoverLetterFactory.makeMockData()
                updateList()
            }
        }
    }
    
    private func createDefaultCoverLettersIfEmpty() async throws -> [CoverLetter] {
        async let guide = insertGuideTemplate()
        async let manage = insertManageTemplate()
        return try await [guide, manage]
    }
    
    private func insertGuideTemplate() async throws -> CoverLetter {
        let guideRequest = CoverLetterInsertRequest(
            company: "회사명",
            title: "커리어 로그 가이드 - 자기소개서 작성",
            job_position: "지원 직무"
        )
        let created = try await service.insert(coverLetter: guideRequest)
        let contents = CoverLetterContentInsertRequest.makeQnAGuideRequests(coverLetterId: created.id)
        let insertedContents = try await contents.parallelMap {
            try await self.service.insertContent($0)
        }
        created.contents = insertedContents
        return created
    }

    private func insertManageTemplate() async throws -> CoverLetter {
        let manageRequest = CoverLetterInsertRequest(
            company: "회사명",
            title: "커리어 로그 가이드 - 자기소개서 관리",
            job_position: "지원 직무"
        )
        let created = try await service.insert(coverLetter: manageRequest)
        let contents = CoverLetterContentInsertRequest.makeManageGuideRequests(coverLetterId: created.id)
        let insertedContents = try await contents.parallelMap {
            try await self.service.insertContent($0)
        }
        created.contents = insertedContents
        return created
    }
    
    func updateCoverLetter(coverLetter: CoverLetter) {
        guard AuthService.shared.isLoggedIn else {
            print("미로그인 상태입니다.")
            return
        }
        let request = CoverLetterUpdateRequest(from: coverLetter)
        
        Task {
            do {
                try await service.updateCoverLetter(coverLetter: request)
                print("자기소개서 업데이트 성공")
            } catch {
                print("자기소개서 업데이트 실패: \(error)")
            }
        }
    }
    
    func updateList() {
        let filteredItems = allItems.filter { selectedFilter.contains($0) }
        tableVC.configure(items: filteredItems, filter: selectedFilter)
        selectDefaultItemIfNeeded(from: filteredItems)
    }
    
    private func selectDefaultItemIfNeeded(from items: [CoverLetter]) {
        DispatchQueue.main.async {
            if let id = self.selectedId, items.contains(where: { $0.id == id }) {
                self.tableVC.selectAndNotifyItem(withId: id)
            } else {
                self.tableVC.selectFirstIfNeeded()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Auth Handling

private extension CoverLetterListViewController {
    func updateLoginUI() {
        DispatchQueue.main.async {
            if AuthService.shared.isLoggedIn {
                self.loginButton.isHidden = true
                self.logoutButton.isHidden = false
            } else {
                self.loginButton.isHidden = false
                self.logoutButton.isHidden = true
            }
        }
    }

    func presentLoginModal(reason: String? = nil) {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        loginVC.modalPresentationStyle = .formSheet
        if let reason = reason {
            loginVC.reasonMessage = reason
        }
        present(loginVC, animated: true)
    }
    
    @objc func loginButtonTapped() {
        presentLoginModal(reason: "새로운 자기소개서를 작성하려면 로그인이 필요해요.")
    }
    
    @objc func logoutButtonTapped() {
        AuthService.shared.signOut { [weak self] result in
            switch result {
            case .success:
                self?.updateLoginUI()
                self?.fetchCoverLetters()
                DispatchQueue.main.async {
                    self?.presentLoginModal()
                }
            case .failure(let error):
                print("로그아웃 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Delegate
extension CoverLetterListViewController: LoginViewControllerDelegate {
    func loginDidSucceed() {
        updateLoginUI()
        fetchCoverLetters()
    }
}

extension CoverLetterListViewController: SidebarFilterDelegate {
    func didSelectFilter(_ filter: SidebarFilter) {
        self.selectedFilter = filter
        self.updateList()
    }
}

extension CoverLetterListViewController: CoverLetterListInteractionDelegate {
    func didTapBookmark(for item: CoverLetter) {
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        allItems[index].isBookmarked.toggle()
        updateCoverLetter(coverLetter: item)
        tableVC.reloadRow(for: item.id)
    }
    
    func didRequestDeleteCoverLetter(for coverLetter: CoverLetter) {
        guard AuthService.shared.isLoggedIn else {
           print("미로그인 상태 - 삭제 요청 실패")
            return
        }
        
        Task {
            do {
                try await service.deleteCoverLetter(coverLetterId: coverLetter.id)
                print("자기소개서 삭제 성공")

                // 전체 소스에서 삭제
                if let index = allItems.firstIndex(where: { $0.id == coverLetter.id }) {
                    allItems.remove(at: index)
                }

                // 현재 선택 아이디도 갱신
                if selectedId == coverLetter.id {
                    selectedId = nil
                }

                // 필터 적용 → 내부에서 configure + reload 수행
                updateList()
            } catch {
                print("삭제 실패: \(error)")
            }
        }
    }
}

extension CoverLetterListViewController: DetailViewControllerDelegate {
    // 디테일에서 업데이트시 메인 테이블 리스트 갱신
    func didUpdateCoverLetter(for item: CoverLetter) {
        if let index = allItems.firstIndex(where: { $0.id == item.id }) {
            allItems[index] = item
        }
        selectedId = item.id
        // applyFilter()
        tableVC.tableView.reloadData()
    }
}

extension Sequence {
    func parallelMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        try await withThrowingTaskGroup(of: (Int, T).self) { group in
            var results = Array<T?>(repeating: nil, count: self.underestimatedCount)
            for (index, element) in self.enumerated() {
                group.addTask {
                    let result = try await transform(element)
                    return (index, result)
                }
            }
            for try await (index, value) in group {
                results[index] = value
            }
            return results.compactMap { $0 }
        }
    }
}
