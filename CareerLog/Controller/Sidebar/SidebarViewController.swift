//
//  SidebarViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/20/25.
//

import UIKit


// MARK: - Protocol
protocol SidebarFilterDelegate: AnyObject {
    func didSelectFilter(_ filter: SidebarFilter)
}

class SidebarViewController: UITableViewController {
    weak var delegate: SidebarFilterDelegate?
    
    let sidebarFilters: [SidebarFilter] = [.all] + CoverLetterState.allCases.map { .state($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
        delegate?.didSelectFilter(selectedFilter)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sidebarFilters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = sidebarFilters[indexPath.row].title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.backgroundColor = .clear
        cell.selectionStyle = .gray
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = sidebarFilters[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
    }
}
