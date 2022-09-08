//
//  MetricsView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 06/09/2022.
//

import UIKit

final class MetricsView: UIView {
    
    private lazy var metricLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.white)
        label.font = UIFont.systemFont(ofSize: 29, weight: .semibold)
        label.alpha = 0.9
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.white)
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.alpha = 0.7
        return label
    }()
    
    init(metric: String, title: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
        self.backgroundColor = backgroundColor
        applyMediumDropShadow(.black)
        applyCornerRadius(10)
        metricLabel.text = metric
        titleLabel.text = title.uppercased()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(metricLabel)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            metricLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            metricLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            metricLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            metricLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -40),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
