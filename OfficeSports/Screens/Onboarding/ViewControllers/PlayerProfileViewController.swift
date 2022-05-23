//
//  NicknameViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

private let nicknameMinLength = 3
private let nicknameMaxLength = 20

final class PlayerProfileViewController: UIViewController {
    
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
        let field = CompoundField(UIColor.OS.General.mainDark, buttonColor: .white, alignment: .left)
        field.setButtonTitle("🙃")
        field.delegate = self
        return field
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton.createButton(.white, UIColor.OS.General.main, title: "Continue")
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var selectedEmoji: String = "🙃" {
        didSet {
            nicknameField.setButtonTitle(selectedEmoji)
        }
    }
    
    private var viewModel: PlayerProfileViewModel
    
    init(viewModel: PlayerProfileViewModel) {
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
        view.addSubview(continueButton)
        
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
            nicknameField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            continueButton.leftAnchor.constraint(equalTo: nicknameField.leftAnchor),
            continueButton.rightAnchor.constraint(equalTo: nicknameField.rightAnchor),
            continueButton.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 16),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    @objc private func continueButtonTapped(_ sender: UIButton) {
        do {
            let nickname = try processAndValidateNickname(nicknameField.text)
            viewModel.registerProfileDetails(nickname: nickname, emoji: selectedEmoji)
        } catch let error {
            Coordinator.global.showMessage(OSMessage(error.localizedDescription, .failure))
        }
    }
}

// MARK: - Text Field Delegate

extension PlayerProfileViewController: CompoundFieldDelegate {
    
    func buttonTapped(_ text: String?) {
        let viewController = EmojiPickerViewController(viewModel: EmojiViewModel())
        present(viewController, animated: true)
    }
}

// MARK: - Nickname View Model Delegate Conformance

extension PlayerProfileViewController: PlayerProfileViewModelDelegate {
    
    func detailsUpdatedSuccessfully() {
        Coordinator.global.changeAppState(.authorized)
    }
    
    func detailsUpdateFailed(with error: Error) {
        Coordinator.global.showMessage(OSMessage(error.localizedDescription, .failure))
    }
    
    func shouldToggleLoading(enabled: Bool) {
        continueButton.toggleLoading(enabled)
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
