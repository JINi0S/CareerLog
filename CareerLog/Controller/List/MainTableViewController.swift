//
//  MainTableViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 5/26/25.
//

import UIKit

protocol CoverLetterListInteractionDelegate: AnyObject {
    func didTapBookmark(for item: CoverLetter)
    func didRequestDeleteCoverLetter(for item: CoverLetter)
}

class CoverLetterTableViewController: UITableViewController {
    private let service = CoverLetterService()

    weak var selectionDelegate: CoverLetterSelectionDelegate?
    weak var mainTableDelegate: CoverLetterListInteractionDelegate?
    
    private var filteredItems: [SidebarFilter: [CoverLetter]] = [:]
    private var filterOrder: [SidebarFilter] = []
    private var activeFilter: SidebarFilter = .all
    
    init() {
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
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroundBlue
        clearsSelectionOnViewWillAppear = false
    }
        
    func configure(items: [CoverLetter], filter: SidebarFilter) {
        self.activeFilter = filter
        
        switch filter {
        case .all:
            let grouped = Dictionary(grouping: items, by: { $0.state })
            self.filteredItems = grouped.mapKeys { SidebarFilter.state($0) }
            self.filterOrder = CoverLetterState.allCases
                .map { SidebarFilter.state($0) }
                .filter { filteredItems[$0]?.isEmpty == false }

        case .state(let selectedState):
            let list = items.filter { $0.state == selectedState }
            let key = SidebarFilter.state(selectedState)
            self.filteredItems = [key: list]
            self.filterOrder = [key]
        }
        self.tableView.reloadData()
    }
    
    func selectAndNotifyItem(withId id: Int?, isAutoSelection: Bool) {
        guard let id, let indexPath = indexPathForItem(withId: id) else { return }
        if isAutoSelection {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
        handleSelection(at: indexPath)
    }
    
    func selectFirstIfNeeded() {
        if let first = self.indexPathForItem(withId: self.filteredItems[self.filterOrder.first ?? .all]?.first?.id ?? -1) {
            print("Will be select first")
            self.tableView.selectRow(at: first, animated: true, scrollPosition: .top)
            self.handleSelection(at: first)
        } else {
            print("Will not select first")
        }
    }

    
    private func indexPathForItem(withId id: Int) -> IndexPath? {
        for (sectionIndex, filter) in filterOrder.enumerated() {
            if let rowIndex = filteredItems[filter]?.firstIndex(where: { $0.id == id }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    func reloadRow(for id: Int) {
        guard let indexPath = indexPathForItem(withId: id) else { return }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CoverLetterTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filterOrder.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filter = filterOrder[section]
        return filteredItems[filter]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoverLetterCell.reuseIdentifier, for: indexPath) as? CoverLetterCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let filter = filterOrder[indexPath.section]
        if let item = filteredItems[filter]?[indexPath.row] {
            cell.configure(with: item)
            cell.onTapBookmarkButton = { [weak self] in
                self?.mainTableDelegate?.didTapBookmark(for: item)
            }
            cell.onDeleteCoverLetter = { [weak self] in
                self?.mainTableDelegate?.didRequestDeleteCoverLetter(for: item)
            }
        }
        
        return cell
    }
    
    /// 섹션 타이틀 주입
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .backgroundBlue

        let label = UILabel()
        label.text = filterOrder[section].title
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 18),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }
    
    /// 테이블 선택 처리
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSelection(at: indexPath)
    }
    
    private func handleSelection(at indexPath: IndexPath) {
        let filter = filterOrder[indexPath.section]
        if let item = filteredItems[filter]?[indexPath.row] {
            selectionDelegate?.didSelectCoverLetter(item)
        }
        splitViewController?.show(.secondary)
        
        // let detailVC = DetailViewController(item: selectedItem)
        // navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func itemFor(indexPath: IndexPath) -> CoverLetter {
        let filter = filterOrder[indexPath.section]
        return filteredItems[filter]![indexPath.row]
    }
}


extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }
}
