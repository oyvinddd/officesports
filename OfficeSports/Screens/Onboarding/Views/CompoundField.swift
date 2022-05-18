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
    
    private lazy var textField: UITextField = {
        let textField = UITextField.createTextField(.clear)
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.textColor = UIColor.OS.Text.normal
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var button: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "arrow.right", withConfiguration: config)
        let button = UIButton.createButton(.white, UIColor.OS.General.main, title: nil)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
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
    
    weak var delegate: CompoundFieldDelegate?
    
    init(_ backgroundColor: UIColor, delegate: CompoundFieldDelegate? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = backgroundColor
        self.delegate = delegate
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
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(textField.text)
    }
}
