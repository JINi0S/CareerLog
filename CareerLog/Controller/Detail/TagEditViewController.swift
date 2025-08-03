//
//  TagEditViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/27/25.
//

import UIKit

// 기능: 태그 추가 & 삭제 & 이름 변경 & 순서 변경
// TODO: 삭제&수정에 따른 다른 자소서 항목들 관리, 태그 순서 저장
final class TagEditViewController: UIViewController {
    private let reuseIdentifier = "TagCell"
    private let tableView = UITableView()
    
    var tagOptions: [CoverLetterTag] = []
    var onUpdate: (([CoverLetterTag]) -> Void)?
    private let tagService = CoverLetterTagService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavigationItems()
    }
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNavigationItems() {
        navigationItem.title = "질문 태그 편집"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
}

// MARK: - Actions
private extension TagEditViewController {
    @objc func doneButtonTapped() {
        onUpdate?(tagOptions)
        dismiss(animated: true)
    }
    
    @objc func addButtonTapped() {
        presentAddTagAlert()
    }
}

// MARK: - Alert Presentation
private extension TagEditViewController {
    func presentAddTagAlert() {
        let alert = createAddTagAlert()
        present(alert, animated: true)
    }
    
    func createAddTagAlert() -> UIAlertController {
        let alert = UIAlertController(title: "태그 추가", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "새 태그 이름"
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            self?.handleAddTagAction(from: alert)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        return alert
    }
    
    func handleAddTagAction(from alert: UIAlertController) {
        guard let newText = alert.textFields?.first?.text?.trimmed,
              !newText.isEmpty else {
            showErrorAlert(message: "태그 이름을 입력해주세요.")
            return
        }
        
        guard !isTagNameDuplicated(newText) else {
            showErrorAlert(message: "이미 존재하는 태그입니다.")
            return
        }
        
        Task {
            await addTag(named: newText)
        }
    }
    
    func presentEditTagAlert(for tag: CoverLetterTag, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let alert = createEditTagAlert(for: tag, at: indexPath, completion: completion)
        present(alert, animated: true)
    }
    
    func createEditTagAlert(for tag: CoverLetterTag, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "태그 이름 수정", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = tag.name
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completion(false)
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            self?.handleEditTagAction(from: alert, for: tag, at: indexPath, completion: completion)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        return alert
    }
    
    func handleEditTagAction(from alert: UIAlertController, for tag: CoverLetterTag, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard let newText = alert.textFields?.first?.text?.trimmed,
              !newText.isEmpty else {
            showErrorAlert(message: "태그 이름을 입력해주세요.")
            completion(false)
            return
        }
        
        guard !isTagNameDuplicated(newText, excluding: tag.name) else {
            showErrorAlert(message: "이미 존재하는 태그입니다.")
            completion(false)
            return
        }
        
        Task {
            await updateTag(tag, newName: newText, at: indexPath, completion: completion)
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Tag Operations
private extension TagEditViewController {
    func addTag(named name: String) async {
        do {
            let newTag = try await tagService.insertTag(name: name)
            await MainActor.run {
                self.tagOptions.append(newTag)
                let indexPath = IndexPath(row: self.tagOptions.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        } catch {
            await MainActor.run {
                dump(error)
                self.showErrorAlert(message: "태그 추가에 실패했어요.")
            }
        }
    }
    
    func updateTag(_ tag: CoverLetterTag, newName: String, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) async {
        do {
            try await tagService.updateTag(id: tag.id, newName: newName)
            await MainActor.run {
                self.tagOptions[indexPath.row].name = newName
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                completion(true)
            }
        } catch {
            await MainActor.run {
                dump(error)
                self.showErrorAlert(message: "수정에 실패했어요. 다시 시도해주세요.")
                completion(false)
            }
        }
    }
    
    func deleteTag(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) async {
        let tag = tagOptions[indexPath.row]
        
        do {
            try await tagService.deleteTag(id: tag.id)
            await MainActor.run {
                self.tagOptions.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            }
        } catch {
            await MainActor.run {
                dump(error)
                self.showErrorAlert(message: "삭제에 실패했어요. 다시 시도해주세요.")
                completion(false)
            }
        }
    }
}

// MARK: - Helper Methods
private extension TagEditViewController {
    func isTagNameDuplicated(_ name: String, excluding excludedName: String? = nil) -> Bool {
        return tagOptions.contains { tag in
            tag.name == name && tag.name != excludedName
        }
    }
}

// MARK: - UITableViewDataSource
extension TagEditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = tagOptions[indexPath.row].name
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TagEditViewController: UITableViewDelegate {
    // 순서 변경 허용
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 순서 변경 처리
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = tagOptions.remove(at: sourceIndexPath.row)
        tagOptions.insert(movedItem, at: destinationIndexPath.row)
    }
    
    // 스와이프 액션 구성
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = createEditAction(for: indexPath)
        let deleteAction = createDeleteAction(for: indexPath)
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

// MARK: - Swipe Actions
private extension TagEditViewController {
    func createEditAction(for indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "이름 수정") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            
            let tag = self.tagOptions[indexPath.row]
            self.presentEditTagAlert(for: tag, at: indexPath, completion: completion)
        }
        
        action.backgroundColor = .systemBlue
        return action
    }
    
    func createDeleteAction(for indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            
            Task {
                await self.deleteTag(at: indexPath, completion: completion)
            }
        }
        
        return action
    }
}


// MARK: - String Extension
private extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
