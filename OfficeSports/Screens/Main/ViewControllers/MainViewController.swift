//
//  MainViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

private let scannerFadeDuration: TimeInterval = 0.2 // seconds
private let scannerDelayDuration: TimeInterval = 0  // seconds

final class MainViewController: UIViewController {
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(UIColor.OS.General.background)
    }()
    
    private lazy var profileView: ProfileView = {
        return ProfileView(account: OSAccount.current, delegate: self)
    }()
    
    private lazy var scrollView: UIScrollView = {
        return UIScrollView.createScrollView(.clear, delegate: self)
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal)
    }()
    
    private lazy var floatingMenu: FloatingMenu = {
        return FloatingMenu(delegate: self)
    }()
    
    private lazy var scannerViewController: ScannerViewController = {
        let viewModel = ScannerViewModel(api: FirebaseSportsAPI())
        return ScannerViewController(viewModel: viewModel)
    }()
    
    private lazy var invitesViewController: InvitesViewController = {
        let viewModel = InvitesViewModel(api: FirebaseSportsAPI())
        return InvitesViewController(viewModel: viewModel)
    }()
    
    private lazy var foosballViewController: SportViewController = {
        let viewModel = SportViewModel(api: MockSportsAPI(), sport: .foosball)
        return SportViewController(viewModel: viewModel)
    }()
    
    private lazy var tableTennisViewController: SportViewController = {
        let viewModel = SportViewModel(api: MockSportsAPI(), sport: .tableTennis)
        return SportViewController(viewModel: viewModel)
    }()
    
    private var cameraIsShowing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        setupChildViewControllers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureTableViewInsets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToViewController(foosballViewController)
    }
    
    private func setupChildViews() {
        
        view.addSubview(scannerViewController.view!)
        
        NSLayoutConstraint.pinToView(view, contentWrap)
        
        contentWrap.addSubview(profileView)
        
        NSLayoutConstraint.pinToView(contentWrap, scrollView)
        
        scrollView.addSubview(stackView)
        
        view.addSubview(floatingMenu)
        
        NSLayoutConstraint.activate([
            profileView.leftAnchor.constraint(equalTo: contentWrap.leftAnchor),
            profileView.rightAnchor.constraint(equalTo: contentWrap.rightAnchor),
            profileView.topAnchor.constraint(equalTo: contentWrap.topAnchor),
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
        scannerViewController.didMove(toParent: self)
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
    
    private func configureTableViewInsets() {
        let profileMaxY = profileView.bounds.maxY
        let menuMinY = floatingMenu.bounds.maxY
        let contentInset = UIEdgeInsets(top: profileMaxY, left: 0, bottom: menuMinY, right: 0)
        foosballViewController.applyContentInsetToTableView(contentInset)
        tableTennisViewController.applyContentInsetToTableView(contentInset)
    }
    
    private func scrollToViewController(_ viewController: UIViewController, animated: Bool = false) {
        scrollView.scrollRectToVisible(viewController.view.frame, animated: animated)
    }
}

// MARK: - Profile view delegate conformance

extension MainViewController: ProfileViewDelegate {
    
    func settingsButtonTapped() {
        Coordinator.global.presentSettings(from: self)
    }
}

// MARK: - Floating Menu Delegate Conformance

extension MainViewController: FloatingMenuDelegate {
    
    func displayCodeButtonTapped() {
        foosballViewController.scrollTableViewToTop(animated: true)
        profileView.displayQrCode(seconds: 3)
    }
    
    func toggleCameraButtonTapped() {
        if cameraIsShowing {
            scannerViewController.stopCaptureSession()
        } else {
            scannerViewController.startCaptureSession()
        }
        floatingMenu.toggleCameraMode(enabled: !cameraIsShowing)
        
        UIView.animate(
            withDuration: scannerFadeDuration,
            delay: scannerDelayDuration) { [unowned self] in
                self.contentWrap.alpha = cameraIsShowing ? 1 : 0
            }
        cameraIsShowing = !cameraIsShowing
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

// MARK: - Scroll View Delegate Conformance

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let width = scrollView.frame.width
        if xOffset == 0 { // invites screen is showing
            // do something
        } else if xOffset < width * 2 { // foosball screen is showing
            profileView.displayDetailsForSport(.foosball)
        } else if xOffset >= width * 2 { // table tennis screen is showing
            profileView.displayDetailsForSport(.tableTennis)
        }
    }
}
