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
        textField.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
        return textField
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton.createButton(.white, UIColor.OS.General.main, title: "🥶")
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    weak var delegate: CompoundFieldDelegate?
    
    init(_ backgroundColor: UIColor, delegate: CompoundFieldDelegate? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = backgroundColor
        self.delegate = delegate
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(textField)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: leftAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.rightAnchor.constraint(equalTo: rightAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leftAnchor.constraint(equalTo: textField.rightAnchor),
            button.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(textField.text)
    }
}
