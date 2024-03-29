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
    
    enum OSButtonState {
        
        case normal
        
        case loading
        
        case disabled
    }
    
    var buttonState: OSButtonState {
        didSet {
            switch buttonState {
            case .normal:
                toggleLoading(false)
                toggleDisabled(false)
            case .loading:
                toggleLoading(true)
                toggleDisabled(false)
            case .disabled:
                toggleLoading(false)
                toggleDisabled(true)
            }
        }
    }
    
    private let type: OSButtonType
    
    init(_ title: String, type: OSButtonType, state: OSButtonState = .normal) {
        self.type = type
        self.buttonState = state
        super.init(frame: .zero)
        switch type {
        case .primary:
            backgroundColor = UIColor.OS.Button.primary
            setTitleColor(UIColor.OS.Button.primaryForeground, for: .normal)
            tintColor = UIColor.OS.Button.primaryForeground
        case .secondary:
            backgroundColor = UIColor.OS.Button.primaryInverted
            setTitleColor(UIColor.OS.Button.secondary, for: .normal)
            layer.borderColor = UIColor.OS.General.main.cgColor
            layer.borderWidth = 1.8
        case .primaryInverted:
            backgroundColor = UIColor.OS.Button.primaryInverted
            setTitleColor(UIColor.OS.Button.primaryInvertedForeground, for: .normal)
            tintColor = UIColor.OS.Button.primaryInvertedForeground
        case .secondaryInverted:
            backgroundColor = UIColor.OS.Button.secondaryInverted
            setTitleColor(UIColor.OS.Button.secondaryInvertedForeground, for: .normal)
            layer.borderColor = UIColor.OS.Button.secondaryInvertedForeground.cgColor
            layer.borderWidth = 1.8
        }
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
    
    private func toggleDisabled(_ disabled: Bool) {
        isUserInteractionEnabled = !disabled
        alpha = disabled ? 0.5 : 1
    }
}
