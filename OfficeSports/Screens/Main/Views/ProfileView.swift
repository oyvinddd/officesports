//
//  ProfileView.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import Combine

private let profileImageDiameter: CGFloat = 128
private let sportImageDiameter: CGFloat = 60
private let profileImageRadius: CGFloat = profileImageDiameter / 2
private let sportImageRadius: CGFloat = sportImageDiameter / 2
private let codeTransitionDuration: TimeInterval = 0.3          // seconds
private let codeHideDelayDuration: TimeInterval = 4             // seconds
private let emojiFadeTransitionDuration: TimeInterval = 0.15    // seconds

protocol ProfileViewDelegate: AnyObject {
    
    func profilePictureTapped()
    
    func settingsButtonTapped()
}

final class ProfileView: UIView {
    
    private lazy var totalWinsLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center, text: "🏆 x 0")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var totalWinsView: UIView = {
        let view = UIView.createView(UIColor.OS.Text.normal, cornerRadius: 5)
        view.alpha = 0.8
        NSLayoutConstraint.pinToView(view, totalWinsLabel, padding: 6)
        return view
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
        let profileColor = UIColor.OS.hashedProfileColor(account.nickname ?? "")
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
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var foosballScoreLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 24)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var tableTennisScoreLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 24)
        label.numberOfLines = 1
        return label
    }()
    
    weak var delegate: ProfileViewDelegate?
    
    private var subscribers = Set<AnyCancellable>()
    private var account: OSAccount
    private var isDisplayingQrCode: Bool = false
    
    init(account: OSAccount, initialSport: OSSport, delegate: ProfileViewDelegate?) {
        self.account = account
        self.delegate = delegate
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let foosballStats = account.player?.foosballStats
        let tableTennisStats = account.player?.tableTennisStats
        
        profileEmojiLabel.text = account.emoji
        nicknameLabel.text = account.nickname?.lowercased()
        totalWinsLabel.text = "🏆 x 0"
        foosballScoreLabel.text = "\(foosballStats?.score ?? 1200) pts"
        tableTennisScoreLabel.text = "\(tableTennisStats?.score ?? 1200) pts"
        setupSubscribers()
        setupChildViews()
        configureForSport(initialSport)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureForSport(_ sport: OSSport) {
        var totalWinsViewAlpha: CGFloat = 1
        var sportImageWrapAlpha: CGFloat = 1
        var sportImageBackgroundColor = UIColor.OS.Sport.foosball
        var foosballEmojiAlpha: CGFloat = 1
        var tableTennisEmojiAlpha: CGFloat = 1
        
        switch sport {
        case .foosball:
            codeImageView.image = foosballCodeImage
            totalWinsViewAlpha = 1
            sportImageWrapAlpha = isDisplayingQrCode ? 0 : 1
            sportImageBackgroundColor = UIColor.OS.Sport.foosball
            foosballEmojiAlpha = 1
            tableTennisEmojiAlpha = 0
        case .tableTennis:
            codeImageView.image = tableTennisCodeImage
            totalWinsViewAlpha = 1
            sportImageWrapAlpha = isDisplayingQrCode ? 0 : 1
            sportImageBackgroundColor = UIColor.OS.Sport.tableTennis
            foosballEmojiAlpha = 0
            tableTennisEmojiAlpha = 1
        default:
            codeImageView.image = tableTennisCodeImage
            totalWinsViewAlpha = 0
            sportImageWrapAlpha = 0
            foosballEmojiAlpha = 0
            tableTennisEmojiAlpha = 0
        }
        UIView.animate(withDuration: emojiFadeTransitionDuration, delay: 0) {
            self.totalWinsView.alpha = totalWinsViewAlpha
            self.sportImageWrap.alpha = sportImageWrapAlpha
            self.sportImageBackground.backgroundColor = sportImageBackgroundColor
            self.foosballEmojiLabel.alpha = foosballEmojiAlpha
            self.foosballScoreLabel.alpha = foosballEmojiAlpha
            self.tableTennisEmojiLabel.alpha = tableTennisEmojiAlpha
            self.tableTennisScoreLabel.alpha = tableTennisEmojiAlpha
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
        OSAccount.current.$player
            .receive(on: DispatchQueue.main)
            .map({ "\($0?.foosballStats?.score ?? 0) pts" })
            .assign(to: \.text, on: foosballScoreLabel)
            .store(in: &subscribers)
        OSAccount.current.$player
            .receive(on: DispatchQueue.main)
            .map({ "\($0?.tableTennisStats?.score ?? 0) pts" })
            .assign(to: \.text, on: tableTennisScoreLabel)
            .store(in: &subscribers)
        OSAccount.current.$player
            .receive(on: DispatchQueue.main)
            .map({ "🏆 x \($0?.totalSeasonWins())" })
            .assign(to: \.text, on: totalWinsLabel)
            .store(in: &subscribers)
    }
    
    private func setupChildViews() {
        addSubview(totalWinsView)
        addSubview(settingsButton)
        addSubview(codeImageWrap)
        addSubview(profileImageWrap)
        profileImageWrap.addSubview(profileImageBackground)
        addSubview(sportImageWrap)
        addSubview(nicknameLabel)
        addSubview(foosballScoreLabel)
        addSubview(tableTennisScoreLabel)
        
        NSLayoutConstraint.pinToView(codeImageWrap, codeImageView, padding: 6)
        NSLayoutConstraint.pinToView(profileImageBackground, profileEmojiLabel)
        NSLayoutConstraint.pinToView(sportImageWrap, sportImageBackground, padding: 5)
        NSLayoutConstraint.pinToView(sportImageBackground, foosballEmojiLabel)
        NSLayoutConstraint.pinToView(sportImageBackground, tableTennisEmojiLabel)
        
        NSLayoutConstraint.activate([
            totalWinsView.leftAnchor.constraint(equalTo: leftAnchor, constant: 24),
            totalWinsView.centerYAnchor.constraint(equalTo: settingsButton.centerYAnchor),
            settingsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            settingsButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsButton.widthAnchor.constraint(equalToConstant: 50),
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
            foosballScoreLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            foosballScoreLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            foosballScoreLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 6),
            foosballScoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            tableTennisScoreLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            tableTennisScoreLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            tableTennisScoreLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 6),
            tableTennisScoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Button Handling
    
    @objc private func profilePictureTapped(_ sender: UITapGestureRecognizer) {
        delegate?.profilePictureTapped()
    }
    
    @objc private func settingsButtonTapped(_ sender: UIButton) {
        delegate?.settingsButtonTapped()
    }
}
