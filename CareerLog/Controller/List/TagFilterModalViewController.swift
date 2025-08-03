//
//  TagFilterBottomSheetViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/27/25.
//

import UIKit

class TagFilterModalViewController: UIViewController {
    var tags: [String] = []
    var selectedTags: Set<String> = []
    var onApplySelection: ((Set<String>) -> Void)?
    
    private let collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("적용", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGesture()
    }
    
    func configure(tags: [String], selectedTags: Set<String>) {
        self.tags = tags
        self.selectedTags = selectedTags
    }
    
    private func setupUI() {
        setupHierarchy()
        setupConstraints()
        setupStyles()
        addTargets()
    }
    
    private func setupHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(applyButton)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupStyles() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagOptionCell.self, forCellWithReuseIdentifier: TagOptionCell.reuseIdentifier)
        collectionView.allowsSelection = false
        // collectionView.allowsMultipleSelection = true
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    private func addTargets() {
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point),
              let cell = collectionView.cellForItem(at: indexPath) as? TagOptionCell else {
            return
        }
        
        let tag = tags[indexPath.item]
        
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
            cell.setSelected(false)
        } else {
            selectedTags.insert(tag)
            cell.setSelected(true)
        }
        
        print("현재 선택된 태그: \(selectedTags)")
    }
    
    @objc private func applyTapped() {
        onApplySelection?(selectedTags)
        dismiss(animated: true)
    }
}

extension TagFilterModalViewController:  UICollectionViewDelegate, UICollectionViewDataSource  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagOptionCell.reuseIdentifier, for: indexPath) as? TagOptionCell else {
            return UICollectionViewCell()
        }
        
        let tag = tags[indexPath.item]
        let isSelected = selectedTags.contains(tag)
        cell.configure(tag: tag, isSelected: isSelected)
        
        return cell
    }
}

extension TagFilterModalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = tags[indexPath.item]
        let padding: CGFloat = 24 // 좌우 패딩 + 내부 마진
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let tagWidth = (tag as NSString).size(withAttributes: [.font: font]).width + padding
        return CGSize(width: tagWidth, height: 32)
    }
}


class TagOptionCell: UICollectionViewCell {
    static let reuseIdentifier = "TagOptionCell"
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configure(tag: String, isSelected: Bool) {
        label.text = tag
        setSelected(isSelected)
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        updateAppearance()
    }
    
    private func updateAppearance() {
        contentView.backgroundColor = isSelected ? UIColor.systemGray5 : UIColor.systemGray6
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = isSelected ? UIColor.systemGray.cgColor : UIColor.systemGray4.cgColor
        label.textColor = isSelected ? .label : .secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
