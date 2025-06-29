//
//  DetailCollectionViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/23/25.
//


import UIKit

final class DetailCollectionViewController: UICollectionViewController {
    
    var item: CoverLetter?
    var onItemChanged: ((CoverLetter) -> Void)?
    var tagOptions =  ["성장배경", "강약점", "강점", "높은목표설정"] // TODO: 저장 및 불러오기 기능
    private let toggleButton = UIButton(type: .system)

    private var numberOfColumns = 1 {
        didSet {
            collectionView.collectionViewLayout = Self.createLayout(numberOfColumns: numberOfColumns)
            updateToggleButtonTitle()
        }
    }
    
    init(item: CoverLetter?) {
        self.item = item
        let layout = DetailCollectionViewController.createLayout(numberOfColumns: 1)
        super.init(collectionViewLayout: layout)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupToggleButton()
        collectionView.backgroundColor = .systemBackground
        collectionView.register(AnswerCell.self, forCellWithReuseIdentifier: AnswerCell.reuseIdentifier)
        collectionView.register(QuestionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: QuestionHeaderView.reuseIdentifier)
        collectionView.register(QuestionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: QuestionFooterView.reuseIdentifier)
        
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = Self.createLayout(numberOfColumns: numberOfColumns)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func reload(with item: CoverLetter) {
        self.item = item
        collectionView.reloadData()
        onItemChanged?(item)
    }
 
    private func setupToggleButton() {
        updateToggleButtonTitle()
        toggleButton.addTarget(self, action: #selector(toggleLayout), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleButton)
        
        NSLayoutConstraint.activate([
            toggleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            toggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            toggleButton.heightAnchor.constraint(equalToConstant: 32),
            toggleButton.widthAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func updateToggleButtonTitle() {
        let imageName = (numberOfColumns == 1) ? "rectangle.grid.1x2" : "rectangle.grid.2x2"
        let image = UIImage(systemName: imageName)
        toggleButton.setImage(image, for: .normal)
    }
    
    @objc private func toggleLayout() {
        numberOfColumns = (numberOfColumns == 1) ? 2 : 1
    }
    
    private func presentTagEditView() {
        let editVC = TagEditViewController()
        editVC.options = self.tagOptions
        editVC.onUpdate = { [weak self] newOptions in
            self?.tagOptions = newOptions
            self?.collectionView?.reloadData()
        }
        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
    }
    
    private func presentAddOptionAlert() {
        let alert = UIAlertController(title: "태그 선택지 추가", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "예: 성장배경" }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "추가", style: .default, handler: { [weak self] _ in
            guard let self,
                  let newOption = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces),
                  !newOption.isEmpty else { return }
            
            if !tagOptions.contains(newOption) {
                tagOptions.append(newOption)
                self.collectionView?.reloadData()
            }
        }))
        present(alert, animated: true)
    }
    
    static func createLayout(numberOfColumns: Int) -> UICollectionViewLayout {
        let spacing: CGFloat = 8
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(numberOfColumns)),
                                              heightDimension: .estimated(100))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let items = Array(repeating: item, count: numberOfColumns)

        let groupWidth = NSCollectionLayoutDimension.fractionalWidth(1.0)
        let groupHeight = NSCollectionLayoutDimension.estimated(100)
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: groupHeight)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top),
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(36)),
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom)
        ]
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - UICollectionView 프로토콜
extension DetailCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        item?.contents.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        item?.contents[section].answers.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnswerCell.reuseIdentifier, for: indexPath) as! AnswerCell
        if let answer = item?.contents[indexPath.section].answers[indexPath.item] {
            cell.configure(with: answer)
        }
        cell.onTextChanged = { [weak self] newText in
            self?.item?.contents[indexPath.section].answers[indexPath.item] = newText
        }
        
        cell.onCopy = { text in
            UIPasteboard.general.string = text
        }
        
        cell.onDelete = { [weak self] in
            self?.item?.contents[indexPath.section].answers.remove(at: indexPath.item)
            self?.collectionView?.reloadData()
        }
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: QuestionHeaderView.reuseIdentifier, for: indexPath) as! QuestionHeaderView
            guard let content = item?.contents[indexPath.section] else { return header }
            
            header.configure(with: content)
            header.onChangeTitle = { [weak self] question in
                self?.item?.contents[indexPath.section].question = question
            }
            header.onDelete = { [weak self] in
                if self?.item?.contents.count ?? 0 > 1 {
                    self?.item?.contents.remove(at: indexPath.section)
                    self?.collectionView?.reloadData()
                }
                // TODO: 1개인 경우는 삭제 안된다고 알럿 띄우기 or 1개인 경우에는 버튼 없애기
            }
            return header
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: QuestionFooterView.reuseIdentifier, for: indexPath) as! QuestionFooterView
            guard let content = item?.contents[indexPath.section] else { return footer }
            
            footer.configure(with: content, tagOptions: tagOptions)
            footer.onTapAddButton = { [weak self] in
                guard let self = self else { return }
                guard var content = self.item?.contents[indexPath.section] else { return }

                // 데이터 모델에 먼저 추가
                content.answers.append("")
                self.item?.contents[indexPath.section] = content

                // 추가된 아이템 인덱스 계산
                let newItemIndex = content.answers.count - 1
                let newIndexPath = IndexPath(item: newItemIndex, section: indexPath.section)

                // 컬렉션뷰에 삽입
                self.collectionView?.insertItems(at: [newIndexPath])
            }
            footer.onTapEditTag = { [weak self] in
                self?.presentTagEditView()
            }
            footer.onTapAddTag = { [weak self] in
                self?.presentAddOptionAlert()
            }
            footer.onTagChanged = { [weak self] selectedTag in
                self?.item?.contents[indexPath.section].tag = selectedTag
                self?.onItemChanged?(self!.item!)
            }
            return footer
        }
        
        return UICollectionReusableView()
    }
}

extension DetailCollectionViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    // 드래그 시작
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let answer = item?.contents[indexPath.section].answers[indexPath.item] ?? ""
        let itemProvider = NSItemProvider(object: NSString(string: answer))
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    // 드롭 가능한지 확인
    func collectionView(_ collectionView: UICollectionView, canHandle session: any UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: NSString.self)
    }
    
    // 드롭 위치 제안
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    // 실제 데이터 순서 변경
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else { return }
            
            // 같은 section 내에서만 이동 허용
            guard sourceIndexPath.section == destinationIndexPath.section else { return }
            
            collectionView.performBatchUpdates {
                // 데이터를 이동
                guard let item else { return }
                var answers = item.contents[sourceIndexPath.section].answers
                let movedAnswer = answers.remove(at: sourceIndexPath.item)
                answers.insert(movedAnswer, at: destinationIndexPath.item)
                self.item?.contents[sourceIndexPath.section].answers = answers
                
                // 셀 위치 갱신
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }
            
            // 드롭 처리
            coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
        }
    }
}
