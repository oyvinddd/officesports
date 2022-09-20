//
//  DuoProgressView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 16/09/2022.
//

import UIKit

private let playerImageDiameter: CGFloat = 50
private let playerImageRadius = playerImageDiameter / 2

final class DuoProgressView: UIView {
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal)
    }()
    
    private lazy var player1ImageWrap: UIView = {
        let imageWrap = UIView.createView(.white, cornerRadius: playerImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var player1ImageBackground: UIView = {
        let profileImageBackground = UIView.createView(.blue)
        profileImageBackground.applyCornerRadius((playerImageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var player2ImageWrap: UIView = {
        let imageWrap = UIView.createView(.white, cornerRadius: playerImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var player2ImageBackground: UIView = {
        let profileImageBackground = UIView.createView(.blue)
        profileImageBackground.applyCornerRadius((playerImageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var player3ImageWrap: UIView = {
        let imageWrap = UIView.createView(.white, cornerRadius: playerImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var player3ImageBackground: UIView = {
        let profileImageBackground = UIView.createView(.blue)
        profileImageBackground.applyCornerRadius((playerImageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var player4ImageWrap: UIView = {
        let imageWrap = UIView.createView(.white, cornerRadius: playerImageRadius)
        imageWrap.applyMediumDropShadow(.black)
        return imageWrap
    }()
    
    private lazy var player4ImageBackground: UIView = {
        let profileImageBackground = UIView.createView(.blue)
        profileImageBackground.applyCornerRadius((playerImageDiameter - 16) / 2)
        return profileImageBackground
    }()
    
    private lazy var cancelButton: OSButton = {
        let button = OSButton("Cancel", type: .secondaryInverted)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        setupChildViews()
        applyCornerRadius(8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(stackView)
        addSubview(cancelButton)
        
        stackView.addArrangedSubviews(player1ImageWrap, player2ImageWrap, player3ImageWrap, player4ImageWrap)
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            cancelButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            player1ImageWrap.widthAnchor.constraint(equalToConstant: playerImageDiameter),
            player1ImageWrap.heightAnchor.constraint(equalTo: player1ImageWrap.widthAnchor)
        ])
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        
    }
}
