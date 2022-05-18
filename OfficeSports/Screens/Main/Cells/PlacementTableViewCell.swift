//
//  PlacementTableViewCell.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

final class PlacementTableViewCell: UITableViewCell {
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var profileImageWrap: UIView = {
        let view = UIView.createView(.red)
        view.applyCornerRadius(25)
        return view
    }()
    
    private lazy var profileEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var placementLabel: UILabel = {
        return UILabel.createLabel(UIColor.OS.Text.normal, alignment: .right)
    }()
    
    private let placementFontNormal = UIFont.boldSystemFont(ofSize: 18)
    private let placementFontEmoji = UIFont.systemFont(ofSize: 32)
    
    init() {
        super.init(style: .default, reuseIdentifier: String(describing: PlacementTableViewCell.self))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChildViews()
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setPlayerAndPlacement(_ player: OSPlayer, _ placement: Int) {
        profileImageWrap.backgroundColor = profileBackgroundColor(player.nickname)
        profileEmojiLabel.text = "🤬"
        usernameLabel.text = player.nickname.lowercased()
        scoreLabel.text = "\(player.foosballScore) pts"
        placementLabel.text = placementText(placement)
        placementLabel.font = placementFont(placement)
    }
    
    func applyCornerRadius(isFirstElement: Bool, isLastElement: Bool) {
        if isFirstElement {
            contentWrap.layer.cornerRadius = 15
            contentWrap.layer.maskedCorners = [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner
            ]
        } else if isLastElement {
            contentWrap.layer.cornerRadius = 15
            contentWrap.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        } else {
            contentWrap.layer.maskedCorners = []
        }
    }
    
    private func setupChildViews() {
        contentView.addSubview(contentWrap)
        contentWrap.addSubview(profileImageWrap)
        contentWrap.addSubview(usernameLabel)
        contentWrap.addSubview(scoreLabel)
        contentWrap.addSubview(placementLabel)
        
        NSLayoutConstraint.pinToView(profileImageWrap, profileEmojiLabel)
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            contentWrap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            contentWrap.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            profileImageWrap.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            profileImageWrap.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 16),
            profileImageWrap.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -16),
            profileImageWrap.heightAnchor.constraint(equalToConstant: 50),
            profileImageWrap.widthAnchor.constraint(equalTo: profileImageWrap.heightAnchor),
            usernameLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 16),
            usernameLabel.topAnchor.constraint(equalTo: profileImageWrap.topAnchor),
            usernameLabel.bottomAnchor.constraint(greaterThanOrEqualTo: scoreLabel.topAnchor),
            usernameLabel.rightAnchor.constraint(greaterThanOrEqualTo: placementLabel.leftAnchor, constant: -8),
            scoreLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 16),
            scoreLabel.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor),
            scoreLabel.rightAnchor.constraint(greaterThanOrEqualTo: placementLabel.leftAnchor, constant: -8),
            placementLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            placementLabel.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor),
            placementLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }

    private func placementText(_ placement: Int) -> String {
        switch placement {
        case 0:
            return "🥇"
        case 1:
            return "🥈"
        case 2:
            return "🥉"
        default:
            return "\(placement + 1)th"
        }
    }
    
    private func placementFont(_ placement: Int) -> UIFont {
        switch placement {
        case 0, 1, 2:
            return placementFontEmoji
        default:
            return placementFontNormal
        }
    }
    
    private func profileBackgroundColor(_ nickname: String) -> UIColor {
        return UIColor.OS.Profile.red
    }
}
