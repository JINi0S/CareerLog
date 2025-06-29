//
//  TagEditViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/27/25.
//

import UIKit

// 기능: 태그 추가 & 삭제 & 이름 변경 & 순서 변경
// TODO: 삭제&수정에 따른 다른 자소서 항목들 관리
final class TagEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var options: [String] = []
    var onUpdate: (([String]) -> Void)?
    let identifier = "TagCell"
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationItems()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
 
    private func setupNavigationItems() {
        navigationItem.title = "질문 태그 편집"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTag))
    }
    
    @objc private func doneEditing() {
        onUpdate?(options)
        dismiss(animated: true)
    }
    
    @objc private func addTag() {
        let alert = UIAlertController(title: "태그 추가", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "새 태그 이름"
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "추가", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let newText = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newText.isEmpty else {
                self.showAlert(message: "태그 이름을 입력해주세요.")
                return
            }
            
            if self.options.contains(newText) {
                self.showAlert(message: "이미 존재하는 태그입니다.")
                return
            }
            
            self.options.append(newText)
            self.tableView.insertRows(at: [IndexPath(row: self.options.count - 1, section: 0)], with: .automatic)
        }))
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    // MARK: - 편집
    // 순서 변경 허용
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 순서 변경 처리
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = options.remove(at: sourceIndexPath.row)
        options.insert(movedItem, at: destinationIndexPath.row)
    }
    
    // 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "이름 수정") { [weak self] (action, view, success) in
            guard let self = self else { return }
            
            let currentName = self.options[indexPath.row]
            
            let alert = UIAlertController(title: "태그 이름 수정", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = currentName
            }
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
                success(false)
            }))
            
            alert.addAction(UIAlertAction(title: "저장", style: .default, handler: { _ in
                guard let newText = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newText.isEmpty else {
                    self.showAlert(message: "태그 이름을 입력해주세요.")
                    success(false)
                    return
                }
                
                if self.options.contains(newText), newText != currentName {
                    self.showAlert(message: "이미 존재하는 태그입니다.")
                    success(false)
                    return
                }
                
                self.options[indexPath.row] = newText
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                success(true)
            }))
            
            self.present(alert, animated: true)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, success) in
            self?.options.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            success(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
