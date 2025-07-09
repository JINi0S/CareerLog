//
//  CoverLetterCell.swift
//  CareerLog
//
//  Created by Lee Jinhee on 6/21/25.
//


import UIKit

class CoverLetterCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    static let reuseIdentifier = "CoverLetterCell"
    
    private let containerView = UIView()
    let stateIconView = FixedImageContainerView(
        imageName: "checkmark.circle.fill",
        tintColor: .systemBlue,
        pointSize: 16,
        fixedSize: CGSize(width: 36, height: 36)
    )
    private let titleLabel = UILabel()
    
    private let companyLabel = UILabel()
    private let jobPositionLabel = UILabel()
    private let separatorLabel = UILabel()
    
    private let tagListView = TagListView()
    private let dueDateLabel = UILabel()
    private let bookmarkButton = UIButton()
    
    private var mainContentHStack = UIStackView()
    private var infoVStackView = UIStackView()
    private var subtitleHStackView = UIStackView()

    var onTapBookmarkButton: (() -> Void)?
    var onDeleteCoverLetter: (() -> ())?
    
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
      
        let interaction = UIContextMenuInteraction(delegate: self)
        containerView.addInteraction(interaction)
    }
    
    func configure(with item: CoverLetter) {
        updateStateImage(from: item.state)
        titleLabel.text = item.title
        companyLabel.text = item.company
        jobPositionLabel.text = item.jobPosition
        separatorLabel.isHidden = item.jobPosition?.isEmpty ?? true || item.company.isEmpty
        let tags = item.contents
            .flatMap { $0.tag }
            .map { $0.name }
        tagListView.setTags(tags)
        dueDateLabel.text = item.dueDate.map { dateFormatter.string(from: $0) } ?? ""
        updateBookmarkButtonImage(item.isBookmarked)
    }
    
    private func setupUI() {
        titleLabel.numberOfLines = 0
        companyLabel.numberOfLines = 0
        jobPositionLabel.numberOfLines = 0
        dueDateLabel.numberOfLines = 0
        
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
            subtitleHStackView.addArrangedSubview($0)
        }
        subtitleHStackView.axis = .horizontal
        subtitleHStackView.spacing = 6
        subtitleHStackView.alignment = .center
        
        [titleLabel, subtitleHStackView, tagListView, dueDateLabel].forEach {
            infoVStackView.addArrangedSubview($0)
        }
        infoVStackView.axis = .vertical
        infoVStackView.spacing = 8
        infoVStackView.alignment = .leading
        infoVStackView.distribution = .fill
        infoVStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [stateIconView, infoVStackView, bookmarkButton].forEach {
            mainContentHStack.addArrangedSubview($0)
        }
        mainContentHStack.axis = .horizontal
        mainContentHStack.spacing = 16
        mainContentHStack.alignment = .leading
        mainContentHStack.distribution = .fill
        mainContentHStack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(mainContentHStack)
    }
    
    private func setupButtons() {
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bookmarkButton.widthAnchor.constraint(equalToConstant: 24),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 16.0
        [companyLabel, separatorLabel, jobPositionLabel].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        tagListView.setContentHuggingPriority(.required, for: .vertical)
        tagListView.setContentCompressionResistancePriority(.required, for: .vertical)
           
        NSLayoutConstraint.activate([
            tagListView.leadingAnchor.constraint(equalTo: infoVStackView.leadingAnchor),
            tagListView.trailingAnchor.constraint(equalTo: infoVStackView.trailingAnchor),
       
            mainContentHStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            mainContentHStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            mainContentHStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            mainContentHStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
        ])
    }
    
    // 셀 재사용 시 상태 초기화 고려
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        companyLabel.text = nil
        jobPositionLabel.text = nil
        dueDateLabel.text = nil
        updateBookmarkButtonImage(false)
        tagListView.setTags([])
    }
    
    private func updateStateImage(from state: CoverLetterState) {
        stateIconView.update(
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        UIView.animate(withDuration: 0.2) {
            self.containerView.layer.borderWidth = selected ? 1 : 0
            self.containerView.layer.borderColor = selected ? UIColor.accent.cgColor : UIColor.clear.cgColor
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if traitCollection.userInterfaceIdiom != .pad {
            updateHighlightAppearance(true)
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let delete = UIAction(title: "삭제", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.onDeleteCoverLetter?()
            }
            
            return UIMenu(title: "", children: [delete])
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?) {
        updateHighlightAppearance(false)
    }
  
    func updateHighlightAppearance(_ isHighlight: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.containerView.layer.borderWidth = isHighlight ? 1 : 0
            self.containerView.layer.borderColor = isHighlight ? UIColor.systemPink.cgColor : UIColor.clear.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
