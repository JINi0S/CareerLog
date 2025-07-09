//
//  FixedImageContainerView.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/8/25.
//


import UIKit

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