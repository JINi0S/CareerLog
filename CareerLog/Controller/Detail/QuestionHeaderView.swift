//
//  ContentCell.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/2/25.
//

import UIKit

final class QuestionHeaderView: UICollectionReusableView, UITextViewDelegate {
    static let reuseIdentifier = "QuestionHeaderView"
    
    var onChangeTitle: ((String) -> ())?
    var onDelete: (() -> ())?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.tintColor = .accent
        textView.font = .systemFont(ofSize: 16, weight: .semibold)
        textView.borderStyle = .none
        textView.isScrollEnabled = false
        return textView
    }()
    
    private let etcButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemGray
        button.setImage(.init(systemName: "ellipsis"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textView.delegate = self
        etcButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        etcButton.setContentHuggingPriority(.required, for: .horizontal)
        etcButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        
        // 스택 뷰 구성
        let questionHStack = UIStackView(arrangedSubviews: [textView, etcButton])
        questionHStack.axis = .horizontal
        questionHStack.alignment = .top
        questionHStack.spacing = 8
        
        // 뷰에 추가
        [questionHStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            questionHStack.topAnchor.constraint(equalTo: topAnchor),
            questionHStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            questionHStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            questionHStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
        ])
    }
    
    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.onChangeTitle?(textView.text)
    }
    
    func configure(with content: CoverLetterContent) {
        textView.text = content.question
    }
    
    @objc private func showMenu() {
        let action = UIAction(title: " 자기소개서 삭제", handler: { [weak self] _ in
            self?.deleteQuestion()
        }
        )
        let tagMenu =  UIMenu(title: "", options: .displayInline, preferredElementSize: .large, children: [action])
        etcButton.menu = UIMenu(title: "", children: [tagMenu])
    }
    
    private func deleteQuestion() {
        guard let parentVC = parentViewController else { return }
        
        let alert = UIAlertController(title: "자기소개서 삭제", message: "정말 삭제하시겠습니까?\n답변도 같이 삭제됩니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            print(("DELETE"))
            self?.onDelete?()
        })
        
        parentVC.present(alert, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}
