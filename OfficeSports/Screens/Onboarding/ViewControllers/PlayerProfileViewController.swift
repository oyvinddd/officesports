//
//  NicknameViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

private let nicknameMinLength = 3
private let nicknameMaxLength = 20

private let profileImageDiameter: CGFloat = 110
private let profileImageRadius: CGFloat = profileImageDiameter / 2

final class PlayerProfileViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center)
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.text = "Create profile"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center)
        label.text = "Choose a nickname and an associated emoji that people can remember you by."
        return label
    }()
    
    private lazy var profileImageWrap: UIView = {
        let imageWrap = UIView.createView(.white, cornerRadius: profileImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var profileImageBackground: UIView = {
        let profileColor = UIColor.OS.hashedProfileColor("")
        let profileImageBackground = UIView.createView(profileColor)
        profileImageBackground.applyCornerRadius((profileImageDiameter - 12) / 2)
        return profileImageBackground
    }()
    
    private lazy var profileEmjoiLabel: UILabel = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileEmojiTapped))
        let label = UILabel.createLabel(.black, alignment: .center)
        label.addGestureRecognizer(tapRecognizer)
        label.font = UIFont.systemFont(ofSize: 63)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var nicknameField: UITextField = {
        let textField = UITextField.createTextField(UIColor.OS.General.mainDark, color: .white, placeholder: "Nickname")
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(16, 0, 0)
        textField.font = UIFont.boldSystemFont(ofSize: 20)
        textField.autocapitalizationType = .none
        textField.applyCornerRadius(8)
        textField.delegate = self
        return textField
    }()
    
    private lazy var continueButton: OSButton = {
        let button = OSButton("Continue", type: .primary)
        return button
    }()
    
    private let viewModel: PlayerProfileViewModel
    private var centerYConstraint: NSLayoutConstraint?
    
    var selectedEmoji: String {
        didSet {
            profileEmjoiLabel.text = selectedEmoji
        }
    }
    
    init(viewModel: PlayerProfileViewModel) {
        self.viewModel = viewModel
        self.selectedEmoji = viewModel.randomEmoji
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
        
        // Subscribe to Keyboard Will Show notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        // Subscribe to Keyboard Will Hide notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = nicknameField.becomeFirstResponder()
    }
    
    private func setupChildViews() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(profileImageWrap)
        view.addSubview(nicknameField)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.pinToView(profileImageWrap, profileImageBackground, padding: 6)
        NSLayoutConstraint.pinToView(profileImageBackground, profileEmjoiLabel)
        
        centerYConstraint = profileImageWrap.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: profileImageWrap.topAnchor, constant: -32),
            profileImageWrap.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYConstraint!,
            profileImageWrap.widthAnchor.constraint(equalToConstant: profileImageDiameter),
            profileImageWrap.heightAnchor.constraint(equalTo: profileImageWrap.widthAnchor),
            nicknameField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            nicknameField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            nicknameField.topAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: 32),
            nicknameField.heightAnchor.constraint(equalToConstant: 50),
            continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            continueButton.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 16),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
        if OSAccount.current.hasValidProfileDetails {
            titleLabel.text = "Update profile"
        }
        let nickname = OSAccount.current.nickname
        let emoji = OSAccount.current.emoji ?? selectedEmoji
        
        nicknameField.text = nickname
        profileEmjoiLabel.text = emoji
        profileImageBackground.backgroundColor = UIColor.OS.hashedProfileColor(nickname ?? "")
    }
    
    private func processAndValidateNickname(_ nickname: String?) throws -> String {
        guard let nickname = nickname else {
            throw OSError.nicknameMissing
        }
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedNickname = trimmedNickname.lowercased()
        
        if lowercasedNickname.count < nicknameMinLength {
            throw OSError.nicknameTooShort
        }
        if lowercasedNickname.count > nicknameMaxLength {
            throw OSError.nicknameTooLong
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
    
    @objc private func profileEmojiTapped(_ sender: UITapGestureRecognizer) {
        Coordinator.global.presentEmojiPicker(from: self, emojis: viewModel.emoijs)
    }
}

// MARK: - Nickname View Model Delegate Conformance

extension PlayerProfileViewController: PlayerProfileViewModelDelegate {
    
    func detailsUpdatedSuccessfully() {
        Coordinator.global.showMessage(OSMessage("Successfully updated player details! 🤝", .success))
        // we check if vc was presented modally so
        // that we know where to send the user next
        guard presentingViewController != nil else {
            Coordinator.global.changeAppState(.authorized)
            return
        }
        dismiss(animated: true)
    }
    
    func detailsUpdateFailed(with error: Error) {
        Coordinator.global.showMessage(OSMessage(error.localizedDescription, .failure))
    }
    
    func shouldToggleLoading(enabled: Bool) {
        //continueButton.toggleLoading(enabled)
    }
}

extension PlayerProfileViewController: UITextFieldDelegate {
    
}

// swiftlint:disable force_cast
extension PlayerProfileViewController {
    
    @objc
    dynamic func keyboardWillShow(
        _ notification: NSNotification
    ) {
        animateWithKeyboard(notification: notification) {
            (keyboardFrame) in
            let constant =  keyboardFrame.height / 2//(self.view.frame.size.height - keyboardFrame.height) * 100 / self.view.frame.size.height
            //self.textFieldTrailingConstraint?.constant = constant
            self.centerYConstraint?.constant = -constant
        }
    }
    
    @objc
    dynamic func keyboardWillHide(
        _ notification: NSNotification
    ) {
        animateWithKeyboard(notification: notification) {
            (keyboardFrame) in
            //self.textFieldTrailingConstraint?.constant = 20
            self.centerYConstraint?.constant = 0
        }
    }
    
    func animateWithKeyboard(
        notification: NSNotification,
        animations: ((_ keyboardFrame: CGRect) -> Void)?
    ) {
        // Extract the duration of the keyboard animation
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as! Double
        
        // Extract the final frame of the keyboard
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue
        
        // Extract the curve of the iOS keyboard animation
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = notification.userInfo![curveKey] as! Int
        let curve = UIView.AnimationCurve(rawValue: curveValue)!

        // Create a property animator to manage the animation
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve
        ) {
            // Perform the necessary animation layout updates
            animations?(keyboardFrameValue.cgRectValue)
            
            // Required to trigger NSLayoutConstraint changes
            // to animate
            self.view?.layoutIfNeeded()
        }
        
        // Start the animation
        animator.startAnimation()
    }
}
