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
        let view = UIView.createView(.yellow)
        view.isUserInteractionEnabled = false
        return view
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
    
    private lazy var matchHistoryView: MatchHistoryView = {
        return MatchHistoryView(title: "Your history with \(player.nickname.lowercased())")
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
        fetchMatchHistoryWithPlayer()
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
        let matches = player.noOfmatchesForSport(sport)
        let winsStr = matches > 0 ? "\(calculateWinRate())%" : "-"
        let matchesStr = matches != 1 ? "Matches" : "Match"
        
        let scoreView = MetricsView(metric: String(describing: score), title: "Points", backgroundColor: UIColor.OS.Sport.foosball)
        let matchesView = MetricsView(metric: String(describing: matches), title: matchesStr, backgroundColor: UIColor.OS.Sport.pool)
        let winsView = MetricsView(metric: winsStr, title: "Win rate", backgroundColor: UIColor.OS.Sport.tableTennis)
        
        
        NSLayoutConstraint.pinToView(view, backgroundView)
        
        view.addSubview(dialogView)
        dialogView.addSubview(contentWrap)
        contentWrap.addSubview(profileBackgroundView)
        contentWrap.addSubview(scoreView)
        contentWrap.addSubview(matchesView)
        contentWrap.addSubview(winsView)
        contentWrap.addSubview(matchHistoryView)
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
            matchesView.leftAnchor.constraint(equalTo: scoreView.rightAnchor, constant: 16),
            matchesView.rightAnchor.constraint(equalTo: winsView.leftAnchor, constant: -16),
            matchesView.topAnchor.constraint(equalTo: scoreView.topAnchor),
            matchesView.bottomAnchor.constraint(equalTo: scoreView.bottomAnchor),
            matchesView.widthAnchor.constraint(equalTo: scoreView.widthAnchor),
            winsView.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            winsView.topAnchor.constraint(equalTo: matchesView.topAnchor),
            winsView.bottomAnchor.constraint(equalTo: matchesView.bottomAnchor),
            winsView.widthAnchor.constraint(equalTo: matchesView.widthAnchor),
            matchHistoryView.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            matchHistoryView.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            matchHistoryView.topAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: 64),
            inviteButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            inviteButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            inviteButton.topAnchor.constraint(equalTo: matchHistoryView.bottomAnchor, constant: 32),
            inviteButton.bottomAnchor.constraint(equalTo: contentWrap.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            inviteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        profileEmjoiLabel.text = player.emoji
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
    
    private func calculateWinRate() -> Int {
        let noOfMatches = player.noOfmatchesForSport(sport)
        let noOfWins = player.noOfWinsForSport(sport)
        guard noOfMatches > 0 else {
            return 0
        }
        return Int((Float(noOfWins) / Float(noOfMatches) * 100.0).rounded())
    }
    
    private func fetchMatchHistoryWithPlayer() {
        // need to get the ID's of the players we want to compare
        guard let id1 = OSAccount.current.userId, let id2 = player.id else {
            return
        }
        // exit early if we the player is ourselves
        guard OSAccount.current.player != player else {
            matchHistoryView.disable()
            return
        }
        viewModel.fetchLatestMatches(sport: sport, player1Id: id1, player2Id: id2)
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
    
    private func drawArc() {
        
        let bounds = croppedView.bounds
        
        
        let path = UIBezierPath(arcCenter: CGPoint(x: 100, y: 100), radius: 100, startAngle: 0, endAngle: .pi, clockwise: false)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        //  shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.strokeColor = UIColor.black.cgColor
        croppedView.layer.mask = shapeLayer
        //croppedView.layer.addSublayer(shapeLayer)
    }
}
