//
//  DetailViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 5/29/25.
//

import UIKit
import SafariServices

// MARK: - Constants
private enum Constants {
    static let sidebarWidth: CGFloat = 400
}
protocol DetailViewControllerDelegate: AnyObject {
    func didUpdateCoverLetter(for item: CoverLetter)
}

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    private let service = CoverLetterService()
    private let tagService = CoverLetterTagService()
    private var tagOptions: [CoverLetterTag] = []

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
        fetchTags()
    }
    
    // MARK: - View Configuration
    private func configureView() {
        view.backgroundColor = .systemBackground
        sidebarView.delegate = self
    }
    
    private func setupLayout() {
#if os(iOS)
        toggleSidebar()
#endif
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
        titleInputView.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        titleInputView.frame = CGRect(x: 0, y: 0, width: 300, height: 30) // TODO: 제한 없도록 크기 조정
        
        navigationItem.titleView = titleInputView
        navigationItem.scrollEdgeAppearance = UINavigationBarAppearance()
        navigationController?.navigationBar.backgroundColor = .systemGroupedBackground
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        addButton.isHidden = (!AuthService.shared.isLoggedIn)
        
        bookmarkButton = UIBarButtonItem(image: .none, style: .done, target: self, action: #selector(bookmarkItem))
        let sidebarButton = UIBarButtonItem(image: UIImage(systemName: "sidebar.right"), style: .plain, target: self, action:  #selector(toggleSidebar))
        updateBookmarkButton()
        navigationItem.rightBarButtonItems = [sidebarButton, bookmarkButton, addButton]
        navigationItem.backBarButtonItem = .some(UIBarButtonItem(title: "", style: .plain, target: nil, action: nil))
    }
    
    private func setupCollectionView() {
        collectionView = DetailCollectionViewController(item: item)
        // MARK: 저장 or 업데이트 처리
        collectionView.onCoverLetterChanged = { [weak self] updatedCoverLetter in
            self?.item = updatedCoverLetter
            self?.triggerDebouncedUpdate(coverLetter: updatedCoverLetter)
        }
        collectionView.onContentChange = { [weak self] updatedContent in
            self?.triggerDebouncedUpdate(content: updatedContent)
        }
        collectionView.onDeleteContent = { [weak self] coverLetterId, contentId in
            self?.deleteCoverLetterContent(coverLetterId: coverLetterId, contentId: contentId)
        }
        collectionView.onTagChanged = { [weak self] tagId, contentId, isSelected in
            Task {
                do {
                    if isSelected {
                        try await self?.tagService.attachTagToContent(contentId: contentId, tagId: tagId)
                    } else {
                        try await self?.tagService.detachTagFromContent(contentId: contentId, tagId: tagId)
                    }
                } catch {
                    print("태그 업데이트 실패: \(error)")
                }
            }
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
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.item?.title = textField.text ?? ""
        if let item {
            self.triggerDebouncedUpdate(coverLetter: item)
        }
    }
    
    @objc private func toggleSidebar() {
        isSidebarVisible.toggle()
        UIView.animate(withDuration: 0.3) {
            self.sidebarView.isHidden = !self.isSidebarVisible
        }
    }
    
    @objc private func addItem() {
        // TODO: 생성뷰를 따로 만들기
        guard let coverLetterId = item?.id else { return }
        let newContent = CoverLetterContentInsertRequest(
            cover_letter_id: coverLetterId,
            question: "자기소개서 문항을 작성해 주세요.",
            answer: [""],
            character_limit: nil
        )
        
        Task {
            do {
                let savedContent = try await service.insertContent(newContent)
                item?.contents.append(savedContent)
                collectionView.collectionView.reloadData()
                // collectionView.insertItems(at: [IndexPath(item: newIndex, section: section)])
            } catch {
                print("자기소개서 추가 실패: \(error)")
                // 에러 알림 처리
            }
        }
    }
 
    @objc private func bookmarkItem() {
        item?.isBookmarked.toggle()
        updateBookmarkButton()
        updateMainView()
    }
    
    private func updateBookmarkButton() {
        let imageName = item?.isBookmarked == true ? "bookmark.fill" : "bookmark"
        bookmarkButton?.image = UIImage(systemName: imageName)
    }
    
    // MARK: - Public Method
    func configure(with item: CoverLetter) {
        self.item = item
        titleInputView.text = item.title
        sidebarView.configure(with: item)
        updateBookmarkButton()
        collectionView?.setTagOptions(tagOptions)
        collectionView?.reload(with: item)
    }
    
    func updateMainView() {
        if let item {
            delegate?.didUpdateCoverLetter(for: item) // 메인뷰 동기화
        }
    }
    
    private let coverLetterDebouncer = DebouncerMap<Int>(delay: 3.0)
    private let contentDebouncer = DebouncerMap<Int>(delay: 3.0)

    private func triggerDebouncedUpdate(coverLetter: CoverLetter) {
        coverLetterDebouncer.run(id: coverLetter.id) { [weak self] in
            self?.updateCoverLetter(coverLetter: coverLetter)
        }
    }
    
    private func triggerDebouncedUpdate(content: CoverLetterContent) {
        contentDebouncer.run(id: content.id) { [weak self] in
            self?.updateCoverLetterContent(content: content)
        }
    }
    
   private func updateCoverLetter(coverLetter: CoverLetter) {
       guard AuthService.shared.isLoggedIn else {
           print("미로그인 상태 - 컨텐츠 업데이트 요청 실패")
           return
       }
       
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
            apply_url: coverLetter.applyUrl,
            includes_whitespace: coverLetter.includesWhitespace
        )

       Task {
            do {
                try await service.updateCoverLetter(coverLetter: updateValue)
                print("자기소개서 업데이트 성공: \(coverLetter.id)")
            } catch {
                print("자기소개서 업데이트 실패: \(error)")
            }
        }
    }
    
    private func updateCoverLetterContent(content: CoverLetterContent) {
        guard AuthService.shared.isLoggedIn else {
            print("미로그인 상태 - 컨텐츠 업데이트 요청 실패")
            return
        }
        
        let updateValue = CoverLetterContentUpdateRequest(
            id: content.id,
            cover_letter_id: content.coverLetterId,
            question: content.question,
            answer: content.answers,
            character_limit: content.characterLimit
        )
        
        Task {
            do {
                try await service.updateContent(content: updateValue)
                print("자기소개서 컨텐츠 업데이트 성공: \(content.id)")
            } catch {
                print("자기소개서 컨텐츠 업데이트 실패: \(error)")
            }
        }
    }
    
    private func deleteCoverLetterContent(coverLetterId: Int, contentId: Int) {
        Task {
            do {
                try await service.deleteContent(contentId: contentId, coverLetterId: coverLetterId)
                print("자기소개서 컨텐츠 삭제 성공: \(contentId)")
            } catch {
                print("자기소개서 컨텐츠 삭제 실패: \(error)")
            }
        }
    }
    
    // MARK: - 태그 관련
    private func fetchTags() {
        Task {
            do {
                let tags = try await tagService.fetchAllTags()
                self.tagOptions = tags
                self.collectionView.setTagOptions(tags)
            } catch {
                print("태그 불러오기 실패: \(error)")
            }
        }
    }
}

// MARK: - CoverLetterSelectionDelegate
extension DetailViewController: CoverLetterSelectionDelegate {
    func didSelectCoverLetter(_ coverLetter: CoverLetter) {
        self.configure(with: coverLetter)
    }
}

// MARK: - DetailSidebarViewDelegate
// TODO: 쓰로틀??! 드바운스 적용
extension DetailViewController: DetailSidebarViewDelegate {
    func sidebarView(_ view: DetailSidebarView, didTapUrlButton urlString: String) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), UIApplication.shared.canOpenURL(url) else {
            showInvalidUrlAlert()
            return
        }
        presentSafariViewController(for: url)
    }
    
    private func presentSafariViewController(for url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .currentContext
        
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController { topVC.present(safariVC, animated: true) }
    }
    
    private func showInvalidUrlAlert() {
        let alert = UIAlertController(
            title: "유효하지 않은 URL",
            message: "올바른 링크를 입력했는지 확인해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func sidebarView(_ view: DetailSidebarView, didChangeState state: CoverLetterState) {
        self.item?.state = state
        print("didChangeState")
        updateMainView()
        if let item {
            self.triggerDebouncedUpdate(coverLetter: item)
        }
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateCompany company: String) {
        print("didUpdateCompany")
        self.item?.company = company
        updateMainView()
        if let item {
            self.triggerDebouncedUpdate(coverLetter: item)
        }
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateJob job: String) {
        print("didUpdateJob")
        self.item?.jobPosition = job
        updateMainView()
        if let item {
            self.triggerDebouncedUpdate(coverLetter: item)
        }
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateUrl url: String) {
        print("didUpdateUrl")
        self.item?.applyUrl = url
        if let item {
            self.triggerDebouncedUpdate(coverLetter: item)
        }
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateMemo memo: String) {
        print("didUpdateMemo")
        self.item?.memo = memo
        if let item {
            self.triggerDebouncedUpdate(coverLetter: item)
        }
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateDueDate date: Date) {
        print("didUpdateDueDate")
        item?.dueDate = date
        updateMainView()
        if let item {
            self.triggerDebouncedUpdate(coverLetter: item)
        }
    }
    
    func sidebarView(_ view: DetailSidebarView, didUpdateWhitespace includesWhitespace: Bool) {
        print("didUpdateWhitespace")
        item?.includesWhitespace = includesWhitespace
        if let item {
            self.triggerDebouncedUpdate(coverLetter: item)
        }
    }
}
