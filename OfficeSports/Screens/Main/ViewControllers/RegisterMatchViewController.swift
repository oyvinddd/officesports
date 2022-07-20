//
//  RegisterMatchViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 18/06/2022.
//

import UIKit
import Combine

private let kBackgroundMaxFade: CGFloat = 0.6
private let kBackgroundMinFade: CGFloat = 0
private let kAnimDuration: TimeInterval = 0.15
private let kAnimDelay: TimeInterval = 0

protocol RegisterMatchDelegate: AnyObject {
    func dismissedMatchRegistration(match: OSMatch?)
}

final class RegisterMatchViewController: UIViewController {
    
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
    
    private lazy var dialogHandle: UIView = {
        let view = UIView.createView(UIColor.OS.Text.subtitle, cornerRadius: 3)
        view.alpha = 0.8
        return view
    }()
    
    private lazy var contentWrap: UIView = {
        return UIView.createView(.clear)
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal, alignment: .center)
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private lazy var registerButton: OSButton = {
        let button = OSButton("Register", type: .primaryInverted)
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: OSButton = {
        let button = OSButton("Cancel", type: .secondaryInverted)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
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
    
    private let viewModel: RegisterMatchViewModel
    private let payload: OSCodePayload
    private var subscribers = Set<AnyCancellable>()
    
    weak var delegate: RegisterMatchDelegate?
    
    init(viewModel: RegisterMatchViewModel, payload: OSCodePayload, delegate: RegisterMatchDelegate?) {
        self.viewModel = viewModel
        self.payload = payload
        self.delegate = delegate
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
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                switch state {
                case .loading:
                    self.registerButton.buttonState = .loading
                case .success(let match):
                    let message = OSMessage("Congratulations! You gained \(match.winnerDelta) points from your win against \(match.loser.nickname) 🤟", .success)
                    Coordinator.global.send(message)
                    self.registerButton.buttonState = .normal
                    self.toggleDialog(enabled: false) { [unowned self] in
                        self.delegate?.dismissedMatchRegistration(match: match)
                    }
                case .failure(let error):
                    Coordinator.global.send(error)
                    self.registerButton.buttonState = .normal
                case .idle:
                    self.registerButton.buttonState = .normal
                }
            }
            .store(in: &subscribers)
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, backgroundView)
        
        view.addSubview(dialogView)
        dialogView.addSubview(contentWrap)
        dialogView.addSubview(dialogHandle)
        contentWrap.addSubview(nicknameLabel)
        contentWrap.addSubview(registerButton)
        contentWrap.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            dialogView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dialogView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dialogBottomConstraint,
            dialogHandle.centerXAnchor.constraint(equalTo: dialogView.centerXAnchor),
            dialogHandle.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 10),
            dialogHandle.widthAnchor.constraint(equalToConstant: 40),
            dialogHandle.heightAnchor.constraint(equalToConstant: 6),
            contentWrap.leftAnchor.constraint(equalTo: dialogView.leftAnchor),
            contentWrap.rightAnchor.constraint(equalTo: dialogView.rightAnchor),
            contentWrap.topAnchor.constraint(equalTo: dialogHandle.topAnchor, constant: 8),
            contentWrap.bottomAnchor.constraint(equalTo: dialogView.safeAreaLayoutGuide.bottomAnchor),
            nicknameLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            nicknameLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            nicknameLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 16),
            registerButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            registerButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            registerButton.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 32),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            cancelButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            cancelButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: contentWrap.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        let sport = payload.sport
        let nickname = payload.nickname
        
        let question = "Register a win in \(sport.humanReadableName) against \(nickname)?"
        let attributedQuestion = NSMutableAttributedString(string: question)
        let rangeOfSport = NSString(string: question).range(of: sport.humanReadableName)
        let sportColor = UIColor.OS.colorForSport(sport)
        
        attributedQuestion.addAttribute(.foregroundColor, value: sportColor, range: rangeOfSport)
        nicknameLabel.attributedText = attributedQuestion
    }
    
    private func toggleDialog(enabled: Bool, completion: (() -> Void)? = nil) {
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
                completion?()
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
    
    // MARK: - Button Handling
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        toggleDialog(enabled: false) { [unowned self] in
            self.delegate?.dismissedMatchRegistration(match: nil)
        }
    }
    
    @objc private func registerButtonTapped(_ sender: OSButton) {
        guard let winnerId = OSAccount.current.userId else {
            return
        }
        let registration = OSMatchRegistration(sport: payload.sport, winnerId: winnerId, loserId: payload.userId)
        viewModel.registerMatch(registration)
    }
    
    @objc private func cancelButtonTapped(_ sender: OSButton) {
        toggleDialog(enabled: false) { [unowned self] in
            self.delegate?.dismissedMatchRegistration(match: nil)
        }
    }
}
