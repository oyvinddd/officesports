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
    
    private lazy var placementLabel: UILabel = {
        return UILabel.createLabel(.black)
    }()
    
    private lazy var usernameLabel: UILabel = {
        return UILabel.createLabel(.black)
    }()
    
    private lazy var scoreLabel: UILabel = {
        return UILabel.createLabel(.black, alignment: .right)
    }()
    
    var player: OSPlayer? {
        didSet {
            guard let player = player else {
                return
            }
            usernameLabel.text = player.username
            scoreLabel.text = "\(player.foosballScore)"
        }
    }
    
    var placement: Int? {
        0
    }
    
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
    
    private func setupChildViews() {
        contentView.addSubview(contentWrap)
        contentWrap.addSubview(placementLabel)
        contentWrap.addSubview(usernameLabel)
        contentWrap.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            contentWrap.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            contentWrap.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            placementLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 8),
            placementLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 8),
            placementLabel.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -8),
            usernameLabel.leftAnchor.constraint(equalTo: placementLabel.rightAnchor, constant: 8),
            usernameLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 8),
            usernameLabel.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -8),
            scoreLabel.leftAnchor.constraint(equalTo: usernameLabel.rightAnchor),
            scoreLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -8),
            scoreLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 8),
            scoreLabel.bottomAnchor.constraint(equalTo: contentWrap.bottomAnchor, constant: -8)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
}
