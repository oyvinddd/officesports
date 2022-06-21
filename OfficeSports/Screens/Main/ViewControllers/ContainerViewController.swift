//
//  ContainerViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

private let scannerFadeDuration: TimeInterval = 0.2 // seconds
private let scannerDelayDuration: TimeInterval = 0  // seconds

final class ContainerViewController: UIViewController {
    
    private lazy var cameraPlaceholderView: UIView = {
        return UIView.createView(.clear)
    }()
    
    private lazy var sportAndProfileWrap: UIView = {
        let view = UIView.createView(UIColor.OS.General.background)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: -15, height: 0)
        view.layer.masksToBounds = false
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.3
        return view
    }()
    
    private lazy var profileView: ProfileView = {
        return ProfileView(account: OSAccount.current, initialSport: .foosball, delegate: self)
    }()
    
    private lazy var outerScrollView: UIScrollView = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        tapGestureRecognizer.cancelsTouchesInView = false
        let scrollView = UIScrollView.createScrollView(.clear, delegate: self)
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        return scrollView
    }()
    
    private lazy var innerScrollView: UIScrollView = {
        return UIScrollView.createScrollView(.clear, delegate: self)
    }()
    
    private lazy var innerStackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal)
    }()
    
    private lazy var floatingMenu: FloatingMenu = {
        return FloatingMenu(delegate: self)
    }()
    
    private lazy var scannerViewController: ScannerViewController = {
        return ScannerViewController()
    }()
    
    private lazy var foosballViewController: SportViewController = {
        let viewModel = SportViewModel(api: FirebaseSportsAPI(), sport: .foosball)
        return SportViewController(viewModel: viewModel, delegate: self)
    }()
    
    private lazy var tableTennisViewController: SportViewController = {
        let viewModel = SportViewModel(api: FirebaseSportsAPI(), sport: .tableTennis)
        return SportViewController(viewModel: viewModel, delegate: self)
    }()
    
    private lazy var invitesViewController: MyInvitesViewController = {
        let viewModel = MyInvitesViewModel(api: FirebaseSportsAPI())
        return MyInvitesViewController(viewModel: viewModel)
    }()
    
    private let viewModel: PlayerProfileViewModel
    
    init(viewModel: PlayerProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        setupChildViewControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToViewController(foosballViewController)
        configureTableViewInsets()
    }
    
    func resetScrollViewsAndReloadData() {
        scrollToViewController(foosballViewController, animated: true)
        foosballViewController.reloadSportData()
        tableTennisViewController.reloadSportData()
    }
    
    private func setupChildViews() {
        view.addSubview(scannerViewController.view!)
        
        NSLayoutConstraint.pinToView(view, outerScrollView)
        
        sportAndProfileWrap.addSubview(profileView)
        
        NSLayoutConstraint.pinToView(sportAndProfileWrap, innerScrollView)
        
        innerScrollView.addSubview(innerStackView)
        
        outerScrollView.addSubview(cameraPlaceholderView)
        outerScrollView.addSubview(sportAndProfileWrap)
        
        view.addSubview(floatingMenu)
        
        NSLayoutConstraint.activate([
            cameraPlaceholderView.leftAnchor.constraint(equalTo: outerScrollView.leftAnchor),
            cameraPlaceholderView.centerYAnchor.constraint(equalTo: outerScrollView.centerYAnchor),
            cameraPlaceholderView.widthAnchor.constraint(equalTo: outerScrollView.widthAnchor),
            cameraPlaceholderView.heightAnchor.constraint(equalTo: outerScrollView.heightAnchor),
            sportAndProfileWrap.leftAnchor.constraint(equalTo: cameraPlaceholderView.rightAnchor),
            sportAndProfileWrap.rightAnchor.constraint(equalTo: outerScrollView.rightAnchor),
            sportAndProfileWrap.centerYAnchor.constraint(equalTo: outerScrollView.centerYAnchor),
            sportAndProfileWrap.widthAnchor.constraint(equalTo: outerScrollView.widthAnchor),
            sportAndProfileWrap.heightAnchor.constraint(equalTo: outerScrollView.heightAnchor),
            profileView.leftAnchor.constraint(equalTo: sportAndProfileWrap.leftAnchor),
            profileView.rightAnchor.constraint(equalTo: sportAndProfileWrap.rightAnchor),
            profileView.topAnchor.constraint(equalTo: sportAndProfileWrap.topAnchor),
            innerStackView.leftAnchor.constraint(equalTo: innerScrollView.leftAnchor),
            innerStackView.rightAnchor.constraint(equalTo: innerScrollView.rightAnchor),
            innerStackView.topAnchor.constraint(equalTo: innerScrollView.topAnchor),
            innerStackView.bottomAnchor.constraint(equalTo: innerScrollView.bottomAnchor),
            innerStackView.centerYAnchor.constraint(equalTo: innerScrollView.centerYAnchor),
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
        let padding: CGFloat = 32
        let topInset = profileView.frame.maxY
        let bottomInset = view.frame.height - floatingMenu.frame.minY + padding
        let contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        foosballViewController.applyContentInsetToTableView(contentInset)
        tableTennisViewController.applyContentInsetToTableView(contentInset)
        invitesViewController.applyContentInsetToTableView(contentInset)
    }
    
    private func scrollToViewController(_ viewController: UIViewController, animated: Bool = false) {
        guard !viewController.isKind(of: ScannerViewController.self) else {
            outerScrollView.setContentOffset(.zero, animated: animated)
            return
        }
        if outerScrollView.contentOffset == .zero {
            outerScrollView.setContentOffset(sportAndProfileWrap.frame.origin, animated: animated)
        }
        innerScrollView.scrollRectToVisible(viewController.view.frame, animated: animated)
    }
    
    private func isShowingViewController(_ viewController: UIViewController) -> Bool {
        if outerScrollView.contentOffset.x > 0 && viewController.isKind(of: ScannerViewController.self) {
            return true
        }
        return innerScrollView.contentOffset.x == viewController.view.frame.minX
    }
    
    @objc private func scrollViewTapped(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(ofTouch: 0, in: view)
        if isShowingViewController(foosballViewController)
            || isShowingViewController(tableTennisViewController)
            || isShowingViewController(invitesViewController) {
            profileView.handleTouch(point: touchPoint)
        }
        scannerViewController.handleTouch(point: touchPoint)
    }
}

// MARK: - Profile View Delegate Conformance

extension ContainerViewController: ProfileViewDelegate {
    
    func profilePictureTapped() {
        // prevent showing of QR code if user is on the invites screen
        guard !isShowingViewController(invitesViewController) else {
            return
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        profileView.displayQrCode(seconds: 3)
    }
    
    func settingsButtonTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Coordinator.global.presentSettings(from: self)
    }
}

// MARK: - Floating Menu Delegate Conformance

extension ContainerViewController: FloatingMenuDelegate {

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
    }
    
    func foosballButtonDoubleTapped() {
        profileView.displayQrCode(seconds: 3)
    }
    
    func tableTennisButtonDoubleTapped() {
        profileView.displayQrCode(seconds: 3)
    }
}

// MARK: - Sport View Controller Delegate Conformance

extension ContainerViewController: SportViewControllerDelegate {
    
    func tableViewDidScroll(_ contentOffset: CGPoint) {
        // TODO: fade profile view as table view scrolls on top of it
    }
    
    func didFetchSportsData() {
        viewModel.getPlayerProfile()
    }
}

// MARK: - Scroll View Delegate Conformance

extension ContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == outerScrollView {
            scannerViewController.handleShadowViewOpacity(scrollView.contentOffset)
            floatingMenu.adjustSelectionFromOuterScrollView(scrollView)
        } else {
            floatingMenu.adjustselectionFromInnerScrollView(scrollView)
        }
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
        // update profile view based on inner scroll view content offset
        if scrollView == innerScrollView {
            if xOffset < width { // foosball screen is showing
                profileView.configureForSport(.foosball)
            } else if xOffset < width * 2 { // table tennis screen is showing
                profileView.configureForSport(.tableTennis)
            } else if xOffset >= width * 2 { // invites screen is showing
                profileView.configureForSport(.unknown)
            }
        }
    }
}
