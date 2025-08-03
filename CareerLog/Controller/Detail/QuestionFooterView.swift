//
//  QuestionFooterView.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/27/25.
//

import UIKit

final class QuestionFooterView: UICollectionReusableView {
    // MARK: - Constants
    private enum Constants {
        static let addAnswerTitle = "답변 추가"
        static let charLimitPlaceholder = "제한 글자 수"
        static let charLimitSuffix = "자 제한"
        static let tagSelectTitle = "질문 태그 선택"
        static let editTag = "태그 편집"
        static let addTag = "태그 추가"
        static let manage = "관리"
    }
    
    private enum Layout {
        static let horizontalSpacing: CGFloat = 8
        static let topInset: CGFloat = 12
        static let bottomInset: CGFloat = 32
    }
    
    // MARK: - Static Properties
    static let reuseIdentifier = "QuestionFooterView"
    
    // MARK: - Public Properties
    var onTapAddButton: (() -> Void)?
    var onTapEditTag: (() -> Void)?
    var onTapAddTag: (() -> Void)?
    var onTagChanged: ((Int, Bool) -> Void)?
    var onCharLimitChanged: ((Int?) -> Void)?
    
    // MARK: - Private Properties
    private var tagOptions: [CoverLetterTag] = []
    private var selectedTagIds: Set<Int> = []

    // MARK: - UI Components
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
        textField.placeholder = Constants.charLimitPlaceholder
        textField.tintColor = .accent
        textField.font = .systemFont(ofSize: 13, weight: .semibold)
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        return textField
    }()
    
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
        config.baseForegroundColor = .accent
        
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .trailing
        button.setTitle(Constants.tagSelectTitle, for: .normal)
        button.showsMenuAsPrimaryAction = true
        
        button.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.baseForegroundColor =  button.title(for: .normal) == Constants.tagSelectTitle ? .accent : .label
            config?.baseBackgroundColor = .clear
            button.configuration = config
        }
        
        let image = UIImage(
            systemName: "chevron.up.chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        addAnswerButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        countLimitTextField.addTarget(self, action: #selector(didEndEditingCountLimit), for: .editingDidEnd)
        countLimitTextField.addTarget(self, action: #selector(didBeginEditingCountLimit), for: .editingDidBegin)
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let limitHStack = UIStackView(arrangedSubviews: [addAnswerButton, spacer, countLimitTextField, tagButton])
        limitHStack.axis = .horizontal
        limitHStack.spacing = Layout.horizontalSpacing
        limitHStack.distribution = .fill
        limitHStack.alignment = .center
        limitHStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(limitHStack)
        
        NSLayoutConstraint.activate([
            limitHStack.topAnchor.constraint(equalTo: topAnchor, constant: Layout.topInset),
            limitHStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Layout.bottomInset),
            limitHStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            limitHStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    // MARK: - Configure
    func configure(with content: CoverLetterContent, tagOptions: [CoverLetterTag]) {
        self.tagOptions = tagOptions
        self.selectedTagIds = Set(content.tag.map({ $0.id }))
        configureCountLimit(with: content.characterLimit)
        updateMenu()
    }
    
    private func configureCountLimit(with characterLimit: Int?) {
        if let characterLimit {
            countLimitTextField.text = "\(characterLimit)\(Constants.charLimitSuffix)"
            countLimitTextField.textColor = .label
        } else {
            countLimitTextField.text = Constants.charLimitPlaceholder
            countLimitTextField.textColor = .accent
        }
    }
    
    private func updateMenu() {
        let tagActions = tagOptions.map { tag in
            let isSelected = selectedTagIds.contains(tag.id)
            return UIAction(
                title: tag.name,
                state: isSelected ? .on : .off,
                handler: { [weak self] _ in
                    guard let self else { return }
                    
                    if isSelected {
                        selectedTagIds.remove(tag.id)
                        onTagChanged?(tag.id, false)
                    } else {
                        selectedTagIds.insert(tag.id)
                        onTagChanged?(tag.id, true)
                    }
                    
                    updateMenu() // 갱신 필요
                }
            )
        }
        
        let tagMenu = UIMenu(
            title: Constants.tagSelectTitle,
            options: [.displayInline, /*.singleSelection*/],
            preferredElementSize: .large,
            children: tagActions
        )
        
        let manageMenu = UIMenu(title: Constants.manage, children: makeManageTagActions())
        tagButton.menu = UIMenu(title: "", children: [tagMenu, manageMenu])
        
        updateTagButtonTitle()
    }
    
    private func updateTagButtonTitle() {
        let selectedNames = tagOptions
            .filter { selectedTagIds.contains($0.id) }
            .map { $0.name }
            .joined(separator: ", ")
        
        let title = selectedNames.isEmpty ? Constants.tagSelectTitle : selectedNames
        tagButton.setTitle(title, for: .normal)
        tagButton.setNeedsUpdateConfiguration()
    }
    
    private func makeManageTagActions() -> [UIAction] {
        let editAction = UIAction(title: Constants.editTag, image: UIImage(systemName: "slider.horizontal.3"), attributes: [], handler: { [weak self] _ in
            guard let self else { return }
            self.onTapEditTag?()
        })
        let addAction = UIAction(title: Constants.addTag, image: UIImage(systemName: "plus"), handler: { [weak self] _ in
            self?.onTapAddTag?()
        })
        let items = [editAction, addAction]
        return items
    }
    
    // MARK: - Action Handlers
    @objc private func didTapAddButton() {
        onTapAddButton?()
    }
    
    @objc private func didBeginEditingCountLimit(_ sender: UITextField) {
        countLimitTextField.text = extractNumber(from: countLimitTextField.text)
    }
    
    @objc private func didEndEditingCountLimit(_ sender: UITextField) {
        let numberText = extractNumber(from: countLimitTextField.text)
        countLimitTextField.textColor = numberText.isEmpty ? .accent : .label
        countLimitTextField.text = numberText.isEmpty ? Constants.charLimitPlaceholder : "\(numberText)\(Constants.charLimitSuffix)"
        self.onCharLimitChanged?(Int(numberText))
    }
    
    // MARK: - Utility
    private func extractNumber(from text: String?) -> String {
        return text?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) ?? ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
