//
//  SettingsViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import UIKit
import Combine

private let kBackgroundMaxFade: CGFloat = 0.4
private let kBackgroundMinFade: CGFloat = 0
private let kAnimDuration: TimeInterval = 0.15
private let kAnimDelay: TimeInterval = 0

final class SettingsViewController: UIViewController {
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(tapRecognizer)
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var dialogView: UIView = {
        let view = UIView.createView(.white)
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    private lazy var newFeatureBadge: UIView = {
        let view = UIView.createView(UIColor.OS.Status.failure, cornerRadius: 3)
        let label = UILabel.createLabel(.white, text: "NEW ✨")
        label.font = UIFont.boldSystemFont(ofSize: 12)
        NSLayoutConstraint.pinToView(view, label, padding: 4)
        view.isHidden = true
        return view
    }()
    
    private lazy var dialogHandle: UIView = {
        let view = UIView.createView(UIColor.OS.Text.subtitle, cornerRadius: 3)
        view.alpha = 0.8
        return view
    }()
    
    private lazy var contentWrapView: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .vertical, spacing: 0)
    }()
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton.createButton(UIColor.OS.General.main, .white, title: "Sign Out")
        button.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var signOutConfirmController: UIAlertController = {
        let alertController = UIAlertController(title: "Are you sure you want to sign out?", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { [unowned self] _ in
            self.viewModel.signOut()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        return alertController
    }()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
    }()
    
    private lazy var dialogBottomConstraint: NSLayoutConstraint = {
        let constraint = dialogView.topAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.constant = dialogHideConstant
        return constraint
    }()
    
    private lazy var viewModel: AuthViewModel = {
        return AuthViewModel(api: FirebaseSportsAPI())
    }()
    
    private let dialogHideConstant: CGFloat = 0
    private var dialogShowConstant: CGFloat {
        return -dialogView.frame.height
    }
    
    private var subscribers: [AnyCancellable] = []
    
    init(with contentView: UIView? = nil, cornerRadius: CGFloat = 20) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        dialogView.layer.cornerRadius = cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSubscribers()
        setupChildViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleDialog(enabled: true)
    }
    
    private func setupSubscribers() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .signOutSuccess:
                    Coordinator.global.changeAppState(.unauthorized)
                case .signOutFailure(let error):
                    Coordinator.global.send(OSMessage(error.localizedDescription, .failure))
                default:
                    // do nothing
                    break
                }
            }
            .store(in: &subscribers)
    }
    
    private func setupChildViews() {
        view.addSubview(backgroundView)
        view.addSubview(dialogView)
        view.addSubview(dialogHandle)
        dialogView.addSubview(contentWrapView)
        contentWrapView.addSubview(stackView)
        contentWrapView.addSubview(newFeatureBadge)
        
        let seasonsButton = createSettingsButton("star", "Season results", #selector(seasonsButtonTapped))
        let profileButton = createSettingsButton("person", "Update profile", #selector(profileButtonTapped))
        let preferencesButton = createSettingsButton("checklist", "Preferences", #selector(preferencesButtonTapped))
        let aboutButton = createSettingsButton("info.circle", "About", #selector(aboutButtonTapped))
        let signOutButton = createSettingsButton("power", "Sign out", #selector(signOutButtonTapped))
        
        stackView.addArrangedSubviews(seasonsButton, profileButton, preferencesButton, aboutButton, signOutButton)
        
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dialogView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dialogView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dialogBottomConstraint,
            dialogHandle.centerXAnchor.constraint(equalTo: dialogView.centerXAnchor),
            dialogHandle.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 10),
            dialogHandle.widthAnchor.constraint(equalToConstant: 40),
            dialogHandle.heightAnchor.constraint(equalToConstant: 6),
            contentWrapView.leftAnchor.constraint(equalTo: dialogView.leftAnchor, constant: 8),
            contentWrapView.rightAnchor.constraint(equalTo: dialogView.rightAnchor, constant: -8),
            contentWrapView.topAnchor.constraint(equalTo: dialogHandle.topAnchor, constant: 8),
            contentWrapView.bottomAnchor.constraint(equalTo: dialogView.safeAreaLayoutGuide.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentWrapView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentWrapView.rightAnchor),
            stackView.topAnchor.constraint(equalTo: contentWrapView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentWrapView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            newFeatureBadge.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16),
            newFeatureBadge.centerYAnchor.constraint(equalTo: seasonsButton.centerYAnchor)
        ])
    }
    
    private func toggleDialog(enabled: Bool) {
        if enabled {
            dialogBottomConstraint.constant = dialogShowConstant
        } else {
            dialogBottomConstraint.constant = dialogHideConstant
        }
        toggleBackgroundView(enabled: enabled)
        UIView.animate(
            withDuration: kAnimDuration,
            delay: kAnimDelay,
            options: [.curveEaseOut]) {
                self.view.layoutIfNeeded()
            } completion: {_ in
                if !enabled {
                    self.dismiss()
                }
            }
    }
    
    private func createSettingsButton(_ systemIconName: String, _ title: String, _ sel: Selector) -> SettingsButton {
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .medium)
        let buttonIcon = UIImage(systemName: systemIconName, withConfiguration: config)!
        
        let button = SettingsButton(buttonIcon, title)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: sel)
        button.addGestureRecognizer(tapGestureRecognizer)
        
        return button
    }
    
    private func toggleBackgroundView(enabled: Bool) {
        UIView.animate(withDuration: kAnimDuration) {
            self.backgroundView.alpha = enabled ? kBackgroundMaxFade : kBackgroundMinFade
        }
    }
    
    private func dismiss() {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Button Handling
    
    @objc private func seasonsButtonTapped(_ sender: UITapGestureRecognizer) {
        Coordinator.global.presentSeasons(from: self)
    }
    
    @objc private func profileButtonTapped(_ sender: UITapGestureRecognizer) {
        Coordinator.global.presentPlayerProfile(from: self)
    }
    
    @objc private func preferencesButtonTapped(_ sender: UITapGestureRecognizer) {
        Coordinator.global.presentPreferences(from: self)
    }
    
    @objc private func aboutButtonTapped(_ sender: UITapGestureRecognizer) {
        Coordinator.global.presentAbout(from: self)
    }
    
    @objc private func signOutButtonTapped(_ sender: UITapGestureRecognizer) {
        present(signOutConfirmController, animated: true)
    }
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        toggleDialog(enabled: false)
    }
}

// MARK: - Settings Button

private final class SettingsButton: UIView {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView.createImageView(nil)
        imageView.tintColor = UIColor.OS.Text.normal
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    init(_ icon: UIImage, _ title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = icon
        titleLabel.text = title
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            titleLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
