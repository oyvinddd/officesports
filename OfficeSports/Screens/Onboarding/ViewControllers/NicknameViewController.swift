//
//  NicknameViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

final class NicknameViewController: UIViewController {

    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white)
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel.createLabel(.white)
        return label
    }()
    
    private lazy var nicknameField: UITextField = {
        let textField = UITextField.createTextField(.black)
        textField.applyCornerRadius(10)
        return textField
    }()
    
    private lazy var chooseButton: UIButton = {
        let button = UIButton.createButton(.white, UIColor.OS.General.main, title: "Choose nickname")
        button.addTarget(self, action: #selector(nicknameButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    private func setupChildViews() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(nicknameField)
        view.addSubview(chooseButton)
        
        NSLayoutConstraint.activate([
            nicknameField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            nicknameField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64),
            nicknameField.heightAnchor.constraint(equalToConstant: 50),
            nicknameField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            chooseButton.leftAnchor.constraint(equalTo: nicknameField.leftAnchor),
            chooseButton.rightAnchor.constraint(equalTo: nicknameField.rightAnchor),
            chooseButton.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 16),
            chooseButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    @objc private func nicknameButtonTapped(_ sender: UIButton) {
        
    }
}
