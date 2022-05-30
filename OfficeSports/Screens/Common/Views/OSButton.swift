//
//  OSButton.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 26/05/2022.
//

import UIKit

final class OSButton: UIButton {
    
    enum OSButtonType {
        
        case primary
        
        case secondary
        
        case primaryInverted
        
        case secondaryInverted
    }
    
    var showLoading: Bool = false {
        didSet {
            toggleLoading(showLoading)
        }
    }
    
    private let type: OSButtonType
    
    init(_ title: String, type: OSButtonType) {
        self.type = type
        super.init(frame: .zero)
        switch type {
        case .primary:
            backgroundColor = UIColor.OS.Button.primary
            setTitleColor(UIColor.OS.Button.primaryForeground, for: .normal)
            tintColor = UIColor.OS.Button.primaryForeground
        case .secondary:
            backgroundColor = UIColor.OS.Button.primaryInverted
            setTitleColor(UIColor.OS.Button.secondary, for: .normal)
        case .primaryInverted:
            backgroundColor = UIColor.OS.Button.primaryInverted
            setTitleColor(UIColor.OS.Button.primaryInvertedForeground, for: .normal)
            tintColor = UIColor.OS.Button.primaryInvertedForeground
        case .secondaryInverted:
            backgroundColor = UIColor.OS.Button.secondaryInverted
            setTitleColor(UIColor.OS.Button.secondaryInvertedForeground, for: .normal)
        }
        //        setTitleColor(color, for: .normal)
        //        setTitleColor(color, for: .selected)
        //        setTitleColor(color, for: .highlighted)
        //        setTitleColor(color, for: .focused)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        titleLabel?.textColor = .black
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1
        }
    }
}
