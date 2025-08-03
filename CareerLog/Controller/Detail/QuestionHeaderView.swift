//
//  ContentCell.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/2/25.
//

import UIKit

final class QuestionHeaderView: UICollectionReusableView {
    // MARK: - Constants
    private enum Layout {
        static let leadingMargin: CGFloat = 4
        static let trailingMargin: CGFloat = -2
        static let stackSpacing: CGFloat = 8
        static let fontSize: CGFloat = 16
    }
    
    // MARK: - Static Properties
    static let reuseIdentifier = "QuestionHeaderView"
    
    // MARK: - Public Properties
    var onChangeTitle: ((String) -> Void)?
    var onDelete: (() -> Void)?
    
    // MARK: - UI Components
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.tintColor = .accent
        textView.font = .systemFont(ofSize: Layout.fontSize, weight: .semibold)
        textView.isScrollEnabled = false
        textView.delegate = self
        return textView
    }()
    
    private lazy var etcButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemGray
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.menu = createDeleteMenu()
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func configure(with content: CoverLetterContent) {
        textView.text = content.question
    }
    
    private func setupViews() {
        let questionHStack = UIStackView(arrangedSubviews: [textView, etcButton])
        questionHStack.axis = .horizontal
        questionHStack.alignment = .top
        questionHStack.spacing = Layout.stackSpacing
        questionHStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(questionHStack)
        
        NSLayoutConstraint.activate([
            questionHStack.topAnchor.constraint(equalTo: topAnchor),
            questionHStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            questionHStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.leadingMargin),
            questionHStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.trailingMargin),
        ])
    }
    
    private func createDeleteMenu() -> UIMenu {
        let deleteAction = UIAction(
            title: "자기소개서 삭제",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.onDelete?()
        }
        
        return UIMenu(options: .displayInline, children: [deleteAction])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QuestionHeaderView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.onChangeTitle?(textView.text)
    }
}
