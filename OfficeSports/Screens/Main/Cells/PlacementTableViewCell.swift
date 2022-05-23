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
        view.applyCornerRadius(23)
        return view
    }()
    
    private lazy var profileEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.boldSystemFont(ofSize: 20)
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
    private let placementFontEmoji = UIFont.systemFont(ofSize: 28)
    
    init() {
        super.init(style: .default, reuseIdentifier: String(describing: PlacementTableViewCell.self))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupChildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with player: OSPlayer, _ placement: Int, _ isFirst: Bool, _ isLast: Bool) {
        applyCornerRadius(isFirstElement: isFirst, isLastElement: isLast)
        configurePlacementLabel(placement, isLast: isLast)
        profileImageWrap.backgroundColor = UIColor.OS.hashedProfileColor(nickname: player.nickname)
        profileEmojiLabel.text = player.emoji
        usernameLabel.text = player.nickname.lowercased()
        scoreLabel.text = "\(player.foosballScore) pts"
    }
    
    private func applyCornerRadius(isFirstElement: Bool, isLastElement: Bool) {
        guard isFirstElement || isLastElement else {
            contentWrap.layer.maskedCorners = []
            return
        }
        
        var mask = CACornerMask()
        if isFirstElement {
            mask.insert(.layerMaxXMinYCorner)
            mask.insert(.layerMinXMinYCorner)
        }
        if isLastElement {
            mask.insert(.layerMinXMaxYCorner)
            mask.insert(.layerMaxXMaxYCorner)
        }
        contentWrap.layer.cornerRadius = 15
        contentWrap.layer.maskedCorners = mask
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
            profileImageWrap.heightAnchor.constraint(equalToConstant: 46),
            profileImageWrap.widthAnchor.constraint(equalTo: profileImageWrap.heightAnchor),
            usernameLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 16),
            usernameLabel.topAnchor.constraint(equalTo: profileImageWrap.topAnchor),
            usernameLabel.rightAnchor.constraint(greaterThanOrEqualTo: placementLabel.leftAnchor, constant: -8),
            scoreLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 16),
            scoreLabel.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor),
            scoreLabel.rightAnchor.constraint(greaterThanOrEqualTo: placementLabel.leftAnchor, constant: -8),
            placementLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            placementLabel.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor),
            placementLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configurePlacementLabel(_ placement: Int, isLast: Bool) {
        // configure font
        if placement == 0 || placement == 1 || placement == 2 || isLast {
            placementLabel.font = placementFontEmoji
        } else {
            placementLabel.font = placementFontNormal
        }
        // configure text label
        switch placement {
        case 0:
            placementLabel.text = "🥇"
        case 1:
            placementLabel.text = "🥈"
        case 2:
            placementLabel.text = "🥉"
        default:
            placementLabel.text = "\(placement + 1)th"
        }
        if isLast {
            placementLabel.text = "💩"
        }
    }
}
