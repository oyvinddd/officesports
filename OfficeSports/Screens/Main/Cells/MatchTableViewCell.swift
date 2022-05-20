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
        return UILabel.createLabel(UIColor.OS.Text.normal)
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
        return UILabel.createLabel(UIColor.OS.Text.normal)
    }()
    
    var match: OSMatch?
    
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
        contentWrap.addSubview(winnerProfileImageWrap)
        contentWrap.addSubview(winnerNicknameLabel)
        contentWrap.addSubview(loserProfileImageWrap)
        contentWrap.addSubview(loserNicknameLabel)
        
        NSLayoutConstraint.pinToView(winnerProfileImageWrap, winnerProfileEmojiLabel)
        NSLayoutConstraint.pinToView(loserProfileImageWrap, loserProfileEmojiLabel)
        
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            contentWrap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            contentWrap.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            winnerProfileImageWrap.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            winnerProfileImageWrap.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 16),
            winnerProfileImageWrap.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -16),
            winnerProfileImageWrap.heightAnchor.constraint(equalToConstant: 46),
            winnerProfileImageWrap.widthAnchor.constraint(equalTo: winnerProfileImageWrap.heightAnchor),
            winnerNicknameLabel.leftAnchor.constraint(equalTo: winnerProfileImageWrap.rightAnchor, constant: 16),
            winnerNicknameLabel.topAnchor.constraint(equalTo: winnerProfileImageWrap.topAnchor)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
}
