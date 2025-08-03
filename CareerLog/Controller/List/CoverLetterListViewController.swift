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

enum SelectionSource {
    case userInitiated     // 유저가 수동 선택한 경우
    case systemAuto        // Mac 등 시스템에서 상태 변경에 따라 자동 선택한 경우
    case none              // 선택 없이 UI만 업데이트
}


class CoverLetterListViewController: UIViewController {
    var presenter: CoverLetterListPresenter!
    let tableVC: CoverLetterTableViewController
    
    private lazy var bookmarkFilterButton: UIButton = UIButton()
    private lazy var tagFilterButton: UIButton = UIButton()
    private let footerButtonStackView = UIStackView()
    private lazy var addButton: UIButton = makePlainButton(title: "자기소개서 추가하기", image: UIImage(named: "plus"), tintColor: .tintColor)
    private lazy var loginButton: UIButton = makePlainButton(title: "로그인", image: nil, tintColor: .tintColor)
    private lazy var logoutButton: UIButton = makePlainButton(title: "로그아웃", image: nil, tintColor: .systemRed)
    private lazy var withdrawButton: UIButton = makePlainButton(title: "회원탈퇴", image: nil, tintColor: .systemRed)
    private let searchController = UISearchController(searchResultsController: nil)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.tableVC = CoverLetterTableViewController()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tableVC.mainTableDelegate = self
    }
    
    private let tagScrollView = UIScrollView()
    private let tagStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopButtons()
        setupBottomButtons()
        setupLayout()
        setupNavigationBar()
        configure()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !AuthService.shared.isLoggedIn {
            showLoginModal(reason: "로그인 후 자기소개서를 저장하거나 불러올 수 있어요.")
        }
    }
    
    private func configure() {
        updateFilteringBookmarkButton(isFiltering: false)
        updateTagButton(tag: "")
        updateSelectedTags([])
    }
    
    private func setupTopButtons() {
        // 북마크 필터 버튼
        bookmarkFilterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bookmarkFilterButton)
        bookmarkFilterButton.addTarget(self, action: #selector(filteringBookmarkButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            bookmarkFilterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            bookmarkFilterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bookmarkFilterButton.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        // 태그 필터 버튼
        tagFilterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagFilterButton)
        tagFilterButton.addTarget(self, action: #selector(filteringTagButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tagFilterButton.centerYAnchor.constraint(equalTo: bookmarkFilterButton.centerYAnchor),
            tagFilterButton.leadingAnchor.constraint(equalTo: bookmarkFilterButton.trailingAnchor, constant: 8),
            tagFilterButton.heightAnchor.constraint(equalTo: bookmarkFilterButton.heightAnchor)
        ])
        
        // 태그 스크롤 뷰
        tagScrollView.translatesAutoresizingMaskIntoConstraints = false
        tagScrollView.showsHorizontalScrollIndicator = false
        tagScrollView.alwaysBounceHorizontal = true
        tagScrollView.isScrollEnabled = true
        view.addSubview(tagScrollView)
        
        tagStackView.translatesAutoresizingMaskIntoConstraints = false
        tagStackView.axis = .horizontal
        tagStackView.spacing = 6
        tagStackView.alignment = .fill
        tagStackView.distribution = .fill
        tagScrollView.addSubview(tagStackView)
        
        tagScrollViewHeightConstraint = tagScrollView.heightAnchor.constraint(equalToConstant: 36)
        tagScrollViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            tagScrollView.centerYAnchor.constraint(equalTo: bookmarkFilterButton.centerYAnchor),
            tagScrollView.leadingAnchor.constraint(equalTo: tagFilterButton.trailingAnchor, constant: 2),
            tagScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tagStackView.topAnchor.constraint(equalTo: tagScrollView.topAnchor),
            tagStackView.bottomAnchor.constraint(equalTo: tagScrollView.bottomAnchor),
            tagStackView.leadingAnchor.constraint(equalTo: tagScrollView.leadingAnchor),
            tagStackView.trailingAnchor.constraint(equalTo: tagScrollView.trailingAnchor),
            tagStackView.heightAnchor.constraint(equalTo: tagScrollView.heightAnchor)
        ])
    }
    
    private func setupBottomButtons() {
        [addButton, loginButton, logoutButton, withdrawButton].forEach {
            footerButtonStackView.addArrangedSubview($0)
        }
        footerButtonStackView.axis = .vertical
        footerButtonStackView.spacing = 12
        footerButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerButtonStackView)

        addButton.addTarget(self, action: #selector(handleAddButtonTap), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        withdrawButton.addTarget(self, action: #selector(withdrawButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            footerButtonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            footerButtonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            footerButtonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
    }
    
    private func setupLayout() {
        view.backgroundColor = .backgroundBlue
        navigationItem.title = "자기소개서 목록"
        // 테이블뷰 컨트롤러 추가
        addChild(tableVC)
        view.addSubview(tableVC.view)
        tableVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableVC.view.topAnchor.constraint(equalTo: bookmarkFilterButton.bottomAnchor, constant: 12),
            tableVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableVC.view.bottomAnchor.constraint(equalTo: footerButtonStackView.topAnchor, constant: -8)
        ])
        
        tableVC.didMove(toParent: self)
    }
    
    private func setupNavigationBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchController.searchBar.searchTextField.backgroundColor = .backgroundBlueDark
        searchController.searchBar.searchTextField.layer.cornerRadius = 8
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.searchTextField.font = .systemFont(ofSize: 15)
        searchController.searchBar.placeholder = "회사명, 제목, 내용으로 검색"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
            let icon = UIImage(systemName: "chevron.left.2")
            let hideSidebarButton = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(didTapHideSidebarButton))
            navigationItem.rightBarButtonItem = hideSidebarButton
        }
    }
    
    @objc private func didTapHideSidebarButton() {
        splitViewController?.preferredDisplayMode = .secondaryOnly
    }
    
    @objc func handleAddButtonTap() {
        presenter.didTapAddButton()
    }
    
    @objc func loginButtonTapped() {
        presenter.didTapLoginButton()
    }
    
    @objc func logoutButtonTapped() {
        presenter.didTapLogoutButton()
    }
    
    @objc func withdrawButtonTapped() {
        presenter.didTapWithdrawButton()
    }
    
    @objc func filteringBookmarkButtonTapped() {
        presenter.didTapFilteringBookmarkButton()
    }
    
    @objc func filteringTagButtonTapped() {
        presenter.didTapFilteringTagButton()
    }
    
    func showTagFilter(tags: [String], selected: Set<String>) {
        let tagVC = TagFilterModalViewController()
        tagVC.configure(tags: tags, selectedTags: selected) // 상태 주입
        
        tagVC.onApplySelection = { [weak self] selectedTags in
            self?.presenter.didSelectTags(Array(selectedTags))
        }

        if let sheet = tagVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(tagVC, animated: true)
    }
    private var tagScrollViewHeightConstraint: NSLayoutConstraint!

    func updateSelectedTags(_ tags: [String]) {
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        tagScrollView.isHidden = tags.isEmpty
        tagScrollViewHeightConstraint.constant = tags.isEmpty ? 0 : 28

        for tag in tags {
            let label = PaddingLabel()
            label.text = tag
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabel
            label.backgroundColor = .systemGray6
            label.layer.cornerRadius = 12
            label.layer.masksToBounds = true
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.systemGray4.cgColor
            
            tagStackView.addArrangedSubview(label)
        }
    }
    
    func updateListUI(with items: [CoverLetter], selectedId: Int?, selectionSource: SelectionSource) {
        tableVC.configure(items: items, filter: presenter.selectedFilter)

        DispatchQueue.main.async {
            switch selectionSource {
            case .userInitiated:
                if let id = selectedId, items.contains(where: { $0.id == id }) {
                    self.tableVC.selectAndNotifyItem(withId: id, isAutoSelection: false)
                }
            case .systemAuto:
                if let id = selectedId, items.contains(where: { $0.id == id }) {
                    self.tableVC.selectAndNotifyItem(withId: id, isAutoSelection: true)
                } else {
                    self.tableVC.selectFirstIfNeeded()
                }
            case .none:
                break // 아무 것도 선택 안 함
            }
        }
    }
    
    private func makePlainButton(
        title: String?,
        image: UIImage?,
        tintColor: UIColor,
        fontSize: CGFloat = 15,
        weight: UIFont.Weight = .medium
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: weight)
        button.tintColor = tintColor
        return button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension CoverLetterListViewController: CoverLetterListViewProtocol {
    func showCoverLetters(_ items: [CoverLetter], selectedId: Int?, selectionSource: SelectionSource) {
        updateListUI(with: items, selectedId: selectedId, selectionSource: selectionSource)
    }

    func updateLoginUI(isLoggedIn: Bool) {
        DispatchQueue.main.async {
            self.loginButton.isHidden = isLoggedIn
            self.logoutButton.isHidden = !isLoggedIn
        }
    }
    
    func updateFilteringBookmarkButton(isFiltering: Bool) {
        var config = UIButton.Configuration.plain()
        config.title = "북마크만"
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var updated = incoming
            updated.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            return updated
        }

        let imageConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)

        if isFiltering {
            config.image = UIImage(systemName: "bookmark.fill", withConfiguration: imageConfig)
            config.baseForegroundColor = .accent
            config.background.backgroundColor = UIColor.accent.withAlphaComponent(0.1)
            config.background.cornerRadius = 6
            bookmarkFilterButton.layer.borderWidth = 1
            bookmarkFilterButton.layer.borderColor = UIColor.accent.cgColor
            bookmarkFilterButton.layer.cornerRadius = 6
        } else {
            config.image = UIImage(systemName: "bookmark", withConfiguration: imageConfig)
            config.baseForegroundColor = .secondaryLabel
            config.background.backgroundColor = .clear
            bookmarkFilterButton.layer.borderWidth = 0
        }

        bookmarkFilterButton.configuration = config
    }
    
    func updateTagButton(tag: String?) {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var updated = incoming
            updated.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            return updated
        }

        let title = (tag?.isEmpty ?? true) ? "태그 필터" : tag!
        config.title = title

        if let tag = tag, !tag.isEmpty {
            config.baseForegroundColor = .accent
            config.background.backgroundColor = UIColor.accent.withAlphaComponent(0.1)
            config.background.cornerRadius = 6
            tagFilterButton.layer.borderWidth = 1
            tagFilterButton.layer.borderColor = UIColor.accent.cgColor
            tagFilterButton.layer.cornerRadius = 6
        } else {
            config.baseForegroundColor = .secondaryLabel
            config.background.backgroundColor = .clear
            tagFilterButton.layer.borderWidth = 0
        }

        tagFilterButton.configuration = config
    }
    
    
    func reloadRow(withId id: Int) {
        DispatchQueue.main.async {
            self.tableVC.reloadRow(for: id)
        }
    }

    func showLoginModal(reason: String?) {
        DispatchQueue.main.async {
            let loginVC = LoginViewController()
            loginVC.delegate = self
            loginVC.modalPresentationStyle = .formSheet
            loginVC.reasonMessage = reason
            self.present(loginVC, animated: true)
        }
    }

    func showError(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - Delegate
extension CoverLetterListViewController: LoginViewControllerDelegate {
    func loginDidSucceed() {
        presenter.viewDidLoad() // 로그인 성공 후 Presenter에 위임
    }
}

extension CoverLetterListViewController: FilterSidebarDelegate {
    func filterSidebar(_ sidebar: SidebarViewController, didSelect filter: SidebarFilter) {
        guard let presenter else {
            print("❗️presenter is nil at the moment of filter selection")
            return
        }
        presenter.didSelectFilter(filter)
    }
}

extension CoverLetterListViewController: CoverLetterListInteractionDelegate {
    func didTapBookmark(for item: CoverLetter) {
        presenter.didToggleBookmark(for: item)
    }
    
    func didRequestDeleteCoverLetter(for item: CoverLetter) {
        presenter.didDeleteCoverLetter(item)
    }
}

extension CoverLetterListViewController: DetailViewControllerDelegate {
    // 디테일에서 업데이트시 메인 테이블 리스트 갱신
    func didUpdateCoverLetter(for item: CoverLetter) {
        presenter.didUpdateCoverLetter(item)
    }
}

extension CoverLetterListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        presenter.updateSearchText(text)
    }
}
