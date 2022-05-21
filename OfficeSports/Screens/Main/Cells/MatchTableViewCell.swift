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
    
    private lazy var winnerProfileImageWrap: UIView = {
        let view = UIView.createView(.red)
        view.applyCornerRadius(23)
        return view
    }()
    
    private lazy var winnerProfileEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 28)
        return label
    }()
    
    private lazy var winnerNicknameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private lazy var loserProfileImageWrap: UIView = {
        let view = UIView.createView(.red)
        view.applyCornerRadius(23)
        return view
    }()
    
    private lazy var loserProfileEmojiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 28)
        return label
    }()
    
    private lazy var loserNicknameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .right)
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private lazy var winnerDeltaLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.backgroundColor = UIColor.OS.General.success
        label.applyCornerRadius(5)
        return label
    }()
    
    private lazy var loserDeltaLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.backgroundColor = UIColor.OS.General.failure
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        return UILabel.createLabel(UIColor.OS.Text.subtitle)
    }()
    
    private lazy var versusLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center, text: "VS")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.backgroundColor = UIColor.OS.Text.subtitle
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
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
        contentWrap.addSubview(winnerNicknameLabel)
        contentWrap.addSubview(winnerDeltaLabel)
        contentWrap.addSubview(loserNicknameLabel)
        contentWrap.addSubview(loserDeltaLabel)
        contentWrap.addSubview(versusLabel)
        
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            contentWrap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            contentWrap.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            winnerNicknameLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            winnerNicknameLabel.rightAnchor.constraint(equalTo: versusLabel.leftAnchor, constant: -8),
            winnerNicknameLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 16),
            winnerDeltaLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            winnerDeltaLabel.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -16),
            winnerDeltaLabel.topAnchor.constraint(equalTo: winnerNicknameLabel.bottomAnchor, constant: 4),
            winnerDeltaLabel.heightAnchor.constraint(equalToConstant: 20),
            loserNicknameLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            loserNicknameLabel.leftAnchor.constraint(equalTo: versusLabel.rightAnchor, constant: 8),
            loserNicknameLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 16),
            loserDeltaLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            loserDeltaLabel.topAnchor.constraint(equalTo: loserNicknameLabel.bottomAnchor, constant: 4),
            loserDeltaLabel.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -16),
            loserDeltaLabel.heightAnchor.constraint(equalToConstant: 20),
            versusLabel.centerXAnchor.constraint(equalTo: contentWrap.centerXAnchor),
            versusLabel.centerYAnchor.constraint(equalTo: contentWrap.centerYAnchor),
            versusLabel.widthAnchor.constraint(equalToConstant: 40),
            versusLabel.heightAnchor.constraint(equalToConstant: 20)
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
        winnerNicknameLabel.text = match.winner.nickname.lowercased()
        winnerDeltaLabel.text = "+\(match.winnerDelta)"
        loserNicknameLabel.text = match.loser.nickname.lowercased()
        loserDeltaLabel.text = "\(match.loserDelta)"
    }
}
