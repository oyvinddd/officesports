//
//  AppButton.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 26/05/2022.
//

import UIKit

final class AppButton: UIButton {
    
    private var background: UIColor
    private var selectedColor: UIColor
    
    init(_ backgroundColor: UIColor, _ color: UIColor, _ selectedColor: UIColor, _ title: String) {
        self.selectedColor = selectedColor
        self.background = backgroundColor
        super.init(frame: .zero)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.textColor = color
        self.background = backgroundColor
        self.backgroundColor = backgroundColor
        setTitleColor(color, for: .normal)
        setTitleColor(color, for: .selected)
        setTitleColor(color, for: .highlighted)
        setTitleColor(color, for: .focused)
        //tintColor = .yellow
        setTitle(title, for: .normal)
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = selectedColor
            } else {
                backgroundColor = background
            }
        }
    }
}

extension AppButton {
    
    class func main(_ title: String) -> AppButton {
        return AppButton(.white, UIColor.OS.General.main, .black, title)
    }
}
