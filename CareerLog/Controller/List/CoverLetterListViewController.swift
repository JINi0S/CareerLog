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
    var presenter: CoverLetterListPresenter!
    let tableVC: CoverLetterTableViewController

    private lazy var addButton: UIButton = makeButton(title: "자기소개서 추가하기", image: UIImage(named: "plus"), tintColor: .tintColor)
    private lazy var loginButton: UIButton = makeButton(title: "로그인", image: nil, tintColor: .tintColor)
    private lazy var logoutButton: UIButton = makeButton(title: "로그아웃", image: nil, tintColor: .systemRed)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.tableVC = CoverLetterTableViewController()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tableVC.mainTableDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !AuthService.shared.isLoggedIn {
            showLoginModal(reason: "로그인 후 자기소개서를 저장하거나 불러올 수 있어요.")
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
        verticalStack.spacing = 12
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
            verticalStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        tableVC.didMove(toParent: self)
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
    
    func updateListUI(with items: [CoverLetter], selectedId: Int?) {
        tableVC.configure(items: items, filter: presenter.selectedFilter)
        DispatchQueue.main.async {
            if let id = selectedId,  items.contains(where: { $0.id == id })  {
                self.tableVC.selectAndNotifyItem(withId: id)
            } else {
                self.tableVC.selectFirstIfNeeded()
            }
        }
    }
    
    private func makeButton(title: String?, image: UIImage?, tintColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        button.tintColor = tintColor
        return button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CoverLetterListViewController: CoverLetterListViewProtocol {
    func showCoverLetters(_ items: [CoverLetter], selectedId: Int?) {
        updateListUI(with: items, selectedId: selectedId)
    }

    
    func updateLoginUI(isLoggedIn: Bool) {
        DispatchQueue.main.async {
            self.loginButton.isHidden = isLoggedIn
            self.logoutButton.isHidden = !isLoggedIn
        }
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

extension CoverLetterListViewController: SidebarFilterDelegate {
    func didSelectFilter(_ filter: SidebarFilter) {
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
