//
//  DetailSidebarView.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/23/25.
//

import UIKit

protocol SidebarViewDelegate: AnyObject {
    func sidebarView(_ view: DetailSidebarView, didChangeState state: CoverLetterState)
    func sidebarView(_ view: DetailSidebarView, didUpdateCompany company: String)
    func sidebarView(_ view: DetailSidebarView, didUpdateJob job: String)
    func sidebarView(_ view: DetailSidebarView, didUpdateMemo memo: String)
    func sidebarView(_ view: DetailSidebarView, didUpdateDueDate date: Date)
    func sidebarView(_ view: DetailSidebarView, didUpdateWhitespace bool: Bool)
}

class DetailSidebarView: UIView {
    private let segmentControl = UISegmentedControl(items: CoverLetterState.allCases.map { $0.koreanName })
    
    private let companyTextField = MemoInputView(text: "")
    private let jobTextField = MemoInputView(text: "")
    private let memoTextField = MemoInputView(text: "")
    
    private let companyLabel: UILabel = DetailSidebarView.makeLabel(text: "회사")
    private let jobLabel: UILabel = DetailSidebarView.makeLabel(text: "직무")
    private let memoLabel: UILabel = DetailSidebarView.makeLabel(text: "메모")
    private let dueDateLabel: UILabel = DetailSidebarView.makeLabel(text: "마감일")
    private let whitespaceCheckBoxLabel: UILabel = DetailSidebarView.makeLabel(text: "공백 포함", applyTransform: false)
    
    private let dueDatePickerToggleView = DatePickerToggleView()
    private let includesWhitespaceCheckBox = CheckBox()
    
    var delegate: SidebarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: CoverLetter?) {
        segmentControl.selectedSegmentIndex = CoverLetterState.allCases.firstIndex(of: item?.state ?? .unwrite) ?? 0
        companyTextField.configure(text: item?.company ?? "")
        jobTextField.configure(text: item?.jobPosition ?? "")
        memoTextField.configure(text: item?.memo ?? "")
        includesWhitespaceCheckBox.isChecked = item?.includesWhitespace ?? true
        dueDatePickerToggleView.configure(initialDate: item?.dueDate, buttonTitle: "마감일 설정")
    }
    
    private let dummySpacerView = UIView()

    private func setupLayout() {
        backgroundColor = UIColor.systemGray6
        
        let companyHStack = makeHStack(label: companyLabel, inputView: companyTextField, alignment: .top)
        let jobHStack = makeHStack(label: jobLabel, inputView: jobTextField, alignment: .firstBaseline)
        let memoHStack = makeHStack(label: memoLabel, inputView: memoTextField, alignment: .top)
        let dueDateHStack = makeHStack(label: dueDateLabel, inputView: dueDatePickerToggleView, alignment: .top)
        let whitespaceCheckBoxHStack = makeHStack(label: whitespaceCheckBoxLabel, inputView: includesWhitespaceCheckBox, alignment: .top, distribution: .equalSpacing)
       
        dummySpacerView.translatesAutoresizingMaskIntoConstraints = false
        dummySpacerView.backgroundColor = .clear
        
        dummySpacerView.setContentHuggingPriority(.defaultLow, for: .vertical) // 늘어나도 됨
        dummySpacerView.setContentCompressionResistancePriority(.required, for: .vertical) // 찌그러지지는 않음
        
        let verticalStack = UIStackView(arrangedSubviews: [
            companyHStack,
            jobHStack,
            memoHStack,
            whitespaceCheckBoxHStack,
            dueDateHStack
        ])
        verticalStack.axis = .vertical
        verticalStack.spacing = 14
        verticalStack.alignment = .fill

        [segmentControl, verticalStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12),
            segmentControl.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -12),
            
            verticalStack.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 14),
            verticalStack.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor, constant: 4),
            verticalStack.trailingAnchor.constraint(equalTo: segmentControl.trailingAnchor, constant: -4),
        ])
    }
    
    private func setupActions() {
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        companyTextField.onTextChanged = { [weak self] text in
            guard let self else { return }
            delegate?.sidebarView(self, didUpdateCompany: text)
        }
        jobTextField.onTextChanged = { [weak self] text in
            guard let self else { return }
            delegate?.sidebarView(self, didUpdateJob: text)
        }
        memoTextField.onTextChanged = { [weak self] text in
            guard let self else { return }
            delegate?.sidebarView(self, didUpdateMemo: text)
        }
        
        dueDatePickerToggleView.onDateChanged = { [weak self] date in
            guard let self else { return }
            delegate?.sidebarView(self, didUpdateDueDate: date)
        }
        
        includesWhitespaceCheckBox.addTarget(self, action: #selector(checkBoxChanged), for: .touchUpInside)
    }
    
    @objc private func segmentChanged() {
        delegate?.sidebarView(self, didChangeState: CoverLetterState.allCases[segmentControl.selectedSegmentIndex])
    }
    
    @objc private func checkBoxChanged() {
        delegate?.sidebarView(self, didUpdateWhitespace: includesWhitespaceCheckBox.isChecked)
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
    
    private func makeHStack(label: UILabel, inputView: UIView, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [label, inputView])
        stack.spacing = 12
        stack.axis = .horizontal
        stack.alignment = alignment
        stack.distribution = distribution
        return stack
    }
}

class CheckBox: UIButton {
    
    // 체크 여부 상태
    var isChecked: Bool = false {
        didSet {
            updateImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
        updateImage()
    }
    
    @objc private func toggleCheck() {
        isChecked.toggle()
    }
    
    private func updateImage() {
        let imageName = isChecked ? "checkmark.square.fill" : "square.fill"
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        setImage(UIImage(systemName: imageName, withConfiguration: imageConfig), for: .normal)
        tintColor = isChecked ? .accent : .backgroundDark
    }
}
