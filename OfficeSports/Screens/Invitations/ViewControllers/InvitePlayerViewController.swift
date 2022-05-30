//
//  InvitePlayerViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 25/05/2022.
//

import UIKit
import Combine

private let kBackgroundMaxFade: CGFloat = 0.6
private let kBackgroundMinFade: CGFloat = 0
private let kAnimDuration: TimeInterval = 0.15
private let kAnimDelay: TimeInterval = 0

private let profileImageDiameter: CGFloat = 100
private let profileImageRadius: CGFloat = profileImageDiameter / 2

final class InvitePlayerViewController: UIViewController {
    
    private lazy var backgroundView: UIView = {
        let view = UIView.createView(.black)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(tapRecognizer)
        view.alpha = 0
        return view
    }()
    
    private lazy var dialogView: UIView = {
        let view = UIView.createView(.white)
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var dialogHandle: UIView = {
        let view = UIView.createView(UIColor.OS.Text.subtitle, cornerRadius: 3)
        view.alpha = 0.8
        return view
    }()
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.clear)
    }()
    
    private lazy var profileImageWrap: UIView = {
        let imageWrap = UIView.createView(.white)
        imageWrap.applyCornerRadius(profileImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var profileImageBackground: UIView = {
        let profileColor = UIColor.OS.hashedProfileColor(player.nickname)
        let profileImageBackground = UIView.createView(profileColor)
        profileImageBackground.applyCornerRadius((profileImageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var profileEmjoiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 60)
        return label
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 26, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var playerDetailsLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var inviteButton: OSButton = {
        let button = OSButton("Invite to match", type: .primaryInverted)
        button.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: OSButton = {
        let button = OSButton("Close", type: .secondaryInverted)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
    }()
    
    private lazy var dialogBottomConstraint: NSLayoutConstraint = {
        let constraint = dialogView.topAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.constant = dialogHideConstant
        return constraint
    }()
    
    private let dialogHideConstant: CGFloat = 0
    private var dialogShowConstant: CGFloat {
        return -dialogView.frame.height
    }
    
    private var subscribers: [AnyCancellable] = []
    
    private let viewModel: InvitePlayerViewModel
    private let player: OSPlayer
    private let sport: OSSport
    
    init(viewModel: InvitePlayerViewModel, player: OSPlayer, sport: OSSport) {
        self.viewModel = viewModel
        self.player = player
        self.sport = sport
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
        
        // setup subscribers
        viewModel.$shouldShowLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.showLoading, on: inviteButton)
            .store(in: &subscribers)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleDialog(enabled: true)
    }
    
    private func setupChildViews() {
        view.addSubview(backgroundView)
        view.addSubview(dialogView)
        dialogView.addSubview(contentWrap)
        dialogView.addSubview(dialogHandle)
        contentWrap.addSubview(profileImageWrap)
        contentWrap.addSubview(nicknameLabel)
        contentWrap.addSubview(playerDetailsLabel)
        contentWrap.addSubview(inviteButton)
        contentWrap.addSubview(closeButton)
        profileImageWrap.addSubview(profileImageBackground)
        
        NSLayoutConstraint.pinToView(profileImageBackground, profileEmjoiLabel)
        
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
            contentWrap.leftAnchor.constraint(equalTo: dialogView.leftAnchor),
            contentWrap.rightAnchor.constraint(equalTo: dialogView.rightAnchor),
            contentWrap.topAnchor.constraint(equalTo: dialogHandle.topAnchor, constant: 8),
            contentWrap.bottomAnchor.constraint(equalTo: dialogView.safeAreaLayoutGuide.bottomAnchor),
            profileImageWrap.widthAnchor.constraint(equalToConstant: profileImageDiameter),
            profileImageWrap.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 32),
            profileImageWrap.heightAnchor.constraint(equalTo: profileImageWrap.widthAnchor),
            profileImageWrap.centerXAnchor.constraint(equalTo: contentWrap.centerXAnchor),
            profileImageBackground.leftAnchor.constraint(equalTo: profileImageWrap.leftAnchor, constant: 8),
            profileImageBackground.rightAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: -8),
            profileImageBackground.topAnchor.constraint(equalTo: profileImageWrap.topAnchor, constant: 8),
            profileImageBackground.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: -8),
            nicknameLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            nicknameLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            nicknameLabel.topAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: 16),
            playerDetailsLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            playerDetailsLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            playerDetailsLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 6),
            inviteButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            inviteButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            inviteButton.topAnchor.constraint(equalTo: playerDetailsLabel.bottomAnchor, constant: 32),
            inviteButton.heightAnchor.constraint(equalToConstant: 50),
            closeButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            closeButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 16),
            closeButton.bottomAnchor.constraint(equalTo: contentWrap.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        profileEmjoiLabel.text = player.emoji
        nicknameLabel.text = player.nickname
        let stats = player.statsForSport(sport)
        playerDetailsLabel.text = "\(stats.totalScore) pts • \(stats.totalMatches) matches"
        inviteButton.setTitle("Invite to \(sport.humanReadableName) match", for: .normal)
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
    
    private func toggleBackgroundView(enabled: Bool) {
        UIView.animate(withDuration: kAnimDuration) {
            self.backgroundView.alpha = enabled ? kBackgroundMaxFade : kBackgroundMinFade
        }
    }
    
    private func dismiss() {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Button Handling
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        toggleDialog(enabled: false)
    }
    
    @objc private func inviteButtonTapped(_ sender: OSButton) {
        viewModel.invitePlayer(player, sport: sport)
    }
    
    @objc private func closeButtonTapped(_ sender: OSButton) {
        dismiss()
    }
}

// MARK: - Invite Player Delegate Conformance

extension InvitePlayerViewController: InvitePlayerViewModelDelegate {
    
    func invitePlayerSuccess() {
        let message = OSMessage("You have invited \(player.nickname) to a game of \(sport.humanReadableName)", .success)
        Coordinator.global.showMessage(message)
        toggleDialog(enabled: false)
    }
    
    func invitePlayerFailed(with error: Error) {
        Coordinator.global.showMessage(OSMessage(error.localizedDescription, .failure))
    }
}
