//
//  PlacementTableViewCell.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

private let firstPlace = "🥇"
private let secondPlace = "🥈"
private let thirdPlace = "🥉"
private let lastPlace = "💩"

private let activeIndicatorDiameter: CGFloat = 16
private let activeIndicatorRadius = activeIndicatorDiameter / 2

final class PlacementTableViewCell: UITableViewCell {
    
    private lazy var contentWrap: UIView = {
        let view = UIView.createView(.white)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var profileImageWrap: UIView = {
        return UIView.createView(.black, cornerRadius: 23)
    }()
    
    private lazy var profileEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var separator: UIView = {
        return UIView.createView(UIColor.OS.General.separator)
    }()
    
    private lazy var placementLabel: UILabel = {
        return UILabel.createLabel(UIColor.OS.Text.normal, alignment: .right)
    }()
    
    private lazy var specialIndicatorLabel: UILabel = {
        return UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center)
    }()
    
    private lazy var activeIndicatorWrap: UIView = {
        let view = UIView.createView(.white, cornerRadius: activeIndicatorRadius)
        NSLayoutConstraint.pinToView(view, activeIndicatorView, padding: 2.4)
        return view
    }()
    
    private lazy var activeIndicatorView: UIView = {
        return UIView.createView(UIColor.OS.Text.disabled, cornerRadius: activeIndicatorRadius - 2.4)
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
    
    // swiftlint:disable function_parameter_count
    func configure(with player: OSPlayer, _ sport: OSSport, _ placement: Int, _ isFanatical: Bool, _ isMostBoring: Bool, _ isFirst: Bool, _ isLast: Bool) {
        applyCornerRadius(isFirstElement: isFirst, isLastElement: isLast)
        configurePlacementLabel(placement, isLast: isLast)
        configureSpecialLabel(isFanatical, isMostBoring)
        configureActiveStatus(player: player)
        profileImageWrap.backgroundColor = UIColor.OS.hashedProfileColor(player.nickname)
        profileEmojiLabel.text = player.emoji
        usernameLabel.text = player.nickname.lowercased()
        scoreLabel.text = "\(player.points(sport)) pts"
        separator.isHidden = isLast
    }
    
    func configure(with player: OSPlayer, _ sport: OSSport, _ isFirst: Bool, _ isLast: Bool) {
        configure(with: player, sport, -1, false, false, isFirst, isLast)
        scoreLabel.text = "No matches played"
        placementLabel.text = ""
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
        contentWrap.addSubview(specialIndicatorLabel)
        contentWrap.addSubview(separator)
        contentWrap.addSubview(activeIndicatorWrap)
        
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
            usernameLabel.rightAnchor.constraint(greaterThanOrEqualTo: specialIndicatorLabel.leftAnchor, constant: -8),
            scoreLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 16),
            scoreLabel.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor),
            scoreLabel.rightAnchor.constraint(greaterThanOrEqualTo: specialIndicatorLabel.leftAnchor, constant: -8),
            placementLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            placementLabel.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor),
            placementLabel.widthAnchor.constraint(equalToConstant: 50),
            specialIndicatorLabel.rightAnchor.constraint(equalTo: placementLabel.leftAnchor, constant: 8),
            specialIndicatorLabel.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor),
            specialIndicatorLabel.widthAnchor.constraint(equalToConstant: 30),
            separator.leftAnchor.constraint(equalTo: contentWrap.leftAnchor),
            separator.rightAnchor.constraint(equalTo: contentWrap.rightAnchor),
            separator.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            activeIndicatorWrap.widthAnchor.constraint(equalToConstant: activeIndicatorDiameter),
            activeIndicatorWrap.heightAnchor.constraint(equalTo: activeIndicatorWrap.widthAnchor),
            activeIndicatorWrap.rightAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 3),
            activeIndicatorWrap.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor)
        ])
    }
    
    private func configurePlacementLabel(_ placement: Int, isLast: Bool) {
        // configure font
        if placement == 0 || placement == 1 || placement == 2 || isLast {
            placementLabel.font = placementFontEmoji
            specialIndicatorLabel.font = placementFontEmoji
        } else {
            placementLabel.font = placementFontNormal
            specialIndicatorLabel.font = placementFontNormal
        }
        // configure text label
        switch placement {
        case 0:
            placementLabel.text = firstPlace
        case 1:
            placementLabel.text = secondPlace
        case 2:
            placementLabel.text = thirdPlace
        default:
            placementLabel.text = "\(placement + 1)th"
        }
        if isLast {
            placementLabel.text = lastPlace
        }
    }
    
    private func configureSpecialLabel(_ isFanatical: Bool, _ isMostBoring: Bool) {
        if isFanatical {
            specialIndicatorLabel.text = "🔥"
        } else if isMostBoring {
            specialIndicatorLabel.text = "🧊"
        } else {
            specialIndicatorLabel.text = ""
        }
    }
    
    private func configureActiveStatus(player: OSPlayer) {
        if player.wasRecentlyActive() {
            activeIndicatorView.backgroundColor = UIColor.OS.Status.success
        } else {
            activeIndicatorView.backgroundColor = UIColor.OS.Text.disabled
        }
    }
}
