//
//  DuoProgressView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 16/09/2022.
//

import UIKit

protocol DuoProgressViewDelegate: AnyObject {
    
    func didRegisterPlayer(_ player: OSPlayer)
    
    func didFinishRegisteringDuoMatch(_ registration: OSMatchRegistration)
}

final class DuoProgressView: UIView {
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal, spacing: 4)
    }()
    
    private lazy var player1View: PlayerView = {
        return PlayerView()
    }()
    
    private lazy var player2View: PlayerView = {
        return PlayerView()
    }()
    
    private lazy var player3View: PlayerView = {
        return PlayerView()
    }()
    
    private lazy var player4View: PlayerView = {
        return PlayerView()
    }()
    
    private var winner1: OSPlayer?
    private var winner2: OSPlayer?
    private var loser1: OSPlayer?
    private var loser2: OSPlayer?
    
    weak var delegate: DuoProgressViewDelegate?
    
    init(delegate: DuoProgressViewDelegate?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        setupChildViews()
        applyCornerRadius(8)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, stackView, padding: 4)
        stackView.addArrangedSubviews(player1View, player2View, player3View, player4View)
    }
    
    func toggle(show: Bool, animated: Bool) {
        let interval = TimeInterval(integerLiteral: 1)
        
        UIView.animate(
            withDuration: interval,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5) {
                
            }
    }
    
    func updateWithPlayer(_ player: OSPlayer) {
        if winner1 == nil {
            winner1 = player
        } else if winner2 == nil {
            winner2 = player
        } else if loser1 == nil {
            loser1 = player
        } else {
            loser2 = player
        }
    }
    
    func reset() {
        winner1 = OSAccount.current.player
        winner2 = nil
        loser1 = nil
        loser2 = nil
    }
}

// MARK: - Player View

private let playerImageDiameter: CGFloat = 50
private let playerImageRadius = playerImageDiameter / 2

private final class PlayerView: UIView {
    
    private lazy var playerEmojiBackground: UIView = {
        let profileImageBackground = UIView.createView(.blue)
        profileImageBackground.applyCornerRadius((playerImageRadius - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var playerEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 50)
        return label
    }()
    
    private lazy var emptyPlayerImageView: UIImageView = {
        let image = UIImage(systemName: "person.crop.circle.badge.questionmark")!.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView.createImageView(image)
        imageView.tintColor = UIColor.OS.Text.disabled
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, playerEmojiBackground)
        NSLayoutConstraint.pinToView(playerEmojiBackground, playerEmojiLabel)
        NSLayoutConstraint.pinToView(playerEmojiBackground, emptyPlayerImageView)
    }
}
