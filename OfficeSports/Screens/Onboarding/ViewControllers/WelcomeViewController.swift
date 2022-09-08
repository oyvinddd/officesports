//
//  WelcomeViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import Combine

final class WelcomeViewController: UIViewController {
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .center)
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.text = "Welcome to Office Sports! 🥳✨"
        label.applyLargeDropShadow(.black)
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
    
    private lazy var signInButton: OSButton = {
        let button = OSButton("Sign in with Google", type: .primary)
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var versionLabel: UILabel = {
        let text = "Version \(Bundle.main.appVersionNumber ?? "") (\(Bundle.main.appBuildNumber ?? "")) ⚡️"
        let label = UILabel.createLabel(.white, alignment: .center, text: text)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.alpha = 0.7
        return label
    }()
    
    private let viewModel: AuthViewModel
    private var subscribers = Set<AnyCancellable>()
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscribers()
        setupChildViews()
        configureUI()
    }
    
    private func setupSubscribers() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                switch state {
                case .loading:
                    self.signInButton.toggleLoading(true)
                case .signInSuccess:
                    Coordinator.global.checkAndHandleAppState()
                case .signInFailure(let error):
                    self.signInButton.toggleLoading(false)
                    Coordinator.global.send(OSMessage(error.localizedDescription, .failure))
                default:
                    // do nothing
                    return
                }
            }.store(in: &subscribers)
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
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    @objc private func signInButtonTapped(_ sender: UIButton) {
        viewModel.signIn(from: self)
    }
}
