//
//  ProfileView.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

private let profileImageDimater: CGFloat = 128
private let profileImageRadius: CGFloat = profileImageDimater / 2

private let codeTransitionDuration: TimeInterval = 0.3  // seconds
private let codeHideDelayDuration: TimeInterval = 2     // seconds

protocol ProfileViewDelegate: AnyObject {
    
    func settingsButtonTapped()
}

final class ProfileView: UIView {
    
    private lazy var foosballCodeImage: UIImage? = {
        guard let payload = OSAccount.current.qrCodePayloadForSport(.foosball) else {
            return nil
        }
        return CodeGen.generateQRCode(from: payload)
    }()
    
    private lazy var tableTennisCodeImage: UIImage? = {
        guard let payload = OSAccount.current.qrCodePayloadForSport(.tableTennis) else {
            return nil
        }
        return CodeGen.generateQRCode(from: payload)
    }()
    
    private lazy var codeImageView: UIImageView = {
        return UIImageView.createImageView(foosballCodeImage, alpha: 0)
    }()
    
    private lazy var settingsButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "gearshape", withConfiguration: config)
        let button = UIButton.createButton(.clear, .clear, title: nil)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.OS.General.mainDark
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var profileImageWrap: UIView = {
        let imageWrap = UIView.createView(.white)
        imageWrap.applyCornerRadius(profileImageRadius)
        imageWrap.applyMediumDropShadow(UIColor.OS.Text.normal)
        return imageWrap
    }()
    
    private lazy var profileImageBackground: UIView = {
        let profileImageBackground = UIView.createView(.yellow)
        profileImageBackground.applyCornerRadius((profileImageDimater - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var profileEmjoiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 80)
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center)
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var totalScoreLabel: UILabel = {
        let label = UILabel.createLabel(.darkGray, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    private weak var delegate: ProfileViewDelegate?
    
    private let account: OSAccount
    private var isDisplayingCode: Bool = false
    
    init(account: OSAccount, delegate: ProfileViewDelegate?) {
        self.account = account
        self.delegate = delegate
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        configureUI()
        setupChildViews()
        displayDetailsForSport(.foosball)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayDetailsForSport(_ sport: OSSport, animated: Bool = false) {
        if sport == .foosball {
            totalScoreLabel.text = "\(account.player.foosballScore) pts"
        } else {
            totalScoreLabel.text = "\(account.player.tableTennisScore) pts"
        }
    }
    
    func displayQrCode(seconds: Int) {
        guard !isDisplayingCode else {
            return
        }
        isDisplayingCode = true
        UIView.animate(withDuration: codeTransitionDuration, delay: 0, options: [.curveEaseOut]) { [weak self] in
            self?.profileImageWrap.alpha = 0
            self?.codeImageView.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: codeTransitionDuration, delay: TimeInterval(seconds), options: [.curveEaseOut]) { [weak self] in
                self?.profileImageWrap.alpha = 1
                self?.codeImageView.alpha = 0
            } completion: { [weak self] _ in
                self?.isDisplayingCode = false
            }
        }
    }
    
    private func setupChildViews() {
        addSubview(codeImageView)
        addSubview(profileImageWrap)
        addSubview(settingsButton)
        profileImageWrap.addSubview(profileImageBackground)
        addSubview(usernameLabel)
        addSubview(totalScoreLabel)
        
        NSLayoutConstraint.pinToView(profileImageBackground, profileEmjoiLabel)
        NSLayoutConstraint.activate([
            codeImageView.widthAnchor.constraint(equalToConstant: profileImageDimater),
            codeImageView.heightAnchor.constraint(equalTo: codeImageView.widthAnchor),
            codeImageView.centerXAnchor.constraint(equalTo: profileImageWrap.centerXAnchor),
            codeImageView.centerYAnchor.constraint(equalTo: profileImageWrap.centerYAnchor),
            profileImageWrap.widthAnchor.constraint(equalToConstant: profileImageDimater),
            profileImageWrap.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageWrap.heightAnchor.constraint(equalTo: profileImageWrap.widthAnchor),
            profileImageWrap.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageBackground.leftAnchor.constraint(equalTo: profileImageWrap.leftAnchor, constant: 8),
            profileImageBackground.rightAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: -8),
            profileImageBackground.topAnchor.constraint(equalTo: profileImageWrap.topAnchor, constant: 8),
            profileImageBackground.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: -8),
            settingsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            settingsButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            settingsButton.widthAnchor.constraint(equalToConstant: 50),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            usernameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            usernameLabel.rightAnchor.constraint(equalTo: rightAnchor),
            usernameLabel.topAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: 8),
            totalScoreLabel.leftAnchor.constraint(equalTo: leftAnchor),
            totalScoreLabel.rightAnchor.constraint(equalTo: rightAnchor),
            totalScoreLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 6),
            totalScoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func configureUI() {
        profileEmjoiLabel.text = account.player.emoji
        usernameLabel.text = account.player.nickname.lowercased()
    }
    
    @objc private func settingsButtonTapped(_ sender: UIButton) {
        delegate?.settingsButtonTapped()
    }
}
