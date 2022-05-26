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
    
    private lazy var sportAndProfileWrap: UIView = {
        return UIView.createView(UIColor.OS.General.background)
    }()
    
    private lazy var profileView: ProfileView = {
        return ProfileView(account: OSAccount.current)
    }()
    
    private lazy var settingsButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold, scale: .large)
        let image = UIImage(systemName: "gearshape.fill", withConfiguration: config)
        let button = UIButton.createButton(.clear, .clear, title: nil)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.OS.Text.normal
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var outerScrollView: UIScrollView = {
        let scrollView = UIScrollView.createScrollView(.clear, delegate: self)
        scrollView.bounces = false
        return scrollView
    }()
    
    private lazy var innerScrollView: UIScrollView = {
        let scrollView = UIScrollView.createScrollView(.clear, delegate: self)
        scrollView.bounces = false
        return scrollView
    }()

    private lazy var outerStackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal)
    }()
    
    private lazy var innerStackView: UIStackView = {
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
        return SportViewController(viewModel: viewModel, delegate: self)
    }()
    
    private lazy var tableTennisViewController: SportViewController = {
        let viewModel = SportViewModel(api: MockSportsAPI(), sport: .tableTennis)
        return SportViewController(viewModel: viewModel, delegate: self)
    }()
    
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
        
        NSLayoutConstraint.pinToView(view, outerScrollView)
        
        //NSLayoutConstraint.pinToView(view, contentWrap)
        
        sportAndProfileWrap.addSubview(profileView)
        
        NSLayoutConstraint.pinToView(sportAndProfileWrap, innerScrollView)
        
        outerScrollView.addSubview(outerStackView)
        innerScrollView.addSubview(innerStackView)
        
        let placeholderView = UIView.createView(.clear)
        outerStackView.addArrangedSubview(placeholderView)
        outerStackView.addArrangedSubview(sportAndProfileWrap)
        
        view.addSubview(settingsButton)
        view.addSubview(floatingMenu)
        
        NSLayoutConstraint.activate([
            placeholderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            placeholderView.heightAnchor.constraint(equalTo: view.heightAnchor),
            sportAndProfileWrap.widthAnchor.constraint(equalTo: view.widthAnchor),
            sportAndProfileWrap.heightAnchor.constraint(equalTo: view.heightAnchor),
            profileView.leftAnchor.constraint(equalTo: sportAndProfileWrap.leftAnchor),
            profileView.rightAnchor.constraint(equalTo: sportAndProfileWrap.rightAnchor),
            profileView.topAnchor.constraint(equalTo: sportAndProfileWrap.topAnchor),
            outerStackView.leftAnchor.constraint(equalTo: outerScrollView.leftAnchor),
            outerStackView.rightAnchor.constraint(equalTo: outerScrollView.rightAnchor),
            outerStackView.topAnchor.constraint(equalTo: outerScrollView.topAnchor),
            outerStackView.bottomAnchor.constraint(equalTo: outerScrollView.bottomAnchor),
            outerStackView.centerYAnchor.constraint(equalTo: outerScrollView.centerYAnchor),
            innerStackView.leftAnchor.constraint(equalTo: innerScrollView.leftAnchor),
            innerStackView.rightAnchor.constraint(equalTo: innerScrollView.rightAnchor),
            innerStackView.topAnchor.constraint(equalTo: innerScrollView.topAnchor),
            innerStackView.bottomAnchor.constraint(equalTo: innerScrollView.bottomAnchor),
            innerStackView.centerYAnchor.constraint(equalTo: innerScrollView.centerYAnchor),
            settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsButton.widthAnchor.constraint(equalToConstant: 50),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            floatingMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            floatingMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64),
            floatingMenu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingMenu.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func setupChildViewControllers() {
        scannerViewController.didMove(toParent: self)
        foosballViewController.didMove(toParent: self)
        tableTennisViewController.didMove(toParent: self)
        invitesViewController.didMove(toParent: self)
        
        let foosballView = foosballViewController.view!
        let tableTennisView = tableTennisViewController.view!
        let invitesView = invitesViewController.view!
        
        innerStackView.addArrangedSubview(foosballView)
        innerStackView.addArrangedSubview(tableTennisView)
        innerStackView.addArrangedSubview(invitesView)
        
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
        let top = profileView.bounds.maxY
        let bottom = view.frame.height - floatingMenu.frame.minY
        let contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
        foosballViewController.applyContentInsetToTableView(contentInset)
        tableTennisViewController.applyContentInsetToTableView(contentInset)
    }
    
    private func scrollToViewController(_ viewController: UIViewController, animated: Bool = false) {
        innerScrollView.scrollRectToVisible(viewController.view.frame, animated: animated)
    }
    
    @objc private func settingsButtonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Coordinator.global.presentSettings(from: self)
    }
}

// MARK: - Floating Menu Delegate Conformance

extension MainViewController: FloatingMenuDelegate {
    
    func scannerButtonTapped() {
        scrollToViewController(scannerViewController, animated: true)
    }
    
    func foosballButtonTapped() {
        scrollToViewController(foosballViewController, animated: true)
    }
    
    func tableTennisButtonTapped() {
        scrollToViewController(tableTennisViewController, animated: true)
    }
    
    func invitesButtonTapped() {
        scrollToViewController(invitesViewController, animated: true)
        // foosballViewController.scrollTableViewToTop(animated: true)
        // profileView.displayQrCode(seconds: 3)
    }
}

// MARK: - Sport View Controller Delegate Conformance

extension MainViewController: SportViewControllerDelegate {
    
    func tableViewDidScroll(_ contentOffset: CGPoint) {
    }
}

// MARK: - Scroll View Delegate Conformance

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        floatingMenu.repositionButtonSelection(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        configureProfileView(scrollView: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        configureProfileView(scrollView: scrollView)
    }
    
    private func configureProfileView(scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let width = scrollView.frame.width
        if xOffset < width { // camera screen is showing
            profileView.configureForSport(.unknown)
        } else if xOffset < width * 2 { // foosball screen is showing
            profileView.configureForSport(.foosball)
        } else if xOffset < width * 3 { // table tennis screen is showing
            profileView.configureForSport(.tableTennis)
        } else if xOffset >= width * 3 { // invites screen is showing
            profileView.configureForSport(.unknown)
        }
    }
}
