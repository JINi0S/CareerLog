//
//  TagCell.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/19/25.
//

import UIKit

class TagCell: UICollectionViewCell {
    static let reuseIdentifier = "TagCell"
    
    private let tagLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .label
        label.backgroundColor = .systemGray5
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(tagLabel)
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with text: String) {
        tagLabel.text = text
    }
}
