//
//  PlayerDetailsViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 25/05/2022.
//

import UIKit
import Combine

private let kBackgroundMaxFade: CGFloat = 0.6
private let kBackgroundMinFade: CGFloat = 0
private let kAnimDuration: TimeInterval = 0.15
private let kAnimDelay: TimeInterval = 0

private let inviteThreshold: TimeInterval = 60 * 15 // 15 minutes

final class PlayerDetailsViewController: UIViewController {
    
    private lazy var backgroundView: UIView = {
        let view = UIView.createView(.black)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(tapRecognizer)
        view.alpha = 0
        return view
    }()
    
    private lazy var dialogView: UIView = {
        let view = UIView.createView(.white)
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.clear)
    }()
    
    private lazy var profileBackgroundView: UIView = {
        let backgroundColor = UIColor.OS.hashedProfileColor(player.nickname)
        let view = UIView.createView(backgroundColor)
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var croppedView: UIView = {
        return UIView.createView(.yellow)
    }()
    
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark", withConfiguration: nil)
        let button = UIButton.createButton(.black, tintColor: .white, image: image)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.applyCornerRadius(20)
        button.alpha = 0.3
        return button
    }()
    
    private lazy var profileEmjoiLabel: UILabel = {
        let label = UILabel.createLabel(.black, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 100)
        label.applyLargeDropShadow(.black)
        return label
    }()
    
    private lazy var inviteButton: OSButton = {
        let button = OSButton("Invite to match", type: .primaryInverted, state: .disabled)
        button.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
    }()
    
    private lazy var dialogBottomConstraint: NSLayoutConstraint = {
        let constraint = dialogView.topAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.constant = dialogHideConstant
        return constraint
    }()
    
    private let dialogHideConstant: CGFloat = 0
    private var dialogShowConstant: CGFloat {
        return -dialogView.frame.height
    }
    
    private let viewModel: PlayerDetailsViewModel
    private let player: OSPlayer
    private let sport: OSSport
    
    private var subscribers = Set<AnyCancellable>()
    
    init(viewModel: PlayerDetailsViewModel, player: OSPlayer, sport: OSSport) {
        self.viewModel = viewModel
        self.player = player
        self.sport = sport
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleDialog(enabled: true)
    }
    
    private func setupSubscribers() {
        viewModel.$state.receive(on: DispatchQueue.main).sink { [unowned self] state in
            switch state {
            case .loading:
                self.inviteButton.buttonState = .loading
            case .success(let invite):
                let message = OSMessage("You have invited \(invite.inviteeNickname) to a game of \(self.sport.humanReadableName) ⚔️", .success)
                Coordinator.global.send(message)
                UserDefaultsHelper.saveInviteTimestamp(Date())
                self.toggleDialog(enabled: false)
                self.inviteButton.buttonState = .normal
            case .failure(let error):
                Coordinator.global.send(error)
                self.inviteButton.buttonState = .normal
            default:
                self.inviteButton.buttonState = .disabled
            }
        }.store(in: &subscribers)
    }
    
    private func setupChildViews() {
        let score = player.scoreForSport(sport)
        let matches = player.matchesPlayed(sport: sport)
        
        let scoreView = MetricsView(metric: String(describing: score), title: "Points", backgroundColor: UIColor.OS.Sport.foosball)
        let matchesView = MetricsView(metric: String(describing: matches), title: "Matches", backgroundColor: UIColor.OS.Sport.pool)
        let winsView = MetricsView(metric: "100%", title: "Win rate", backgroundColor: UIColor.OS.Sport.tableTennis)
        let historyView = MatchHistoryView(player: player)
        
        NSLayoutConstraint.pinToView(view, backgroundView)
        
        view.addSubview(dialogView)
        dialogView.addSubview(contentWrap)
        contentWrap.addSubview(profileBackgroundView)
        contentWrap.addSubview(scoreView)
        contentWrap.addSubview(matchesView)
        contentWrap.addSubview(winsView)
        contentWrap.addSubview(historyView)
        contentWrap.addSubview(inviteButton)
        profileBackgroundView.addSubview(profileEmjoiLabel)
        profileBackgroundView.addSubview(closeButton)
        profileBackgroundView.addSubview(croppedView)
        
        NSLayoutConstraint.activate([
            dialogView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dialogView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dialogBottomConstraint,
            contentWrap.leftAnchor.constraint(equalTo: dialogView.leftAnchor),
            contentWrap.rightAnchor.constraint(equalTo: dialogView.rightAnchor),
            contentWrap.topAnchor.constraint(equalTo: dialogView.topAnchor),
            contentWrap.bottomAnchor.constraint(equalTo: dialogView.safeAreaLayoutGuide.bottomAnchor),
            profileBackgroundView.leftAnchor.constraint(equalTo: dialogView.leftAnchor),
            profileBackgroundView.rightAnchor.constraint(equalTo: dialogView.rightAnchor),
            profileBackgroundView.topAnchor.constraint(equalTo: dialogView.topAnchor),
            croppedView.leftAnchor.constraint(equalTo: profileBackgroundView.leftAnchor),
            croppedView.rightAnchor.constraint(equalTo: profileBackgroundView.rightAnchor),
            croppedView.bottomAnchor.constraint(equalTo: profileBackgroundView.bottomAnchor),
            croppedView.heightAnchor.constraint(equalToConstant: 40),
            closeButton.rightAnchor.constraint(equalTo: profileBackgroundView.rightAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: profileBackgroundView.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            profileEmjoiLabel.centerXAnchor.constraint(equalTo: profileBackgroundView.centerXAnchor),
            profileEmjoiLabel.centerYAnchor.constraint(equalTo: profileBackgroundView.centerYAnchor),
            profileEmjoiLabel.topAnchor.constraint(equalTo: profileBackgroundView.topAnchor, constant: 32),
            profileEmjoiLabel.bottomAnchor.constraint(equalTo: profileBackgroundView.bottomAnchor, constant: -32),
            scoreView.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            scoreView.topAnchor.constraint(equalTo: profileBackgroundView.bottomAnchor, constant: 16),
            scoreView.bottomAnchor.constraint(equalTo: historyView.topAnchor, constant: -16),
            matchesView.leftAnchor.constraint(equalTo: scoreView.rightAnchor, constant: 16),
            matchesView.rightAnchor.constraint(equalTo: winsView.leftAnchor, constant: -16),
            matchesView.topAnchor.constraint(equalTo: scoreView.topAnchor),
            matchesView.bottomAnchor.constraint(equalTo: scoreView.bottomAnchor),
            matchesView.widthAnchor.constraint(equalTo: scoreView.widthAnchor),
            winsView.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            winsView.topAnchor.constraint(equalTo: matchesView.topAnchor),
            winsView.bottomAnchor.constraint(equalTo: matchesView.bottomAnchor),
            winsView.widthAnchor.constraint(equalTo: matchesView.widthAnchor),
            historyView.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            historyView.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            historyView.topAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: 32),
            inviteButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            inviteButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            inviteButton.topAnchor.constraint(equalTo: historyView.bottomAnchor, constant: 16),
            inviteButton.bottomAnchor.constraint(equalTo: contentWrap.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            inviteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        profileEmjoiLabel.text = player.emoji
        addBottomRoundedEdge(view: croppedView, desiredCurve: 5)
        //nicknameLabel.text = player.nickname.lowercased()
        inviteButton.setTitle("Invite to \(sport.humanReadableName) match", for: .normal)
    }
    
    private func toggleDialog(enabled: Bool) {
        dialogBottomConstraint.constant = enabled ? dialogShowConstant : dialogHideConstant
        toggleBackgroundView(enabled: enabled)
        UIView.animate(
            withDuration: kAnimDuration,
            delay: kAnimDelay,
            options: [.curveEaseOut]) {
                self.view.layoutIfNeeded()
            } completion: { [unowned self] _ in
                if !enabled {
                    self.dismiss()
                }
            }
    }
    
    private func toggleBackgroundView(enabled: Bool) {
        UIView.animate(withDuration: kAnimDuration) {
            self.backgroundView.alpha = enabled ? kBackgroundMaxFade : kBackgroundMinFade
        }
    }
    
    private func dismiss() {
        dismiss(animated: false, completion: nil)
    }
    
    private func isAllowedToInvitePlayer() -> Bool {
        guard let lastInviteTimestamp = UserDefaultsHelper.loadInviteTimestamp() else {
            // if there currently is no timestamp stored locally we are able to invite players
            return true
        }
        let intervalSinceLast = Date().timeIntervalSince(lastInviteTimestamp)
        return intervalSinceLast >= inviteThreshold
    }
    
    // MARK: - Button Handling
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        toggleDialog(enabled: false)
    }
    
    @objc private func inviteButtonTapped(_ sender: OSButton) {
        guard isAllowedToInvitePlayer() else {
            Coordinator.global.send(OSError.inviteNotAllowed)
            return
        }
        viewModel.invitePlayer(player, sport: sport)
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        toggleDialog(enabled: false)
    }
    
    private func addBottomRoundedEdge(view: UIView, desiredCurve: CGFloat?) {
        let offset: CGFloat = view.frame.width / desiredCurve!
        let bounds: CGRect = view.bounds
        
        let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height / 2)
        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        
        // Set the newly created shape layer as the mask for the view's layer
        view.layer.mask = maskLayer
    }
}

// MARK: - Match history view

private final class MatchHistoryView: UIView {
    
    private lazy var historyLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .left)
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView.createStackView(.clear, axis: .horizontal, spacing: 6)
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    init(player: OSPlayer) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        historyLabel.text = "Your matches against \(player.nickname)"
        setupChildViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(historyLabel)
        addSubview(stackView)
        
        createAndAddStatusView()
        createAndAddStatusView()
        createAndAddStatusView()
        createAndAddStatusView()
        createAndAddStatusView()
        createAndAddStatusView()
        createAndAddStatusView()
        
        NSLayoutConstraint.activate([
            historyLabel.leftAnchor.constraint(equalTo: leftAnchor),
            historyLabel.rightAnchor.constraint(equalTo: rightAnchor),
            historyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            historyLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func configureUI() {
        backgroundColor = .white
    }
    
    private func createAndAddStatusView() {
        let statusView = MatchStatusView()
        stackView.addArrangedSubview(statusView)
        
        NSLayoutConstraint.activate([
            statusView.heightAnchor.constraint(equalTo: statusView.widthAnchor)
        ])
    }
}

// MARK: - Match status view

private final class MatchStatusView: UIView {
    
    private lazy var innerView: UIView = {
        return UIView.createView(UIColor.OS.Status.failure, cornerRadius: 2)
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, innerView, padding: 4)
    }
    
    private func configureUI() {
        backgroundColor = .white
        applyCornerRadius(4)
        applySmallDropShadow(.black)
    }
}

// MARK: - Metrics View

private final class MetricsView: UIView {
    
    private lazy var metricLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.white)
        label.font = UIFont.systemFont(ofSize: 29, weight: .semibold)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.white)
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    init(metric: String, title: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupChildViews()
        self.backgroundColor = backgroundColor
        applyMediumDropShadow(.black)
        applyCornerRadius(10)
        metricLabel.text = metric
        titleLabel.text = title.uppercased()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        addSubview(metricLabel)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            metricLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            metricLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            metricLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            metricLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -40),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
