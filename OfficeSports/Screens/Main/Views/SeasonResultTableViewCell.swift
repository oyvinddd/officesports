//
//  PlacementTableViewCell.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

private let winterEmoji = "❄️"
private let springEmoji = "🌿"
private let autumnEmoji = "🍁"
private let summerEmoji = "🏖"

final class SeasonResultTableViewCell: UITableViewCell {
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, yyyy"
        return dateFormatter
    }
    
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
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var seasonLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var seasonTypeLabel: UILabel = {
        return UILabel.createLabel(UIColor.OS.Text.normal, alignment: .right)
    }()
    
    init() {
        super.init(style: .default, reuseIdentifier: String(describing: SeasonResultTableViewCell.self))
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
    
    func configure(with season: OSSeasonStats, _ isFirst: Bool, _ isLast: Bool) {
        let winner = season.winner
        let dateString = SeasonResultTableViewCell.dateFormatter.string(from: season.date)
        var scoreString = ""
        if season.sport == .tableTennis, let score = winner.tableTennisStats?.score {
            scoreString = " • \(score) pts"
        } else if season.sport == .foosball, let score = winner.foosballStats?.score {
            scoreString = " • \(score) pts"
        }
        
        applyCornerRadius(isFirstElement: isFirst, isLastElement: isLast)
        profileImageWrap.backgroundColor = UIColor.OS.hashedProfileColor(winner.nickname)
        profileEmojiLabel.text = winner.emoji
        nicknameLabel.text = "\(winner.nickname.lowercased()) 👑"
        seasonLabel.text = "\(dateString)\(scoreString)"
        seasonTypeLabel.text = seasonTypeFromDate(season.date)
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
        contentWrap.addSubview(nicknameLabel)
        contentWrap.addSubview(seasonLabel)
        contentWrap.addSubview(seasonTypeLabel)
        
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
            nicknameLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 16),
            nicknameLabel.topAnchor.constraint(equalTo: profileImageWrap.topAnchor),
            nicknameLabel.rightAnchor.constraint(greaterThanOrEqualTo: seasonTypeLabel.leftAnchor, constant: -8),
            seasonLabel.leftAnchor.constraint(equalTo: profileImageWrap.rightAnchor, constant: 16),
            seasonLabel.bottomAnchor.constraint(equalTo: profileImageWrap.bottomAnchor),
            seasonLabel.rightAnchor.constraint(greaterThanOrEqualTo: seasonTypeLabel.leftAnchor, constant: -8),
            seasonTypeLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            seasonTypeLabel.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor),
            seasonTypeLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func seasonTypeFromDate(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.month], from: date)
        guard let month = components.month else {
            return ""
        }
        switch month {
        case 12, 1, 2:
            return winterEmoji
        case 3, 4, 5:
            return springEmoji
        case 6, 7, 8:
            return summerEmoji
        case 9, 10, 11:
            return autumnEmoji
        default:
            return ""
        }
    }
}
