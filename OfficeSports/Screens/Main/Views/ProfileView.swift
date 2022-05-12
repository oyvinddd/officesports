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
private let codeHideDelayDuration: TimeInterval = 3     // seconds

final class ProfileView: UIView {
    
    private lazy var codeImageView: UIImageView = {
        let image = CodeGen.generateQRCode(from: "Hello, world!")
        let imageView = UIImageView.createImageView(image!)
        imageView.alpha = 0
        return imageView
    }()
    
    private lazy var profileImageWrap: UIView = {
        let imageWrap = UIView.createView(.white)
        imageWrap.applyCornerRadius(profileImageRadius)
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
        return label
    }()
    
    private lazy var totalScoreLabel: UILabel = {
        let label = UILabel.createLabel(.darkGray, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    private var isDisplayingCode: Bool = false
    
    init(account: OSAccount) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        configureUI(account: account)
        setupChildViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayQrCode(seconds: Int) {
        guard !isDisplayingCode else {
            return
        }
        isDisplayingCode = true
        // TODO: refactor this mess
        UIView.animate(withDuration: codeTransitionDuration, delay: 0, options: [.curveEaseOut]) { [weak self] in
            self?.profileImageWrap.alpha = 0
            self?.codeImageView.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: codeTransitionDuration, delay: codeHideDelayDuration, options: [.curveEaseOut]) { [weak self] in
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
            profileImageWrap.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            profileImageWrap.heightAnchor.constraint(equalTo: profileImageWrap.widthAnchor),
            profileImageWrap.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageBackground.leftAnchor.constraint(equalTo: profileImageWrap.leftAnchor, constant: 8),
            profileImageBackground.rightAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: -8),
            profileImageBackground.topAnchor.constraint(equalTo: profileImageWrap.topAnchor, constant: 8),
            profileImageBackground.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: -8),
            usernameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            usernameLabel.rightAnchor.constraint(equalTo: rightAnchor),
            usernameLabel.topAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: 8),
            totalScoreLabel.leftAnchor.constraint(equalTo: leftAnchor),
            totalScoreLabel.rightAnchor.constraint(equalTo: rightAnchor),
            totalScoreLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 6),
            totalScoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureUI(account: OSAccount) {
        profileEmjoiLabel.text = "😭"
        usernameLabel.text = account.username.lowercased()
        totalScoreLabel.text = "\(account.totalFoosballScore) pts"
    }
}
