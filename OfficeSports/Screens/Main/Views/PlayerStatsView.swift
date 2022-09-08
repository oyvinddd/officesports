//
//  PlayerStatsView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 07/09/2022.
//

import UIKit

final class PlayerStatsView: UIView {
    
    private lazy var pointsWrap: UIView = {
        return UIView.createView(UIColor.OS.General.pointsBackground, cornerRadius: 4)
    }()
    
    private lazy var pointsLabel: UILabel = {
        let label = UILabel.createLabel(.white)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.7
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.masksToBounds = false
        
        return label
    }()
    
    private lazy var totalWinsWrap: UIView = {
        return UIView.createView(UIColor.OS.General.totalWinsBackground, cornerRadius: 4)
    }()
    
    private lazy var totalWinsLabel: UILabel = {
        let label = UILabel.createLabel(.white)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.7
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.masksToBounds = false
        
        return label
    }()
    
    init(points: Int, totalWins: Int) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
        pointsLabel.text = "💎 x \(points)"
        totalWinsLabel.text = "🏆 x \(totalWins)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(pointsWrap)
        addSubview(totalWinsWrap)
        pointsWrap.addSubview(pointsLabel)
        totalWinsWrap.addSubview(totalWinsLabel)
        
        NSLayoutConstraint.activate([
            pointsWrap.leftAnchor.constraint(equalTo: leftAnchor),
            pointsWrap.topAnchor.constraint(equalTo: topAnchor),
            pointsWrap.bottomAnchor.constraint(equalTo: bottomAnchor),
            pointsWrap.rightAnchor.constraint(equalTo: totalWinsWrap.leftAnchor, constant: -8),
            pointsLabel.leftAnchor.constraint(equalTo: pointsWrap.leftAnchor, constant: 8),
            pointsLabel.rightAnchor.constraint(equalTo: pointsWrap.rightAnchor, constant: -8),
            pointsLabel.topAnchor.constraint(equalTo: pointsWrap.topAnchor, constant: 8),
            pointsLabel.bottomAnchor.constraint(equalTo: pointsWrap.bottomAnchor, constant: -8),
            totalWinsWrap.rightAnchor.constraint(equalTo: rightAnchor),
            totalWinsWrap.topAnchor.constraint(equalTo: topAnchor),
            totalWinsWrap.bottomAnchor.constraint(equalTo: bottomAnchor),
            totalWinsLabel.leftAnchor.constraint(equalTo: totalWinsWrap.leftAnchor, constant: 8),
            totalWinsLabel.rightAnchor.constraint(equalTo: totalWinsWrap.rightAnchor, constant: -8),
            totalWinsLabel.topAnchor.constraint(equalTo: totalWinsWrap.topAnchor, constant: 8),
            totalWinsLabel.bottomAnchor.constraint(equalTo: totalWinsWrap.bottomAnchor, constant: -8)
        ])
    }
}
