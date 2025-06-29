//
//  DetailViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 5/29/25.
//

import UIKit

// MARK: - Constants
private enum Constants {
    static let sidebarWidth: CGFloat = 400
}
protocol DetailViewControllerDelegate: AnyObject {
    func didUpdateCoverLetter(for item: CoverLetter)
}

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: DetailViewControllerDelegate?
    
    var item: CoverLetter?
    
    private var mainContentView = UIView()
    private var sidebarView = DetailSidebarView()
    private var collectionView: DetailCollectionViewController!
    
    private var isSidebarVisible = true
    private var bookmarkButton: UIBarButtonItem!
    private let titleInputView = UITextField()
 
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupLayout()
        setupNavigationBar()
        setupCollectionView()
    }
    
    // MARK: - View Configuration
    private func configureView() {
        view.backgroundColor = .white
        sidebarView.delegate = self
    }
    
    private func setupLayout() {
        let separatorView = UIView()
        separatorView.backgroundColor = .systemGray4
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        let wrapperStackView = UIStackView(arrangedSubviews: [mainContentView, separatorView, sidebarView])
        wrapperStackView.axis = .horizontal
        wrapperStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(wrapperStackView)
        NSLayoutConstraint.activate([
            wrapperStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            wrapperStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wrapperStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wrapperStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sidebarView.widthAnchor.constraint(equalToConstant: Constants.sidebarWidth)
        ])
    }
    
    private func setupNavigationBar() {
        titleInputView.borderStyle = .none
        titleInputView.font = .boldSystemFont(ofSize: 16)
        titleInputView.textAlignment = .center
        titleInputView.placeholder = "제목 입력"
        titleInputView.text = item?.title ?? ""
        titleInputView.addTarget(self, action: #selector(companyTextFieldDidChange(_:)), for: .editingChanged)
        titleInputView.frame = CGRect(x: 0, y: 0, width: 300, height: 30) // TODO: 제한 없도록 크기 조정
        
        navigationItem.titleView = titleInputView
        navigationItem.scrollEdgeAppearance = UINavigationBarAppearance()
        navigationController?.navigationBar.backgroundColor = .systemGroupedBackground
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        bookmarkButton = UIBarButtonItem(image: .none, style: .done, target: self, action: #selector(bookmarkItem))
        let sidebarButton = UIBarButtonItem(image: UIImage(systemName: "sidebar.right"), style: .plain, target: self, action:  #selector(toggleSidebar))
        updateBookmarkButton()
        navigationItem.rightBarButtonItems = [sidebarButton, bookmarkButton, addButton]
        navigationItem.backBarButtonItem = .some(UIBarButtonItem(title: "", style: .plain, target: nil, action: nil))
    }
    
    private func setupCollectionView() {
        collectionView = DetailCollectionViewController(item: item)
        collectionView.onItemChanged = { [weak self] updated in
            self?.item = updated
            // TODO: 저장 or 업데이트 처리
        }
        
        addChild(collectionView)
        mainContentView.addSubview(collectionView.view)
        collectionView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.view.topAnchor.constraint(equalTo: mainContentView.topAnchor),
            collectionView.view.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor),
            collectionView.view.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor),
            collectionView.view.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor)
        ])
        collectionView.didMove(toParent: self)
    }
    
    // MARK: - Actions
    @objc private func companyTextFieldDidChange(_ textField: UITextField) {
        self.item?.title = textField.text ?? ""
        // TODO: 저장 처리
    }
    
    @objc private func toggleSidebar() {
        isSidebarVisible.toggle()
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.isHidden = !self.isSidebarVisible
        }
    }

    @objc private func addItem() {
        let nextId = item?.contents.max(by: { $0.id < $1.id })?.id ?? 0 + 1
        let newItem = CoverLetterContent(id: nextId, question: "자기소개서 문항을 작성해주세요.", answers: [""], characterLimit: 1000)
        item?.contents.append(newItem)
        collectionView.collectionView.reloadData()
        // collectionView.insertItems(at: [IndexPath(item: newIndex, section: section)])
    }
 
    @objc private func bookmarkItem() {
        item?.isBookmarked.toggle()
        updateBookmarkButton()
        if let updatedItem = item {
            delegate?.didUpdateCoverLetter(for: updatedItem) // 메인뷰 동기화
        }
    }
    
    private func updateBookmarkButton() {
        let imageName = item?.isBookmarked == true ? "bookmark.fill" : "bookmark"
        bookmarkButton.image = UIImage(systemName: imageName)
    }
    
    // MARK: - Public Method
    func configure(with item: CoverLetter) {
        self.item = item
        titleInputView.text = item.title
        sidebarView.configure(with: item)
        updateBookmarkButton()
        collectionView.reload(with: item)
    }
    
    func updateMainView() {
        if let item {
            delegate?.didUpdateCoverLetter(for: item) // 메인뷰 동기화
        }
    }
}

// MARK: - CoverLetterSelectionDelegate
extension DetailViewController: CoverLetterSelectionDelegate {
    func didSelectCoverLetter(_ coverLetter: CoverLetter) {
        self.configure(with: coverLetter)
    }
}

// MARK: - SidebarViewDelegate
// TODO: 쓰로틀??! 드바운스 적용
extension DetailViewController: SidebarViewDelegate {

  
    func sidebarView(_ view: DetailSidebarView, didChangeState state: CoverLetterState) {
        self.item?.state = state
        print("didChangeState")
        updateMainView()
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateCompany company: String) {
        print("didUpdateCompany")
        // TODO: 회사 모델 다시 짜기..
        self.item?.company.name = company
        updateMainView()
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateJob job: String) {
        print("didUpdateJob")
        self.item?.jobPosition = job
        updateMainView()
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateMemo memo: String) {
        print("didUpdateMemo")
        self.item?.memo = memo
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateDueDate date: Date) {
        print("didUpdateDueDate")
        item?.dueDate = date
        updateMainView()
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateWhitespace includesWhitespace: Bool) {
        print("didUpdateWhitespace")
        item?.includesWhitespace = includesWhitespace
    }
}
