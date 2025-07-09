//
//  ViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 5/25/25.
//

import UIKit
import Supabase

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
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
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
        fetchCoverLetters()
        setLayout()
    }

    func setLayout() {
        view.backgroundColor = .backgroundBlue
        navigationItem.title = "자기소개서 목록"
        // 테이블뷰 컨트롤러 추가
        addChild(tableVC)
        view.addSubview(tableVC.view)
        tableVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
        view.addSubview(logoutButton)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableVC.view.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -8),
            
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -12),
            
            logoutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        tableVC.didMove(toParent: self)
    }
    
    @objc func logoutButtonTapped() {
        AuthService.shared.signOut { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // 로그인 뷰 전환 등 작업 실행
                    // self.presentLoginScreen()
                }
            case .failure(let error):
                print("로그아웃 실패: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func handleAddButtonTap() {
        let newCoverLetter = CoverLetterInsertRequest(
            company: "회사명",
            title:  "Software Engineer 자기소개서",
            job_position: "Software Engineer"
        )
      
        Task {
            do {
                let savedLetter = try await service.insert(coverLetter: newCoverLetter)
                allItems.insert(savedLetter, at: 0)
                selectedId = savedLetter.id
                updateList()
            } catch {
                print("자기소개서 저장 실패: \(error)")
                // 사용자에게 에러 알림 처리
            }
        }
    }
    
    func fetchCoverLetters() {
        Task {
            do {
                let items = try await service.fetchAll()
                let contentsList = try await parallelMap(items) { [weak self] item -> [CoverLetterContent] in
                    return (try await self?.service.fetchContentsWithTags(for: item.id)) ?? []
                }

                for (index, contents) in contentsList.enumerated() {
                    items[index].contents = contents
                }
                dump(items)
                self.allItems = items
                updateList()
            } catch {
                print("🚨 Error: \(error)")
            }
        }
    }
    
    func updateCoverLetter(coverLetter: CoverLetter) {
         let updateValue = CoverLetterUpdateRequest(
             id: coverLetter.id,
             company: coverLetter.company,
             title: coverLetter.title,
             state: coverLetter.state.rawValue,
             is_bookmarked: coverLetter.isBookmarked,
             due_date: coverLetter.dueDate,
             job_position: coverLetter.jobPosition,
             memo: coverLetter.memo,
             updated_at: coverLetter.updatedAt,
             includes_whitespace: coverLetter.includesWhitespace
         )

        Task {
             do {
                 try await service.updateCoverLetter(coverLetter: updateValue)
                 print("자기소개서 업데이트 성공")
             } catch {
                 print("자기소개서 업데이트 실패: \(error)")
             }
         }
     }
    
    func updateList() {
        let filteredItems = allItems.filter { selectedFilter.contains($0) }
        tableVC.configure(items: filteredItems, filter: selectedFilter)
        
        // 기존 선택이 필터링 후에도 포함되어 있으면 그거 선택, 없으면 첫 번째 선택
        DispatchQueue.main.async {
            if let selectedId = self.selectedId, filteredItems.contains(where: { $0.id == selectedId }) {
                self.tableVC.selectAndNotifyItem(withId: selectedId)
            } else {
                self.tableVC.selectFirstIfNeeded()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

// 재사용 가능한 유틸
func parallelMap<T, U>(
    _ items: [T],
    _ transform: @escaping (T) async throws -> U
) async throws -> [U] {
    try await withThrowingTaskGroup(of: (Int, U).self) { group in
        for (index, item) in items.enumerated() {
            group.addTask {
                let result = try await transform(item)
                return (index, result)
            }
        }
        
        var results = Array<U?>(repeating: nil, count: items.count)
        
        for try await (index, value) in group {
            results[index] = value
        }
        
        return results.compactMap { $0 }
    }
}
