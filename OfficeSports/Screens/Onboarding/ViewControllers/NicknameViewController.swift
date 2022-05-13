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
        label.text = "Choose your nickname"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel.createLabel(.white)
        label.text = "Choose a nickname that people can remember you by. You can also choose an emoji as a profile picture."
        return label
    }()
    
    private lazy var nicknameField: CompoundField = {
        return CompoundField(.red)
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
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: nicknameField.topAnchor, constant: -16),
            nicknameField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            nicknameField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            nicknameField.heightAnchor.constraint(equalToConstant: 50),
            nicknameField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    private func checkNicknameValidity(_ nickname: String?) throws {
        
    }
    
    @objc private func nicknameButtonTapped(_ sender: UIButton) {
        
    }
}

// MARK: - Text Field Delegate

extension NicknameViewController: CompoundFieldDelegate {
    
    func buttonTapped(_ text: String?) {
        do {
            try checkNicknameValidity(text)
            
            // TODO: update nickname in backend
            
            Coordinator.global.updateApplicationState(.authorized)
        } catch let error {
            print(error)
            // show error to user
        }
    }
}
