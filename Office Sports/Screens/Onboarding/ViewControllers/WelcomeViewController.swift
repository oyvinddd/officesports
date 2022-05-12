//
//  WelcomeViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

final class WelcomeViewController: UIViewController {

    private lazy var welcomeLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center)
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.text = "Welcome to Office Sports!"
        return label
    }()
    
    private lazy var foosballCircleView: CircleView = {
        let circleView = CircleView(.white, text: "⚽️")
        circleView.applyCornerRadius(45)
        return circleView
    }()
    
    private lazy var tableTennisCircleView: CircleView = {
        let circleView = CircleView(.white, text: "🏓")
        circleView.applyCornerRadius(45)
        return circleView
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton.createButton(.white, UIColor.OfficeSports.main, title: "Sign in with Google")
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        configureUI()
    }
    
    private func setupChildViews() {
        view.addSubview(welcomeLabel)
        view.addSubview(foosballCircleView)
        view.addSubview(tableTennisCircleView)
        view.addSubview(signInButton)
        
        NSLayoutConstraint.activate([
            welcomeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            welcomeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64),
            welcomeLabel.bottomAnchor.constraint(equalTo: foosballCircleView.topAnchor, constant: -64),
            foosballCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            foosballCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 26),
            foosballCircleView.widthAnchor.constraint(equalToConstant: 90),
            foosballCircleView.heightAnchor.constraint(equalTo: foosballCircleView.widthAnchor),
            tableTennisCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 12),
            tableTennisCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -26),
            tableTennisCircleView.widthAnchor.constraint(equalToConstant: 90),
            tableTennisCircleView.heightAnchor.constraint(equalTo: tableTennisCircleView.widthAnchor),
            signInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            signInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64),
            signInButton.topAnchor.constraint(equalTo: tableTennisCircleView.bottomAnchor, constant: 64),
            signInButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OfficeSports.main
    }
    
    @objc private func signInButtonTapped(_ sender: UIButton) {
        print("signed in")
    }
}
