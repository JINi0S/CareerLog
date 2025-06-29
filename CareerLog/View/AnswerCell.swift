//
//  AnswerCell.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/13/25.
//


import UIKit

final class AnswerCell: UICollectionViewCell {
    static let reuseIdentifier = "AnswerCell"
    
    private let textView = UITextView()
    private let copyButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let countLabel = UILabel()
    
    var onTextChanged: ((String) -> Void)?
    var onDelete: (() -> Void)?
    var onCopy: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        setupTextView()
        setupButtons()
        setupStackViews()
        setupConstraints()
    }
    
    private func setupTextView() {
        textView.delegate = self
        textView.font = .systemFont(ofSize: 15)
        textView.isScrollEnabled = false
        textView.textAlignment = .left
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
    }
    
    private func setupButtons() {
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)
        
        let copyImage = UIImage(systemName: "doc.on.doc", withConfiguration: config)
        copyButton.setImage(copyImage, for: .normal)
        copyButton.tintColor = .systemGray
        copyButton.backgroundColor = .systemGray3.withAlphaComponent(0.14)
        copyButton.layer.cornerRadius = 6
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        copyButton.translatesAutoresizingMaskIntoConstraints = false

        let deleteImage = UIImage(systemName: "trash", withConfiguration: config)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.tintColor = .red
        deleteButton.backgroundColor = .red.withAlphaComponent(0.1)
        deleteButton.layer.cornerRadius = 6
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let vStack = UIStackView()
    let buttonHStack = UIStackView()
    private func setupStackViews() {
        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = .gray
        countLabel.textAlignment = .left
        
        buttonHStack.addArrangedSubview(copyButton)
        buttonHStack.addArrangedSubview(deleteButton)
        buttonHStack.axis = .horizontal
        buttonHStack.distribution = .equalSpacing
        
        let hStack = UIStackView(arrangedSubviews: [countLabel, buttonHStack])
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        
        vStack.addArrangedSubview(textView)
        vStack.addArrangedSubview(hStack)
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.backgroundColor = .systemGray6.withAlphaComponent(0.6)
        vStack.layer.cornerRadius = 8
        
        vStack.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        vStack.isLayoutMarginsRelativeArrangement = true
        
        contentView.addSubview(vStack)
    }
    
    private func setupConstraints() {
        let buttonSize = 32.0
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            copyButton.widthAnchor.constraint(equalToConstant: buttonSize),
            copyButton.heightAnchor.constraint(equalToConstant: buttonSize),
            deleteButton.widthAnchor.constraint(equalToConstant: buttonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: buttonSize),
            
            buttonHStack.widthAnchor.constraint(equalToConstant: 72)
        ])
    }
    
    func configure(with text: String) {
        textView.text = text
        updateCount()
    }
    
    private func updateCount() {
        let text = textView.text ?? ""
        countLabel.text = "공백 포함: \(text.count)   |   제외: \(text.filter { !$0.isWhitespace }.count)"
    }
    
    @objc private func deleteButtonTapped() {
        onDelete?()
    }
    
    // TODO: 토스트메시지
    @objc private func copyButtonTapped() {
        onCopy?(textView.text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AnswerCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateCount()
        onTextChanged?(textView.text)
        
        // 셀 높이 갱신 유도
        if let collectionView = self.superview as? UICollectionView {
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates(nil)
            }
        }
    }
}
