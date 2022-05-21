//
//  NicknameViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

private let nicknameMinLength = 3
private let nicknameMaxLength = 20

final class ProfileDetailsViewController: UIViewController {
    
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
        return CompoundField(UIColor.OS.General.mainDark, delegate: self)
    }()
    
    private var viewModel: NicknameViewModel
    var selectedEmoji: String = "🙃"
    
    init(viewModel: NicknameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = nicknameField.becomeFirstResponder()
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
    
    private func processAndValidateNickname(_ nickname: String?) throws -> String {
        guard let nickname = nickname else {
            throw NicknameError.missing
        }
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedNickname = trimmedNickname.lowercased()
        
        if lowercasedNickname.count < nicknameMinLength {
            throw NicknameError.tooShort
        }
        if lowercasedNickname.count > nicknameMaxLength {
            throw NicknameError.tooLong
        }
        return lowercasedNickname
    }
}

// MARK: - Text Field Delegate

extension ProfileDetailsViewController: CompoundFieldDelegate {
    
    func buttonTapped(_ text: String?) {
        do {
            let nickname = try processAndValidateNickname(text)
            viewModel.updateProfileDetails(nickname: nickname, emoji: "😙")
        } catch let error {
            let localizedError = error.localizedDescription
            Coordinator.global.displayMessage(localizedError, type: .failure)
        }
    }
}

// MARK: - Nickname View Model Delegate Conformance

extension ProfileDetailsViewController: NicknameViewModelDelegate {
    
    func detailsUpdatedSuccessfully() {
        Coordinator.global.updateState(.authorized)
    }
    
    func detailsUpdateFailed(with error: Error) {
        Coordinator.global.displayMessage(error.localizedDescription, type: .failure)
    }
    
    func shouldToggleLoading(enabled: Bool) {
    }
}

// MARK: - Nickname Error

private enum NicknameError: LocalizedError {
    
    case missing
    
    case tooShort
    
    case tooLong
    
    var errorDescription: String? {
        switch self {
        case .missing:
            return "Nickname is missing"
        case .tooShort:
            return "Nickname is too short"
        case .tooLong:
            return "Nickname is too long"
        }
    }
}
