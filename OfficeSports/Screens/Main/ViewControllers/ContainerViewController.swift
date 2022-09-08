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
        let initialSport = determineInitialSport()
        return ProfileView(account: OSAccount.current, initialSport: initialSport, delegate: self)
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
    
    private lazy var tableTennisViewController: SportViewController = {
        let viewModel = SportViewModel(api: FirebaseSportsAPI(), sport: .tableTennis)
        return SportViewController(viewModel: viewModel, delegate: self)
    }()
    
    private lazy var foosballViewController: SportViewController = {
        let viewModel = SportViewModel(api: FirebaseSportsAPI(), sport: .foosball)
        return SportViewController(viewModel: viewModel, delegate: self)
    }()
    
    private lazy var poolViewController: SportViewController = {
        let viewModel = SportViewModel(api: FirebaseSportsAPI(), sport: .pool)
        return SportViewController(viewModel: viewModel, delegate: self)
    }()
    
    private lazy var activeViewControllers: [UIViewController] = {
        let showTableTennis = UserDefaultsHelper.loadToggledStateFor(sport: .tableTennis)
        let showFoosball = UserDefaultsHelper.loadToggledStateFor(sport: .foosball)
        let showPool = UserDefaultsHelper.loadToggledStateFor(sport: .pool)
        
        var viewControllers: [UIViewController] = [scannerViewController]
        if showTableTennis {
            viewControllers.append(tableTennisViewController)
        }
        if showFoosball {
            viewControllers.append(foosballViewController)
        }
        if showPool {
            viewControllers.append(poolViewController)
        }
        return viewControllers
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
        showDefaultViewController(animated: false)
        configureTableViewInsets()
    }
    
    func resetScrollViewsAndReloadData() {
        scrollToViewController(tableTennisViewController, animated: true)
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
            floatingMenu.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 16),
            floatingMenu.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor, constant: -16),
            floatingMenu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingMenu.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floatingMenu.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupChildViewControllers() {
        let showTableTennis = UserDefaultsHelper.loadToggledStateFor(sport: .tableTennis)
        let showFoosball = UserDefaultsHelper.loadToggledStateFor(sport: .foosball)
        let showPool = UserDefaultsHelper.loadToggledStateFor(sport: .pool)
        
        scannerViewController.didMove(toParent: self)
        
        if showTableTennis {
            tableTennisViewController.didMove(toParent: self)
            let tableTennisView = tableTennisViewController.view!
            innerStackView.addArrangedSubview(tableTennisView)
            
            tableTennisView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            tableTennisView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }
        
        if showFoosball {
            foosballViewController.didMove(toParent: self)
            let foosballView = foosballViewController.view!
            innerStackView.addArrangedSubview(foosballView)
            
            foosballView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            foosballView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }
        
        if showPool {
            poolViewController.didMove(toParent: self)
            let poolView = poolViewController.view!
            innerStackView.addArrangedSubview(poolView)
            
            poolView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            poolView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }
    }
    
    private func configureTableViewInsets() {
        let padding: CGFloat = 0
        let topInset = profileView.frame.maxY
        let bottomInset = view.frame.height - floatingMenu.frame.minY + padding
        let contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        tableTennisViewController.applyContentInsetToTableView(contentInset)
        foosballViewController.applyContentInsetToTableView(contentInset)
        poolViewController.applyContentInsetToTableView(contentInset)
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
    
    private func showDefaultViewController(animated: Bool) {
        if UserDefaultsHelper.sportIsDefaultScreen() {
            scrollToViewController(tableTennisViewController, animated: animated)
        } else {
            scrollToViewController(scannerViewController, animated: animated)
        }
    }
    
    private func determineInitialSport() -> OSSport {
        guard activeViewControllers.count >= 2 else {
            return .tableTennis
        }
        let firstSportViewController = activeViewControllers[1]
        if firstSportViewController == tableTennisViewController {
            return .tableTennis
        }
        if firstSportViewController == foosballViewController {
            return .foosball
        }
        return .pool
    }
    
    @objc private func scrollViewTapped(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(ofTouch: 0, in: view)
        if isShowingViewController(tableTennisViewController)
            || isShowingViewController(foosballViewController)
            || isShowingViewController(poolViewController) {
            profileView.handleTouch(point: touchPoint)
        }
        scannerViewController.handleTouch(point: touchPoint)
    }
}

// MARK: - Profile View Delegate Conformance

extension ContainerViewController: ProfileViewDelegate {

    func profilePictureTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        profileView.displayQrCode()
    }
    
    func invitesButtonTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Coordinator.global.presentSettings(from: self)
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
    
    func poolButtonTapped() {
        scrollToViewController(poolViewController, animated: true)
    }
    
    func tableTennisButtonDoubleTapped() {
        tableTennisViewController.scrollTableViewToTop(animated: true)
        profileView.displayQrCode()
    }
    
    func foosballButtonDoubleTapped() {
        foosballViewController.scrollTableViewToTop(animated: true)
        profileView.displayQrCode()
    }
    
    func poolButtonDoubleTapped() {
        poolViewController.scrollTableViewToTop(animated: true)
        profileView.displayQrCode()
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
            if xOffset < width { // table tennis screen is showing
                profileView.configureForSport(.tableTennis)
                foosballViewController.scrollTableViewToTop(animated: false)
                poolViewController.scrollTableViewToTop(animated: false)
            } else if xOffset < width * 2 { // foosball screen is showing
                profileView.configureForSport(.foosball)
                tableTennisViewController.scrollTableViewToTop(animated: false)
                poolViewController.scrollTableViewToTop(animated: false)
            } else if xOffset >= width * 2 { // pool screen is showing
                profileView.configureForSport(.pool)
                tableTennisViewController.scrollTableViewToTop(animated: false)
                foosballViewController.scrollTableViewToTop(animated: false)
            }
        }
    }
}
