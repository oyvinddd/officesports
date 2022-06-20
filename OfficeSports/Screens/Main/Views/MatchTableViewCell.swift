//
//  MatchTableViewCell.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 20/05/2022.
//

import UIKit

final class MatchTableViewCell: UITableViewCell {
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.white)
    }()
    
    private lazy var matchDateLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.subtitle)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var matchResultLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    var match: OSMatch? {
        didSet {
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChildViews()
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func applyCornerRadius(isFirstElement: Bool, isLastElement: Bool) {
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
        contentWrap.addSubview(matchDateLabel)
        contentWrap.addSubview(matchResultLabel)
        
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            contentWrap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            contentWrap.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            matchDateLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            matchDateLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            matchDateLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 16),
            matchResultLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            matchResultLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            matchResultLabel.topAnchor.constraint(equalTo: matchDateLabel.bottomAnchor, constant: 4),
            matchResultLabel.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func updateUI() {
        guard let match = match else {
            return
        }
        let winner = match.winner.nickname
        let wDelta = match.winnerDelta
        let loser = match.loser.nickname
        let lDelta = match.loserDelta
        let originalStr = "\(winner) (+\(wDelta)) won against \(loser) (\(lDelta))"
        
        let attrStr = NSMutableAttributedString(string: originalStr)
        let rangeOfWinner = NSString(string: originalStr).range(of: winner)
        let rangeOfLoser = NSString(string: originalStr).range(of: loser)
        let rangeOfWdt = NSString(string: originalStr).range(of: "+\(wDelta)", options: .caseInsensitive)
        let rangeOfLdt = NSString(string: originalStr).range(of: "\(lDelta)", options: .caseInsensitive)
        
        attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .bold), range: rangeOfWinner)
        attrStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .bold), range: rangeOfLoser)
        attrStr.addAttribute(.foregroundColor, value: UIColor.OS.Status.success, range: rangeOfWdt)
        attrStr.addAttribute(.foregroundColor, value: UIColor.OS.Status.failure, range: rangeOfLdt)
        
        matchDateLabel.text = match.dateToString()
        matchResultLabel.attributedText = attrStr
    }
}
