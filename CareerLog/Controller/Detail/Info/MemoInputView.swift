//
//  MemoInputView.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/20/25.
//

import UIKit

final class MemoInputView: UIView, UITextViewDelegate {
    let textView = UITextView()
    var onTextChanged: ((String) -> Void)?
    let container = UIStackView()

    init(text: String) {
        super.init(frame: .zero)
        setupViews()
        configure(text: text)
    }
    
    private func setupViews() {
        textView.delegate = self
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.autocapitalizationType = .none
        textView.backgroundColor = .backgroundDark
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .left
        textView.textContainerInset = .init(top: 8, left: 14, bottom: 8, right: 14)
        textView.textContainer.lineFragmentPadding = 0
        textView.layer.cornerRadius = 8
    
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(text: String) {
        textView.text = text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
  
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            
            /// 180 이하일때는 더 이상 줄어들지 않게하기
            if estimatedSize.height <= 140 {
                
            }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
