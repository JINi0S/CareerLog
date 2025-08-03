//
//  DatePickerToggleViewController.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/24/25.
//

import UIKit

class DatePickerToggleView: UIView {
    
    private var defaultTitle = "날짜 선택"
    
    private lazy var toggleButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 4
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .trailing
        button.addTarget(self, action: #selector(togglePicker), for: .touchUpInside)
        return button
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.isHidden = true
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .inline
        picker.locale = Locale(identifier: "ko_KR")
        picker.timeZone = TimeZone(identifier: "Asia/Seoul")
        return picker
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - Initializer
   override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Configuration
    func configure(initialDate: Date? = nil,
                   minimumDate: Date? = nil,
                   maximumDate: Date? = nil,
                   buttonTitle: String) {
        defaultTitle = buttonTitle
        updateTitle(with: initialDate)
        datePicker.date = initialDate ?? Date()
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
    }
    
    /// 외부에서 날짜 갱신 요청 시 사용
    func updateDate(_ date: Date) {
        datePicker.date = date
        updateTitle(with: date)
    }
    
    /// 외부에서 텍스트만 갱신하고 싶을 때
    func updateTitle(with date: Date?) {
        let title = date.map { dateFormatter.string(from: $0) } ?? defaultTitle
        updateToggleButtonStyle(isSelected: toggleButton.isSelected, title: title)
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(toggleButton)
        addSubview(datePicker)
        
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toggleButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            toggleButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor),

            datePicker.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: toggleButton.trailingAnchor, constant: -8),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func togglePicker() {
        toggleButton.isSelected.toggle()
        UIView.animate(withDuration: 0.3) {
            self.datePicker.isHidden.toggle()
        }
        updateChevronIcon()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formattedDate = dateFormatter.string(from: sender.date)
        onDateChanged?(sender.date)
        togglePicker()
        updateToggleButtonStyle(isSelected: toggleButton.isSelected, title: formattedDate)
    }

    // MARK: - Style Update
    private func updateToggleButtonStyle(isSelected: Bool, title: String) {
        let isHighlight = isSelected || (title == defaultTitle)
        var config = toggleButton.configuration ?? UIButton.Configuration.plain()
        var attributed = AttributedString(title)
        attributed.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        attributed.foregroundColor = isHighlight ? .accent : .secondaryLabel
        config.baseForegroundColor = isHighlight ? .accent : .secondaryLabel
        config.baseBackgroundColor = .clear
        config.attributedTitle = attributed
        toggleButton.configuration = config
        updateChevronIcon()
    }
    
    /// 버튼 상태에 따라 아이콘만 다시 설정하는 함수
    private func updateChevronIcon() {
        var config = toggleButton.configuration
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        config?.image = UIImage(systemName: toggleButton.isSelected ? "chevron.up" : "chevron.down", withConfiguration: imageConfig)
        toggleButton.configuration = config
    }
}
