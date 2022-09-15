//
//  InviteTableViewCell.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 10/06/2022.
//

import UIKit

final class InviteTableViewCell: UITableViewCell {
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var sportImageWrap: UIView = {
        return UIView.createView(.black, cornerRadius: 23)
    }()
    
    private lazy var sportEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    private lazy var playerLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle, text: "2 hours a go")
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    init() {
        super.init(style: .default, reuseIdentifier: String(describing: InviteTableViewCell.self))
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
    
    func configure(with invite: OSInvite, _ isLast: Bool) {
        applyCornerRadius(isLastElement: isLast)
        sportImageWrap.backgroundColor = UIColor.OS.colorForSport(invite.sport)
        sportEmojiLabel.text = invite.sport.emoji
        playerLabel.text = "Invite from \(invite.inviteeNickname)!"
    }
    
    private func setupChildViews() {
        contentView.addSubview(contentWrap)
        contentWrap.addSubview(sportImageWrap)
        contentWrap.addSubview(timestampLabel)
        contentWrap.addSubview(playerLabel)
        
        NSLayoutConstraint.pinToView(sportImageWrap, sportEmojiLabel)
        
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            contentWrap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            contentWrap.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            sportImageWrap.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            sportImageWrap.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 16),
            sportImageWrap.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -16),
            sportImageWrap.heightAnchor.constraint(equalToConstant: 46),
            sportImageWrap.widthAnchor.constraint(equalTo: sportImageWrap.heightAnchor),
            playerLabel.leftAnchor.constraint(equalTo: sportImageWrap.rightAnchor, constant: 16),
            playerLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            playerLabel.topAnchor.constraint(equalTo: sportImageWrap.topAnchor),
            timestampLabel.leftAnchor.constraint(equalTo: sportImageWrap.rightAnchor, constant: 16),
            timestampLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            timestampLabel.bottomAnchor.constraint(equalTo: sportImageWrap.bottomAnchor)
        ])
    }
    
    private func applyCornerRadius(isLastElement: Bool) {
        guard isLastElement else {
            contentWrap.layer.maskedCorners = []
            return
        }
        var mask = CACornerMask()
        if isLastElement {
            mask.insert(.layerMinXMaxYCorner)
            mask.insert(.layerMaxXMaxYCorner)
        }
        contentWrap.layer.cornerRadius = 15
        contentWrap.layer.maskedCorners = mask
    }
}
