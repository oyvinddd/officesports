//
//  MainViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import AVFoundation

private let scannerFadeDuration: TimeInterval = 0.2 // seconds

final class MainViewController: UIViewController {
    
    private lazy var activateCameraDescription: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .left, text: "You need to activate the camera in order to register match scores.")
        return label
    }()
    
    private lazy var activateCameraButton: UIButton = {
        let button = UIButton.createButton(.white, UIColor.OS.General.main, title: "Activate camera")
        button.addTarget(self, action: #selector(activateCameraButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(UIColor.OS.General.background)
    }()
    
    private lazy var profileView: ProfileView = {
        return ProfileView(account: OSAccount.current, delegate: self)
    }()
    
    private lazy var scrollView: UIScrollView = {
        return UIScrollView.createScrollView(.clear)
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal)
    }()
    
    private lazy var floatingMenu: FloatingMenu = {
        return FloatingMenu(delegate: self)
    }()
    
    private lazy var invitesViewController: InvitesViewController = {
        let viewModel = InvitesViewModel(api: FirebaseSportsAPI())
        return InvitesViewController(viewModel: viewModel)
    }()
    
    private lazy var foosballViewController: SportViewController = {
        let viewModel = ScoreboardViewModel(api: FirebaseSportsAPI(), sport: .foosball)
        return SportViewController(viewModel: viewModel)
    }()
    
    private lazy var tableTennisViewController: SportViewController = {
        let viewModel = ScoreboardViewModel(api: FirebaseSportsAPI(), sport: .tableTennis)
        return SportViewController(viewModel: viewModel)
    }()
    
    private var isDisplayingScanner: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        setupChildViewControllers()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureTableViewInsets()
    }
    
    private func setupChildViews() {
        view.addSubview(activateCameraDescription)
        view.addSubview(activateCameraButton)
        
        NSLayoutConstraint.pinToView(view, contentWrap)
        
        contentWrap.addSubview(profileView)
        
        NSLayoutConstraint.pinToView(contentWrap, scrollView)
        
        scrollView.addSubview(stackView)
        
        view.addSubview(floatingMenu)
        
        NSLayoutConstraint.activate([
            activateCameraDescription.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            activateCameraDescription.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            activateCameraDescription.bottomAnchor.constraint(equalTo: activateCameraButton.topAnchor, constant: -16),
            activateCameraButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            activateCameraButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            activateCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activateCameraButton.heightAnchor.constraint(equalToConstant: 50),
            profileView.leftAnchor.constraint(equalTo: contentWrap.leftAnchor),
            profileView.rightAnchor.constraint(equalTo: contentWrap.rightAnchor),
            profileView.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 64),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            floatingMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            floatingMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64),
            floatingMenu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingMenu.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func setupChildViewControllers() {
        
        invitesViewController.didMove(toParent: self)
        foosballViewController.didMove(toParent: self)
        tableTennisViewController.didMove(toParent: self)
        
        let invitesView = invitesViewController.view!
        let foosballView = foosballViewController.view!
        let tableTennisView = tableTennisViewController.view!
        
        stackView.addArrangedSubview(invitesView)
        stackView.addArrangedSubview(foosballView)
        stackView.addArrangedSubview(tableTennisView)
        
        NSLayoutConstraint.activate([
            invitesView.widthAnchor.constraint(equalTo: view.widthAnchor),
            invitesView.heightAnchor.constraint(equalTo: view.heightAnchor),
            foosballView.widthAnchor.constraint(equalTo: view.widthAnchor),
            foosballView.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableTennisView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableTennisView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OS.General.main
    }
    
    private func configureTableViewInsets() {
        let padding: CGFloat = 32
        let profileMaxY = profileView.bounds.maxY + padding
        let menuMinY = floatingMenu.bounds.maxY + padding
        let contentInset = UIEdgeInsets(top: profileMaxY, left: 0, bottom: menuMinY, right: 0)
        foosballViewController.applyContentInsetToTableView(contentInset)
        tableTennisViewController.applyContentInsetToTableView(contentInset)
    }
    
    @objc private func activateCameraButtonTapped(_ sender: UIButton) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupCaptureSession()
                }
            }
        case .denied:
            // user has previously denied access
            return
        case .restricted:
            // user can't grant access due to restriction
            return
        default:
            // ...
            return
        }
    }
}

// MARK: - Profile view delegate conformance

extension MainViewController: ProfileViewDelegate {
    
    func settingsButtonTapped() {
        present(SettingsViewController(), animated: false)
    }
}

// MARK: - Floating Menu Delegate Conformance

extension MainViewController: FloatingMenuDelegate {
    
    func displayCodeButtonTapped() {
        foosballViewController.scrollTableViewToTop(animated: true)
        profileView.displayQrCode(seconds: 0)
    }
    
    func registerMatchButtonTapped() {
        guard !isDisplayingScanner else {
            return
        }
        isDisplayingScanner = true
        UIView.animate(
            withDuration: scannerFadeDuration,
            delay: 0,
            options: [.curveEaseInOut]) { [weak self] in
                self?.contentWrap.alpha = 0
            } completion: { [weak self] _ in
                self?.isDisplayingScanner = false
            }
    }
    
    func changeSportsButtonTapped() {
        let foosballFrame = foosballViewController.view.frame
        let tableTennisFrame = tableTennisViewController.view.frame
        let xOffset = scrollView.contentOffset.x
        
        guard xOffset == 0 || xOffset == tableTennisFrame.minX else {
            return
        }
        let frame = xOffset > 0 ? foosballFrame : tableTennisFrame
        scrollView.scrollRectToVisible(frame, animated: true)
    }
}

// MARK: - Scanner

extension MainViewController {
    
    private func setupCaptureSession() {
        
    }
}
