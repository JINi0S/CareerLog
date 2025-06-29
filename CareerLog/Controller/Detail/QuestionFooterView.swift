//
//  QuestionFooterView.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/27/25.
//

import UIKit

final class QuestionFooterView: UICollectionReusableView {
    private enum Constants {
        static let addAnswerTitle = "답변 추가"
        static let charLimitSuffix = "자 제한"
        static let tagSelectTitle = "질문 태그 선택"
        static let manage = "관리"
        static let editTag = "태그 편집"
    }
    
    static let reuseIdentifier = "QuestionFooterView"
    
    var onTapAddButton: (() -> Void)?
    var onTapEditTag: (() -> Void)?
    var onTapAddTag: (() -> Void)?
    var onTagChanged: ((String) -> Void)?
    
    private var tagOptions: [String] = []

    private let addAnswerButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = Constants.addAnswerTitle
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let addImage = UIImage(systemName: "plus", withConfiguration: imageConfig)
        config.image = addImage
        config.imagePadding = 4 // 이미지-텍스트 간격
        config.baseForegroundColor = .accent
        config.titleAlignment = .leading
        config.titleTextAttributesTransformer = .init { container in
            var container = container
            container.font = .systemFont(ofSize: 13, weight: .semibold)
            return container
        }
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading
        button.backgroundColor = .accent.withAlphaComponent(0.12)
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    private let countLimitTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "글자수 제한"
        textField.tintColor = .accent
        textField.font = .systemFont(ofSize: 13, weight: .semibold)
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        return textField
    }()
    
    // TODO: 초기값 설정
    private let tagButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 6
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var newAttributes = incoming
            newAttributes.font = .systemFont(ofSize: 13, weight: .semibold)
            return newAttributes
        }
        
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .trailing
        button.setTitle(Constants.tagSelectTitle, for: .normal)
        button.setTitleColor(.accent, for: .normal)
        let image = UIImage(
            systemName: "chevron.up.chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        button.setImage(image, for: .normal)
        
        button.showsMenuAsPrimaryAction = true
        return button
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAnswerButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        countLimitTextField.addTarget(self, action: #selector(onEndEditingCountLimit), for: .editingDidEnd)
        countLimitTextField.addTarget(self, action: #selector(onBeginCountLimit), for: .editingDidBegin)
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let limitHStack = UIStackView(arrangedSubviews: [addAnswerButton, spacer, countLimitTextField, tagButton])
        limitHStack.axis = .horizontal
        limitHStack.spacing = 8
        limitHStack.distribution = .fill
        limitHStack.alignment = .center
       
        limitHStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(limitHStack)

        NSLayoutConstraint.activate([
            limitHStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            limitHStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            limitHStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            limitHStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with content: CoverLetterContent, tagOptions: [String]) {
        self.tagOptions = tagOptions
        if content.tag != "" {
            tagButton.setTitle(content.tag, for: .normal)
            tagButton.setTitleColor(.label, for: .normal)
            tagButton.tintColor = .label
        }
        
        countLimitTextField.text = "\(content.characterLimit)자 제한"
        updateMenu()
    }
    
    @objc private func didTapAddButton() {
        onTapAddButton?()
    }
    
    private func updateMenu() {
        var actions: [UIAction] = []
        for option in tagOptions {
            let isSelected = (option == tagButton.title(for: .normal))
            let action = UIAction(
                title: option,
                state: isSelected ? .on : .off,
                handler: { [weak self] _ in
                    self?.tagButton.setTitle(option, for: .normal)
                    self?.tagButton.setTitleColor(.label, for: .normal)
                    self?.tagButton.tintColor = .label
                    self?.onTagChanged?(option) // ✅ 여기서 변경 감지
                }
            )
            actions.append(action)
        }

        let tagMenu =  UIMenu(title: Constants.tagSelectTitle, options: .displayInline, preferredElementSize: .large, children: actions)
        let manageMenu = UIMenu(title: Constants.manage, options: .displayInline, preferredElementSize: .large, children:  makeManageTagActions())
        tagButton.menu = UIMenu(title: "", children: [tagMenu, manageMenu])
    }
    
    private func makeManageTagActions() -> [UIAction] {
        let editAction = UIAction(title: Constants.editTag, image: UIImage(systemName: "slider.horizontal.3"), attributes: [], handler: { [weak self] _ in
            guard let self else { return }
            self.onTapEditTag?()
        })
        let addAction = UIAction(title: "태그 추가", image: UIImage(systemName: "plus"), handler: { [weak self] _ in
            self?.onTapAddTag?()
        })
        let items = [editAction, addAction]
        return items
    }

    @objc private func onBeginCountLimit(_ sender: UITextField) {
        let numberText = extractNumber(from: countLimitTextField.text)
        countLimitTextField.text = numberText
    }
    
    @objc private func onEndEditingCountLimit(_ sender: UITextField) {
        let numberText = extractNumber(from: countLimitTextField.text)
        countLimitTextField.text = numberText.isEmpty ? "" : "\(numberText)자 제한"
    }
    
    private func extractNumber(from text: String?) -> String {
        return text?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) ?? ""
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
