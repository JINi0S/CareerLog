//
//  CoverLetterCell.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/21/25.
//


import UIKit

class CoverLetterCell: UITableViewCell {
    
    static let reuseIdentifier = "CoverLetterCell"
    
    // 셀 안에 들어갈 UI 요소 정의
    private let containerView = UIView()
    let stateImage = FixedImageContainerView(
        imageName: "checkmark.circle.fill",
        tintColor: .systemBlue,
        pointSize: 16,
        fixedSize: CGSize(width: 36, height: 36)
    )
    private let titleLabel = UILabel()
    
    private let subtitleStackView = UIStackView()
    private let companyLabel = UILabel()
    private let jobPositionLabel = UILabel()
    private let separatorLabel = UILabel()
    
    private let tagListView = TagListView()
    private let dueDateLabel = UILabel()
    private let bookmarkButton = UIButton()
    
    private var labelHStack = UIStackView()
    private var vStack = UIStackView()
    private var hStack = UIStackView()

    var onTapBookmarkButton: (() -> Void)?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupUI() {
        setupContainerView()
        setupLabels()
        setupStacks()
        setupButtons()
        setupConstraints()
    }
    
    private func setupContainerView() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowRadius = 12
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.main.scale
                
        // 패딩 설정
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupLabels() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        companyLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        companyLabel.textColor = .systemGray
        
        jobPositionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        jobPositionLabel.textColor = .systemGray
       
        separatorLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        separatorLabel.text = "•"
        separatorLabel.textColor = .systemGray
        
        dueDateLabel.font =  UIFont.systemFont(ofSize: 13, weight: .medium)
        dueDateLabel.textColor = .systemGray
    }
    
    private func setupStacks() {
        [companyLabel, separatorLabel, jobPositionLabel].forEach {
            labelHStack.addArrangedSubview($0)
        }
        labelHStack.axis = .horizontal
        labelHStack.spacing = 6
        labelHStack.alignment = .center
        
        [companyLabel, separatorLabel, jobPositionLabel].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        [titleLabel, labelHStack, tagListView, dueDateLabel].forEach {
            vStack.addArrangedSubview($0)
        }
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.alignment = .leading
        vStack.distribution = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        vStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        vStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                
        [stateImage, vStack, bookmarkButton].forEach {
            hStack.addArrangedSubview($0)
        }
        hStack.axis = .horizontal
        hStack.spacing = 16
        hStack.alignment = .leading
        hStack.distribution = .fill
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(hStack)
    }
    
    private func setupButtons() {
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20.0
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            hStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            hStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            hStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
        ])
    }
    
    // 셀 재사용 시 상태 초기화 고려
    override func prepareForReuse() {
        super.prepareForReuse()
        updateBookmarkButtonImage(false)
        tagListView.setTags([])
    }
    
    func configure(with item: CoverLetter) {
        updateStateImage(from: item.state)
        titleLabel.text = item.title
        companyLabel.text = item.company.name
        jobPositionLabel.text = item.jobPosition
        separatorLabel.isHidden = ((item.jobPosition?.isEmpty) != nil)
        let tags = item.contents.compactMap { $0.tag }
        tagListView.setTags(tags)
        dueDateLabel.text = item.dueDate.map { dateFormatter.string(from: $0) } ?? ""
        updateBookmarkButtonImage(item.isBookmarked)
    }
    
    private func updateStateImage(from state: CoverLetterState) {
        stateImage.update(
            imageName: state.imageName,
            tintColor: state.tintColor,
            pointSize: 16
        )
    }
    
    private func updateBookmarkButtonImage(_ isBookmarked: Bool) {
        let imageName = isBookmarked ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func bookmarkButtonTapped() {
        self.onTapBookmarkButton?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class FixedImageContainerView: UIView {
    
    private let imageView: UIImageView
    private let fixedSize: CGSize
    
    init(
        imageName: String,
        tintColor: UIColor,
        pointSize: CGFloat = 15,
        fixedSize: CGSize = CGSize(width: 36, height: 36),
        backgroundColor: UIColor? = nil
    ) {
        self.fixedSize = fixedSize
        self.imageView = UIImageView()

        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: fixedSize.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: fixedSize.height).isActive = true
        
        self.backgroundColor = backgroundColor ?? tintColor.withAlphaComponent(0.2)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.tintColor = tintColor
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        imageView.image = UIImage(systemName: imageName, withConfiguration: config)
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    func update(imageName: String, tintColor: UIColor, pointSize: CGFloat = 15) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)
        imageView.image = UIImage(systemName: imageName, withConfiguration: config)
        imageView.tintColor = tintColor
        self.backgroundColor = tintColor.withAlphaComponent(0.2)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
