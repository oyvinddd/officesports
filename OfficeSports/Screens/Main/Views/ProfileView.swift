//
//  ProfileView.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import Combine

private let codeTransitionDuration: TimeInterval = 0.3          // seconds
private let codeHideDelayDuration: TimeInterval = 4             // seconds
private let emojiFadeTransitionDuration: TimeInterval = 0.15    // seconds

private let profileImageDiameter: CGFloat = 128
private let sportImageDiameter: CGFloat = 60
private let profileImageRadius: CGFloat = profileImageDiameter / 2
private let sportImageRadius: CGFloat = sportImageDiameter / 2

protocol ProfileViewDelegate: AnyObject {
    
    func profilePictureTapped()
    
    func invitesButtonTapped()
    
    func settingsButtonTapped()
}

final class ProfileView: UIView {
    
    private lazy var invitesButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "tray.fill", withConfiguration: config)
        let button = UIButton.createButton(.clear, .clear, title: nil)
        button.addTarget(self, action: #selector(invitesButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.OS.Text.disabled
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "gearshape.fill", withConfiguration: config)
        let button = UIButton.createButton(.clear, .clear, title: nil)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.OS.Text.normal
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var tableTennisCodeImage: UIImage? = {
        guard let payload = OSAccount.current.qrCodePayloadForSport(.tableTennis) else {
            return nil
        }
        let color = UIColor.OS.Text.normal
        let backgroundColor = UIColor.white
        return QRCodeGenerator.generate(from: payload, color: color, backgroundColor: backgroundColor)
    }()
    
    private lazy var foosballCodeImage: UIImage? = {
        guard let payload = OSAccount.current.qrCodePayloadForSport(.foosball) else {
            return nil
        }
        let color = UIColor.OS.Text.normal
        let backgroundColor = UIColor.white
        return QRCodeGenerator.generate(from: payload, color: color, backgroundColor: backgroundColor)
    }()
    
    private lazy var poolCodeImage: UIImage? = {
        guard let payload = OSAccount.current.qrCodePayloadForSport(.pool) else {
            return nil
        }
        let color = UIColor.OS.Text.normal
        let backgroundColor = UIColor.white
        return QRCodeGenerator.generate(from: payload, color: color, backgroundColor: backgroundColor)
    }()
    
    private lazy var codeImageView: UIImageView = {
        return UIImageView.createImageView(foosballCodeImage)
    }()
    
    private lazy var codeImageWrap: UIView = {
        let view = UIView.createView(.white, cornerRadius: 5)
        view.applyMediumDropShadow(.black)
        view.alpha = 0
        return view
    }()
    
    private lazy var profileImageWrap: UIView = {
        let imageWrap = UIView.createView(.white, cornerRadius: profileImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
        imageWrap.addGestureRecognizer(tapGestureRecognizer)
        return imageWrap
    }()
    
    private lazy var profileImageBackground: UIView = {
        let nickname = OSAccount.current.nickname ?? ""
        let profileColor = UIColor.OS.hashedProfileColor(nickname)
        let profileImageBackground = UIView.createView(profileColor)
        profileImageBackground.applyCornerRadius((profileImageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var profileEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 80)
        return label
    }()
    
    private lazy var sportImageBackground: UIView = {
        let view = UIView.createView(UIColor.OS.Profile.color12)
        view.applyCornerRadius((sportImageDiameter - 10) / 2)
        return view
    }()
    
    private lazy var sportImageWrap: UIView = {
        let imageWrap = UIView.createView(.white)
        imageWrap.applyCornerRadius(sportImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var foosballEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center, text: "⚽️")
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    private lazy var tableTennisEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center, text: "🏓")
        label.font = UIFont.systemFont(ofSize: 32)
        label.alpha = 0
        return label
    }()
    
    private lazy var poolEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center, text: "🎱")
        label.font = UIFont.systemFont(ofSize: 32)
        label.alpha = 0
        return label
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var playerStatsView: PlayerStatsView = {
        return PlayerStatsView(points: 1200, totalWins: 0)
    }()
    
    private var subscribers = Set<AnyCancellable>()
    private var isDisplayingQrCode: Bool = false
    
    weak var delegate: ProfileViewDelegate?
    
    init(initialSport: OSSport, delegate: ProfileViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupSubscribers()
        setupChildViews()
        configureForSport(initialSport)
        profileEmojiLabel.text = OSAccount.current.emoji
        nicknameLabel.text = OSAccount.current.nickname?.lowercased()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureForSport(_ sport: OSSport) {
        // update player stats labels with stats for the given sport
        let points = OSAccount.current.player?.pointsForSport(sport)
        let totalWins = OSAccount.current.player?.totalSeasonWinsForSport(sport)
        playerStatsView.updateStats(points: points, totalWins: totalWins)
        
        var sportImageWrapAlpha: CGFloat = 1
        var sportImageBackgroundColor = UIColor.OS.Sport.foosball
        var foosballEmojiAlpha: CGFloat = 1
        var tableTennisEmojiAlpha: CGFloat = 1
        var poolEmojiAlpha: CGFloat = 1
        
        switch sport {
        case .foosball:
            codeImageView.image = foosballCodeImage
            sportImageWrapAlpha = isDisplayingQrCode ? 0 : 1
            sportImageBackgroundColor = UIColor.OS.Sport.foosball
            foosballEmojiAlpha = 1
            tableTennisEmojiAlpha = 0
            poolEmojiAlpha = 0
        case .tableTennis:
            codeImageView.image = tableTennisCodeImage
            sportImageWrapAlpha = isDisplayingQrCode ? 0 : 1
            sportImageBackgroundColor = UIColor.OS.Sport.tableTennis
            foosballEmojiAlpha = 0
            tableTennisEmojiAlpha = 1
            poolEmojiAlpha = 0
        case .pool:
            codeImageView.image = poolCodeImage
            sportImageWrapAlpha = isDisplayingQrCode ? 0 : 1
            sportImageBackgroundColor = UIColor.OS.Sport.pool
            foosballEmojiAlpha = 0
            tableTennisEmojiAlpha = 0
            poolEmojiAlpha = 1
        }
        UIView.animate(withDuration: emojiFadeTransitionDuration, delay: 0) {
            self.sportImageWrap.alpha = sportImageWrapAlpha
            self.sportImageBackground.backgroundColor = sportImageBackgroundColor
            self.foosballEmojiLabel.alpha = foosballEmojiAlpha
            self.tableTennisEmojiLabel.alpha = tableTennisEmojiAlpha
            self.poolEmojiLabel.alpha = poolEmojiAlpha
        }
    }
    
    func displayQrCode() {
        guard !isDisplayingQrCode else {
            return
        }
        isDisplayingQrCode = true
        UIView.animate(withDuration: codeTransitionDuration, delay: 0, options: [.curveEaseOut]) { [weak self] in
            self?.profileImageWrap.alpha = 0
            self?.sportImageWrap.alpha = 0
            self?.codeImageWrap.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: codeTransitionDuration, delay: codeHideDelayDuration, options: [.curveEaseOut]) { [weak self] in
                self?.profileImageWrap.alpha = 1
                self?.sportImageWrap.alpha = 1
                self?.codeImageWrap.alpha = 0
            } completion: { [weak self] _ in
                self?.isDisplayingQrCode = false
            }
        }
    }
    
    func handleTouch(point: CGPoint) {
        if settingsButton.frame.contains(point) {
            settingsButton.sendActions(for: .touchUpInside)
        } else if invitesButton.frame.contains(point) {
            invitesButton.sendActions(for: .touchUpInside)
        } else if profileImageWrap.frame.contains(point) {
            delegate?.profilePictureTapped()
        }
    }
    
    private func setupSubscribers() {
        OSAccount.current.$player
            .receive(on: DispatchQueue.main)
            .map({ $0!.nickname })
            .assign(to: \.text, on: nicknameLabel)
            .store(in: &subscribers)
        OSAccount.current.$player
            .receive(on: DispatchQueue.main)
            .map({ UIColor.OS.hashedProfileColor($0!.nickname) })
            .assign(to: \.backgroundColor, on: profileImageBackground)
            .store(in: &subscribers)
        OSAccount.current.$player
            .receive(on: DispatchQueue.main)
            .map({ $0!.emoji })
            .assign(to: \.text, on: profileEmojiLabel)
            .store(in: &subscribers)
    }
    
    private func setupChildViews() {
        addSubview(invitesButton)
        addSubview(settingsButton)
        addSubview(codeImageWrap)
        addSubview(profileImageWrap)
        profileImageWrap.addSubview(profileImageBackground)
        addSubview(sportImageWrap)
        addSubview(nicknameLabel)
        addSubview(playerStatsView)
        
        NSLayoutConstraint.pinToView(codeImageWrap, codeImageView, padding: 6)
        NSLayoutConstraint.pinToView(profileImageBackground, profileEmojiLabel)
        NSLayoutConstraint.pinToView(sportImageWrap, sportImageBackground, padding: 5)
        NSLayoutConstraint.pinToView(sportImageBackground, foosballEmojiLabel)
        NSLayoutConstraint.pinToView(sportImageBackground, tableTennisEmojiLabel)
        NSLayoutConstraint.pinToView(sportImageBackground, poolEmojiLabel)
        
        NSLayoutConstraint.activate([
            invitesButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            invitesButton.centerYAnchor.constraint(equalTo: settingsButton.centerYAnchor),
            invitesButton.widthAnchor.constraint(equalToConstant: 60),
            invitesButton.heightAnchor.constraint(equalTo: invitesButton.widthAnchor),
            settingsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            settingsButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsButton.widthAnchor.constraint(equalToConstant: 60),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            codeImageWrap.widthAnchor.constraint(equalToConstant: profileImageDiameter),
            codeImageWrap.heightAnchor.constraint(equalTo: codeImageWrap.widthAnchor),
            codeImageWrap.centerXAnchor.constraint(equalTo: profileImageWrap.centerXAnchor),
            codeImageWrap.centerYAnchor.constraint(equalTo: profileImageWrap.centerYAnchor),
            profileImageWrap.widthAnchor.constraint(equalToConstant: profileImageDiameter),
            profileImageWrap.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50),
            profileImageWrap.heightAnchor.constraint(equalTo: profileImageWrap.widthAnchor),
            profileImageWrap.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageBackground.leftAnchor.constraint(equalTo: profileImageWrap.leftAnchor, constant: 8),
            profileImageBackground.rightAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: -8),
            profileImageBackground.topAnchor.constraint(equalTo: profileImageWrap.topAnchor, constant: 8),
            profileImageBackground.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: -8),
            sportImageWrap.centerXAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: -8),
            sportImageWrap.centerYAnchor.constraint(equalTo: profileImageWrap.bottomAnchor, constant: -22),
            sportImageWrap.widthAnchor.constraint(equalToConstant: sportImageDiameter),
            sportImageWrap.heightAnchor.constraint(equalTo: sportImageWrap.widthAnchor),
            nicknameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            nicknameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            nicknameLabel.topAnchor.constraint(equalTo: sportImageWrap.bottomAnchor, constant: 16),
            playerStatsView.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 12),
            playerStatsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            playerStatsView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    // MARK: - Button Handling
    
    @objc private func profilePictureTapped(_ sender: UITapGestureRecognizer) {
        delegate?.profilePictureTapped()
    }
    
    @objc private func invitesButtonTapped(_ sender: UIButton) {
        // FIXME: enable when feature is done
        // delegate?.invitesButtonTapped()
    }
    
    @objc private func settingsButtonTapped(_ sender: UIButton) {
        delegate?.settingsButtonTapped()
    }
}
