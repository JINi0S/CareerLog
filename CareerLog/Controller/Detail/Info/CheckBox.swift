//
//  CheckBox.swift
//  CareerLog
//
//  Created by Lee Jinhee on 7/28/25.
//

import UIKit

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
