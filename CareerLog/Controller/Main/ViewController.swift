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

class ViewController: UIViewController, SidebarSelectionDelegate {
    var allItems: [CoverLetter] =  CoverLetter.mockCoverLetters // 전체 데이터
    var filteredItems: [CoverLetter] = []
    
    let tableVC: MainTableViewController
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setTitle("자기소개서 추가하기", for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.tableVC = MainTableViewController(items: filteredItems, sectionTitle: "자기소개서 리스트")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }

    func setLayout() {
        view.backgroundColor = .backgroundBlue

        // 테이블뷰 컨트롤러 추가
        addChild(tableVC)
        view.addSubview(tableVC.view)
        tableVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableVC.view.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -8),

            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        tableVC.didMove(toParent: self)
    }
    
    @objc func handleAddButtonTap() {
        let newCoverLetter = CoverLetter(
            id: UUID().hashValue,
            company: .init(id: UUID().hashValue, name: "회사명"),
            title: "Software Engineer 자기소개서",
            contents: [.init(id: 0, question: "질문을 입력해주세요.", answers: ["답변을 입력해주세요."], characterLimit: 1000)],
            state: .draft,
            jobPosition: "Software Engineer"
        )
        
        filteredItems.append(newCoverLetter)
        tableVC.updateItems(filteredItems)
        
        // 테이블뷰 리로드 후 방금 추가한 아이템을 선택
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newIndexPath = IndexPath(row: self.filteredItems.count - 1, section: 0)
            self.tableVC.tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .none)
            self.tableVC.tableView(self.tableVC.tableView, didSelectRowAt: newIndexPath)
        }
    }
    
    func didSelectState(_ state: CoverLetterState?) {
        if let state {
            filteredItems = allItems.filter { $0.state == state }
        } else {
            filteredItems = allItems
        }
        tableVC.updateItems(filteredItems)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController: DetailViewControllerDelegate {
    func didUpdateCoverLetter(for item: CoverLetter) {
        // 리스트 갱신
        if let index = allItems.firstIndex(where: { $0.id == item.id }) {
            allItems[index] = item
            tableVC.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}
