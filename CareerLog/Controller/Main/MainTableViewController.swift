//
//  MainTableViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 5/26/25.
//

import UIKit

class MainTableViewController: UITableViewController {    
    weak var delegate: CoverLetterSelectionDelegate?

    private var items: [CoverLetter]
    private var sectionTitle: String?
    
    // 커스텀 이니셜라이저
    init(items: [CoverLetter], sectionTitle: String? = nil) {
        self.items = items
        self.sectionTitle = sectionTitle
        super.init(style: .plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CoverLetterCell.self, forCellReuseIdentifier: CoverLetterCell.reuseIdentifier)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroundBlue
    }
    
    func updateItems(_ newItems: [CoverLetter]) {
        self.items = newItems
        tableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoverLetterCell.reuseIdentifier, for: indexPath) as? CoverLetterCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configure(with: item)
        cell.onTapBookmarkButton = { [weak self] in
            self?.items[indexPath.row].isBookmarked.toggle()
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
    
    /// 섹션 타이틀 주입
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle
    }
    
    /// 테이블 선택 처리
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
//        let detailVC = DetailViewController(item: selectedItem)
//        navigationController?.pushViewController(detailVC, animated: true)
        delegate?.didSelectCoverLetter(selectedItem)
    }
}
