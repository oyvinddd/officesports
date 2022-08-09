//
//  NicknameViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit
import Combine

private let profileImageDiameter: CGFloat = 110
private let profileImageRadius: CGFloat = profileImageDiameter / 2

final class PlayerProfileViewController: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(.white, tintColor: UIColor.OS.General.main, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.applyCornerRadius(20)
        button.alpha = 0.9
        return button
    }()
    
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
    
    private lazy var emojiField: UITextField = {
        let textField = UITextField.createTextField(UIColor.OS.General.mainDark, color: .white)
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(16, 0, 0)
        textField.font = UIFont.boldSystemFont(ofSize: 20)
        textField.autocapitalizationType = .none
        textField.applyCornerRadius(8)
        textField.delegate = self
        return textField
    }()
    
    private lazy var nicknameField: UITextField = {
        let textField = UITextField.createTextField(UIColor.OS.General.mainDark, color: .white, placeholder: "Nickname")
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(16, 0, 0)
        textField.font = UIFont.boldSystemFont(ofSize: 20)
        textField.autocapitalizationType = .none
        textField.applyCornerRadius(8)
        return textField
    }()
    
    private lazy var teamField: UITextField = {
        let textField = UITextField.createTextField(UIColor.OS.General.mainDark, color: .white)
        let attrPlaceholder = NSAttributedString(string: "No team selected", attributes: [NSAttributedString.Key.foregroundColor: UIColor.OS.General.main])
        textField.attributedPlaceholder = attrPlaceholder
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(16, 0, 0)
        textField.font = UIFont.boldSystemFont(ofSize: 20)
        textField.autocapitalizationType = .none
        textField.applyCornerRadius(8)
        textField.delegate = self
        return textField
    }()
    
    private lazy var continueButton: OSButton = {
        let button = OSButton("Continue", type: .primary)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: PlayerProfileViewModel
    private var centerYConstraint: NSLayoutConstraint?
    private var subscribers = Set<AnyCancellable>()
    
    var selectedTeam: OSTeam?
    var selectedEmoji: String {
        didSet {
            emojiField.text = selectedEmoji
        }
    }
    
    init(viewModel: PlayerProfileViewModel) {
        self.viewModel = viewModel
        self.selectedTeam = OSAccount.current.player?.team
        self.selectedEmoji = OSAccount.current.emoji ?? viewModel.randomEmoji
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscribers()
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
    
    private func setupChildViews() {
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(emojiField)
        view.addSubview(nicknameField)
        view.addSubview(teamField)
        view.addSubview(continueButton)
        
        centerYConstraint = nicknameField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        NSLayoutConstraint.activate([
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: nicknameField.topAnchor, constant: -32),
            centerYConstraint!,
            emojiField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            emojiField.rightAnchor.constraint(equalTo: nicknameField.leftAnchor, constant: -16),
            emojiField.centerYAnchor.constraint(equalTo: nicknameField.centerYAnchor),
            emojiField.widthAnchor.constraint(equalToConstant: 60),
            emojiField.heightAnchor.constraint(equalTo: nicknameField.heightAnchor),
            nicknameField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            nicknameField.heightAnchor.constraint(equalToConstant: 50),
            teamField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            teamField.rightAnchor.constraint(equalTo: nicknameField.rightAnchor),
            teamField.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 16),
            teamField.heightAnchor.constraint(equalTo: nicknameField.heightAnchor),
            continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            continueButton.topAnchor.constraint(equalTo: teamField.bottomAnchor, constant: 16),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
        // if a player is already present it means we are editing our
        // profile, if not we are creating our profile for the first time
        if let player = OSAccount.current.player {
            titleLabel.text = "Update profile"
            emojiField.text = player.emoji
            nicknameField.text = player.nickname
            teamField.text = player.team?.name ?? nil
        }
    }
    
    private func setupSubscribers() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                switch state {
                case .loading:
                    continueButton.toggleLoading(true)
                case .success:
                    continueButton.toggleLoading(false)
                    Coordinator.global.send(OSMessage("Successfully updated player details! 🤝", .success))
                    // we check if vc was presented modally so
                    // that we know where to send the user next
                    guard presentingViewController != nil else {
                        Coordinator.global.changeAppState(.authorized)
                        return
                    }
                    dismiss(animated: true)
                case .failure(let error):
                    continueButton.toggleLoading(false)
                    Coordinator.global.send(error)
                default:
                    // do nothing
                    return
                }
            }.store(in: &subscribers)
    }
    
    @objc private func continueButtonTapped(_ sender: UIButton) {
        do {
            let nickname = try viewModel.processAndValidateNickname(nicknameField.text)
            viewModel.registerPlayerProfile(nickname: nickname, emoji: selectedEmoji, team: selectedTeam)
        } catch let error {
            Coordinator.global.send(error)
        }
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Text Field Delegate

extension PlayerProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == teamField {
            presentTeamPickerSheet()
        } else if textField == emojiField {
            Coordinator.global.presentEmojiPicker(from: self, emojis: viewModel.emoijs)
        }
        return false
    }
    
    private func presentTeamPickerSheet() {
        let viewModel = TeamsViewModel(api: FirebaseSportsAPI())
        let viewController = TeamPickerViewController(viewModel: viewModel, delegate: self)
        
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - Team Selection Delegate

extension PlayerProfileViewController: TeamSelectionDelegate {
    
    func didSelectTeam(_ team: OSTeam) {
        teamField.text = team.name
        selectedTeam = team
    }
}

// MARK: - UI / Keyboard handling

// swiftlint:disable force_cast
extension PlayerProfileViewController {
    
    @objc dynamic func keyboardWillShow(_ notification: NSNotification) {
        animateWithKeyboard(notification: notification) { keyboardFrame in
            let constant = keyboardFrame.height / 2
            self.centerYConstraint?.constant = -constant
        }
    }
    
    @objc dynamic func keyboardWillHide(_ notification: NSNotification) {
        animateWithKeyboard(notification: notification) { _ in
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
