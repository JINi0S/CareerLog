//
//  DetailSidebarView.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/23/25.
//

import UIKit

protocol DetailSidebarViewDelegate: AnyObject {
    func sidebarView(_ view: DetailSidebarView, didChangeState state: CoverLetterState)
    func sidebarView(_ view: DetailSidebarView, didUpdateCompany company: String)
    func sidebarView(_ view: DetailSidebarView, didUpdateJob job: String)
    func sidebarView(_ view: DetailSidebarView, didUpdateUrl url: String)
    func sidebarView(_ view: DetailSidebarView, didUpdateMemo memo: String)
    func sidebarView(_ view: DetailSidebarView, didUpdateDueDate date: Date)
    func sidebarView(_ view: DetailSidebarView, didUpdateWhitespace bool: Bool)
    func sidebarView(_ view: DetailSidebarView, didTapUrlButton urlString: String)
}

class DetailSidebarView: UIView {
    private let stateSegmentedControl = UISegmentedControl(items: CoverLetterState.allCases.map { $0.koreanName })
    
    private let companyInputView = InputTextView()
    private let jobInputView = InputTextView()
    private let urlInputView = InputTextView()
    private let memoInputView = InputTextView()
    
    private let companyLabel: UILabel = DetailSidebarView.makeLabel(text: "회사")
    private let jobLabel: UILabel = DetailSidebarView.makeLabel(text: "직무")
    private let urlLabel: UILabel = DetailSidebarView.makeLabel(text: "사이트")
    private let memoLabel: UILabel = DetailSidebarView.makeLabel(text: "메모")
    private let dueDateLabel: UILabel = DetailSidebarView.makeLabel(text: "마감일")
    private let whitespaceCheckBoxLabel: UILabel = DetailSidebarView.makeLabel(text: "공백 포함", applyTransform: false)
    
    private let dueDatePickerToggleView = DatePickerToggleView()
    private let includesWhitespaceCheckBox = CheckBox()
    
    private let urlButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "safari"), for: .normal)
        button.tintColor = .secondaryLabel
        return button
    }()
    
    private let inputStack = UIStackView()
    private var isUpdating = false

    var delegate: DetailSidebarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: CoverLetter?) {
        isUpdating = false
        stateSegmentedControl.selectedSegmentIndex = CoverLetterState.allCases.firstIndex(of: item?.state ?? .unwrite) ?? 0
        companyInputView.configure(text: item?.company ?? "")
        jobInputView.configure(text: item?.jobPosition ?? "")
        urlInputView.configure(text: item?.applyUrl ?? "")
        memoInputView.configure(text: item?.memo ?? "")
        includesWhitespaceCheckBox.isChecked = item?.includesWhitespace ?? true
        dueDatePickerToggleView.configure(initialDate: item?.dueDate, buttonTitle: "마감일 설정")
    }
    
    func update(with item: CoverLetter?) {
        isUpdating = true
        stateSegmentedControl.selectedSegmentIndex = CoverLetterState.allCases.firstIndex(of: item?.state ?? .unwrite) ?? 0
        companyInputView.update(text: item?.company ?? "")
        jobInputView.update(text: item?.jobPosition ?? "")
        urlInputView.update(text: item?.applyUrl ?? "")
        memoInputView.update(text: item?.memo ?? "")
        includesWhitespaceCheckBox.isChecked = item?.includesWhitespace ?? true
        if let date = item?.dueDate {
            dueDatePickerToggleView.updateDate(date)
        }
        isUpdating = false
    }
    
    private func setupLayout() {
        backgroundColor = UIColor.systemGray6
        setupSegmentedControl()
        setupInputStack()
        setupConstraints()
    }
    
    private func setupSegmentedControl() {
        addSubview(stateSegmentedControl)
        stateSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupInputStack() {
        let companyHStack = makeInputRow(label: companyLabel, inputView: companyInputView, alignment: .top)
        let jobHStack = makeInputRow(label: jobLabel, inputView: jobInputView, alignment: .firstBaseline)
        let urlHStack = makeInputRow(label: urlLabel, inputView: urlInputView, alignment: .firstBaseline)
        let memoHStack = makeInputRow(label: memoLabel, inputView: memoInputView, alignment: .top)
        let dueDateHStack = makeInputRow(label: dueDateLabel, inputView: dueDatePickerToggleView, alignment: .top)
        let whitespaceCheckBoxHStack = makeInputRow(label: whitespaceCheckBoxLabel, inputView: includesWhitespaceCheckBox, alignment: .top, distribution: .equalSpacing)
        
        // Safari 버튼 삽입
        urlHStack.addSubview(urlButton)
        urlButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlButton.trailingAnchor.constraint(equalTo: urlHStack.trailingAnchor, constant: -8),
            urlButton.centerYAnchor.constraint(equalTo: urlInputView.centerYAnchor),
            urlButton.widthAnchor.constraint(equalToConstant: 20),
            urlButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // 입력 필드 세로 스택
        [companyHStack,
         jobHStack,
         urlHStack,
         memoHStack,
         whitespaceCheckBoxHStack,
         dueDateHStack
        ].forEach {
            inputStack.addArrangedSubview($0)
        }
        inputStack.axis = .vertical
        inputStack.spacing = 14
        inputStack.alignment = .fill
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stateSegmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            stateSegmentedControl.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12),
            stateSegmentedControl.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -12),
            
            inputStack.topAnchor.constraint(equalTo: stateSegmentedControl.bottomAnchor, constant: 14),
            inputStack.leadingAnchor.constraint(equalTo: stateSegmentedControl.leadingAnchor, constant: 4),
            inputStack.trailingAnchor.constraint(equalTo: stateSegmentedControl.trailingAnchor, constant: -4)
        ])
    }
    
    private func setupActions() {
        stateSegmentedControl.addTarget(self, action: #selector(stateSegmentChanged), for: .valueChanged)
        urlButton.addTarget(self, action: #selector(urlButtonTapped), for: .touchUpInside)
        includesWhitespaceCheckBox.addTarget(self, action: #selector(whitespaceCheckBoxTapped), for: .touchUpInside)
        
        companyInputView.onTextChanged = { [weak self] text in
            guard let self, !self.isUpdating else { return }
            delegate?.sidebarView(self, didUpdateCompany: text)
        }
        jobInputView.onTextChanged = { [weak self] text in
            guard let self, !self.isUpdating else { return }
            delegate?.sidebarView(self, didUpdateJob: text)
        }
        urlInputView.onTextChanged = { [weak self] text in
            guard let self, !self.isUpdating else { return }
            delegate?.sidebarView(self, didUpdateUrl: text)
        }
        memoInputView.onTextChanged = { [weak self] text in
            guard let self, !self.isUpdating else { return }
            delegate?.sidebarView(self, didUpdateMemo: text)
        }
        dueDatePickerToggleView.onDateChanged = { [weak self] date in
            guard let self else { return }
            delegate?.sidebarView(self, didUpdateDueDate: date)
        }
    }
    
    @objc private func stateSegmentChanged() {
        delegate?.sidebarView(self, didChangeState: CoverLetterState.allCases[stateSegmentedControl.selectedSegmentIndex])
    }
    
    @objc private func whitespaceCheckBoxTapped() {
        delegate?.sidebarView(self, didUpdateWhitespace: includesWhitespaceCheckBox.isChecked)
    }
    
    @objc private func urlButtonTapped() {
        delegate?.sidebarView(self, didTapUrlButton: urlInputView.textView.text)
    }
    
    // MARK: - Helper UI Methods
    
    private static func makeLabel(text: String, applyTransform: Bool = true) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        if applyTransform {
            label.transform = CGAffineTransform(translationX: 0, y: 6)
        }
        
        return label
    }
    
    private func makeInputRow(label: UILabel, inputView: UIView, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [label, inputView])
        stack.spacing = 12
        stack.axis = .horizontal
        stack.alignment = alignment
        stack.distribution = distribution
        return stack
    }
}
