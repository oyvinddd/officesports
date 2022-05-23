//
//  CompoundField.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 13/05/2022.
//

import UIKit

protocol CompoundFieldDelegate: AnyObject {
    
    func buttonTapped(_ text: String?)
}

final class CompoundField: UIView {
    
    enum ButtonAlignment {
        case left, right
    }
    
    private lazy var textField: UITextField = {
        let textField = UITextField.createTextField(.clear, color: UIColor.OS.Text.normal)
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(16, 0, 0)
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var button: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "arrow.right", withConfiguration: config)
        let button = UIButton.createButton(.white, UIColor.OS.General.main, title: nil)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 26)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.OS.General.main
        button.layer.cornerRadius = 0
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.tintColor = .red
        return activityIndicator
    }()
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    var alignment: ButtonAlignment
    
    weak var delegate: CompoundFieldDelegate?
    
    init(_ backgroundColor: UIColor, buttonColor: UIColor, alignment: ButtonAlignment) {
        self.alignment = alignment
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = backgroundColor
        button.backgroundColor = buttonColor
        setupChildViews()
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textField.becomeFirstResponder()
    }
    
    func setButtonTitle(_ title: String) {
        button.setTitle(title, for: .normal)
        button.setImage(nil, for: .normal)
    }
    
    func toggleLoadingIndicator(enabled: Bool) {
        if enabled {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func setupChildViews() {
        addSubview(textField)
        addSubview(button)
        button.addSubview(activityIndicator)
        
        if alignment == .right {
        
            NSLayoutConstraint.activate([
                textField.leftAnchor.constraint(equalTo: leftAnchor),
                textField.topAnchor.constraint(equalTo: topAnchor),
                textField.bottomAnchor.constraint(equalTo: bottomAnchor),
                button.rightAnchor.constraint(equalTo: rightAnchor),
                button.topAnchor.constraint(equalTo: topAnchor),
                button.bottomAnchor.constraint(equalTo: bottomAnchor),
                button.leftAnchor.constraint(equalTo: textField.rightAnchor),
                button.widthAnchor.constraint(equalToConstant: 70),
                activityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                activityIndicator.widthAnchor.constraint(equalToConstant: 40),
                activityIndicator.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            NSLayoutConstraint.activate([
                button.leftAnchor.constraint(equalTo: leftAnchor),
                button.topAnchor.constraint(equalTo: topAnchor),
                button.bottomAnchor.constraint(equalTo: bottomAnchor),
                button.rightAnchor.constraint(equalTo: textField.leftAnchor),
                button.widthAnchor.constraint(equalToConstant: 70),
                textField.rightAnchor.constraint(equalTo: rightAnchor),
                textField.topAnchor.constraint(equalTo: topAnchor),
                textField.bottomAnchor.constraint(equalTo: bottomAnchor),
                activityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                activityIndicator.widthAnchor.constraint(equalToConstant: 40),
                activityIndicator.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(textField.text)
    }
}
