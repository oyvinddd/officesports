//
//  WelcomeViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import Combine
import AuthenticationServices
import FirebaseAuth

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
    
    private lazy var googleSignInButton: OSButton = {
        let button = OSButton("Sign in with Google", type: .primary)
        button.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var appleSignInButton: OSButton = {
        let button = OSButton("Sign in with Apple", type: .primary)
        button.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
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
    private var currentNonce: String?
    
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
                    self.googleSignInButton.toggleLoading(true)
                case .signInSuccess:
                    Coordinator.global.checkAndHandleAppState()
                case .signInFailure(let error):
                    self.googleSignInButton.toggleLoading(false)
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
        view.addSubview(googleSignInButton)
        view.addSubview(appleSignInButton)
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
            googleSignInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            googleSignInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            googleSignInButton.topAnchor.constraint(equalTo: tableTennisCircleView.bottomAnchor, constant: 64),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            appleSignInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            appleSignInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            appleSignInButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 20),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            versionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            versionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    @objc private func googleButtonTapped(_ sender: UIButton) {
        viewModel.signInWithGoogle(from: self)
    }
    
    @objc private func appleButtonTapped(_ sender: UIButton) {
        viewModel.signInWithApple(from: self)
    }
}

extension WelcomeViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                guard let error = error else {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

extension WelcomeViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }
}
