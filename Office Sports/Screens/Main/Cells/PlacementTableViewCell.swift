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
        let view = UIView.createView(.yellow)
        view.applyCornerRadius(30)
        return view
    }()
    
    private lazy var profileEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    private lazy var placementLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        return UILabel.createLabel(UIColor.OS.Text.normal)
    }()
    
    private lazy var scoreLabel: UILabel = {
        return UILabel.createLabel(.black, alignment: .right)
    }()
    
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
        profileEmojiLabel.text = "🤬"
        usernameLabel.text = player.username.lowercased()
        scoreLabel.text = "\(player.foosballScore) pts"
        placementLabel.text = placementText(placement)
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
            usernameLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 8),
            usernameLabel.topAnchor.constraint(equalTo: profileImageWrap.topAnchor),
            usernameLabel.bottomAnchor.constraint(greaterThanOrEqualTo: scoreLabel.topAnchor, constant: 8),
            scoreLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 8),
            scoreLabel.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor),
            placementLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            placementLabel.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor)
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
}
