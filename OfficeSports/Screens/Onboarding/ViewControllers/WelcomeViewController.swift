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
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.text = "Welcome to Office Sports! 🥹"
        return label
    }()
    
    private lazy var foosballCircleView: CircleView = {
        let circleView = CircleView(UIColor.OS.Profile.color12, .white, text: "⚽️")
        circleView.applyMediumDropShadow(.black)
        circleView.applyCornerRadius(50)
        return circleView
    }()
    
    private lazy var tableTennisCircleView: CircleView = {
        let circleView = CircleView(UIColor.OS.Profile.color1, .white, text: "🏓")
        circleView.applyMediumDropShadow(.black)
        circleView.applyCornerRadius(50)
        return circleView
    }()
    
    private lazy var signInButton: AppButton = {
        //let button = UIButton.createButton(.white, UIColor.OS.General.main, UIColor.OS.General.mainDark, title: "Sign in with Google")
        let button = AppButton.main("Sign in with Google")
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var versionLabel: UILabel = {
        let text = "Version \(Bundle.main.appVersionNumber ?? "") (\(Bundle.main.appBuildNumber ?? ""))"
        let label = UILabel.createLabel(.white, alignment: .center, text: text)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.alpha = 0.5
        return label
    }()
    
    private let viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        view.backgroundColor = UIColor.OS.General.main
    }
    
    private func setupChildViews() {
        view.addSubview(welcomeLabel)
        view.addSubview(foosballCircleView)
        view.addSubview(tableTennisCircleView)
        view.addSubview(signInButton)
        view.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            welcomeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            welcomeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64),
            welcomeLabel.bottomAnchor.constraint(equalTo: foosballCircleView.topAnchor, constant: -64),
            foosballCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -8),
            foosballCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 26),
            foosballCircleView.widthAnchor.constraint(equalToConstant: 100),
            foosballCircleView.heightAnchor.constraint(equalTo: foosballCircleView.widthAnchor),
            tableTennisCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 12),
            tableTennisCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -26),
            tableTennisCircleView.widthAnchor.constraint(equalToConstant: 100),
            tableTennisCircleView.heightAnchor.constraint(equalTo: tableTennisCircleView.widthAnchor),
            signInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            signInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64),
            signInButton.topAnchor.constraint(equalTo: tableTennisCircleView.bottomAnchor, constant: 64),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            versionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            versionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func signInButtonTapped(_ sender: UIButton) {
        viewModel.signIn(from: self)
    }
}

// MARK: - Auth View Model Delegate Conformance

extension WelcomeViewController: AuthViewModelDelegate {

    func signedInSuccessfully() {
        Coordinator.global.checkAndHandleAppState()
    }
    
    func signInFailed(with error: Error) {
        Coordinator.global.showMessage(OSMessage(error.localizedDescription, .failure))
    }
    
    func shouldToggleLoading(enabled: Bool) {
        signInButton.toggleLoading(enabled)
    }
}
