//
//  SidebarViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/20/25.
//

import UIKit


// MARK: - Protocol
protocol SidebarSelectionDelegate: AnyObject {
    func didSelectState(_ state: CoverLetterState?)
}

class SidebarViewController: UITableViewController {
    weak var delegate: SidebarSelectionDelegate?
    
    var states: [CoverLetterState?] = [nil] + CoverLetterState.allCases // "전체 보기"를 포함한 상태 배열
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tintColor = .systemGray3
        
        // 초기 선택 상태 설정
        let defaultIndexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: defaultIndexPath, animated: false, scrollPosition: .none)
        
        // delegate 호출
        let selectedState = states[defaultIndexPath.row]
        delegate?.didSelectState(selectedState)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = states[indexPath.row]?.koreanName ?? "전체"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.backgroundColor = .clear
        cell.selectionStyle = .gray
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedState = states[indexPath.row]
        delegate?.didSelectState(selectedState)
    }
}
