//
//  SidebarViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/20/25.
//

import UIKit


// MARK: - Protocol
protocol FilterSidebarDelegate: AnyObject {
    func filterSidebar(_ sidebar: SidebarViewController, didSelect filter: SidebarFilter)
}

class SidebarViewController: UITableViewController {
    weak var delegate: FilterSidebarDelegate?
    let sidebarFilters: [SidebarFilter] = [.all] + CoverLetterState.allCases.map { .state($0) }
    static let reuseIdentifier = "FilterCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SidebarViewController.reuseIdentifier)
        tableView.tintColor = .systemGray3
        tableView.estimatedRowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 초기 선택 상태 설정
        super.viewWillAppear(animated)
        let defaultIndexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: defaultIndexPath, animated: false, scrollPosition: .none)
        
        // delegate 호출
        let selectedFilter = sidebarFilters[defaultIndexPath.row]
        delegate?.filterSidebar(self, didSelect: selectedFilter)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sidebarFilters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SidebarViewController.reuseIdentifier, for: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = sidebarFilters[indexPath.row]
        delegate?.filterSidebar(self, didSelect: selectedFilter)
        splitViewController?.show(.supplementary) // iOS 고려
    }
    
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let filter = sidebarFilters[indexPath.row]
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.backgroundColor = .clear
    }
}
