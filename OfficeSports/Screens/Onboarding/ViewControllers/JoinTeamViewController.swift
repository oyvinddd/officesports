//
//  JoinTeamViewController.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 29/09/2022.
//

import UIKit
import Combine

private let kBackgroundMaxFade: CGFloat = 0.6
private let kBackgroundMinFade: CGFloat = 0
private let kAnimDuration: TimeInterval = 0.15
private let kAnimDelay: TimeInterval = 0

final class JoinTeamViewController: UIViewController {
    
    private lazy var shadowView: UIView = {
        let view = UIView.createView(.black)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(shadowViewTapped))
        view.addGestureRecognizer(tapRecognizer)
        view.alpha = kBackgroundMinFade
        return view
    }()
    
    private lazy var contentWrap: UIView = {
        let view = UIView.createView(.white)
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.OS.Text.normal)
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private lazy var codeInputView: CodeInputView = {
        return CodeInputView(delegate: self)
    }()
    
    private lazy var joinButton: OSButton = {
        let button = OSButton("Join", type: .primaryInverted, state: .disabled)
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var dialogBottomConstraint: NSLayoutConstraint = {
        let constraint = contentWrap.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.constant = dialogHideConstant
        return constraint
    }()
    
    private var dialogHideConstant: CGFloat {
        return contentWrap.frame.height
    }
    private var dialogShowConstant: CGFloat {
        return 0
    }
    
    private let viewModel: JoinTeamViewModel
    private let team: OSTeam
    private var subscribers = Set<AnyCancellable>()
    
    init(viewModel: JoinTeamViewModel, team: OSTeam) {
        self.viewModel = viewModel
        self.team = team
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        titleLabel.text = "Insert password for the team \(team.name)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        setupSubscribers()
        setupChildViews()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleDialog(enabled: true)
        _ = codeInputView.becomeFirstResponder()
    }
    
    private func setupSubscribers() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                switch state {
                case .idle:
                    self.joinButton.buttonState = .disabled
                case .loading:
                    joinButton.buttonState = .loading
                case .success(let team):
                    self.joinButton.buttonState = .normal
                    self.storeTeamIdAndProceed(team: team)
                case .failure(let error):
                    self.joinButton.buttonState = .disabled
                    Coordinator.global.send(error)
                }
            }.store(in: &subscribers)
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(view, shadowView)
        
        view.addSubview(contentWrap)
        contentWrap.addSubview(titleLabel)
        contentWrap.addSubview(codeInputView)
        contentWrap.addSubview(joinButton)
        
        NSLayoutConstraint.activate([
            contentWrap.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentWrap.rightAnchor.constraint(equalTo: view.rightAnchor),
            dialogBottomConstraint,
            titleLabel.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentWrap.topAnchor, constant: 26),
            codeInputView.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 16),
            codeInputView.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -16),
            codeInputView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            codeInputView.heightAnchor.constraint(equalToConstant: 60),
            joinButton.leftAnchor.constraint(equalTo: contentWrap.leftAnchor, constant: 64),
            joinButton.rightAnchor.constraint(equalTo: contentWrap.rightAnchor, constant: -64),
            joinButton.topAnchor.constraint(equalTo: codeInputView.bottomAnchor, constant: 32),
            joinButton.bottomAnchor.constraint(equalTo: contentWrap.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            joinButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
    }
    
    private func toggleDialog(enabled: Bool) {
        UIView.animate(
            withDuration: kAnimDuration,
            delay: kAnimDelay,
            options: [.curveEaseOut]) {
                self.shadowView.alpha = enabled ? kBackgroundMaxFade : kBackgroundMinFade
                self.dialogBottomConstraint.constant = enabled ? self.dialogShowConstant : self.dialogHideConstant
                self.view.layoutIfNeeded()
            } completion: { [unowned self] _ in
                if !enabled {
                    self.dismiss(animated: false)
                }
            }
    }
    
    private func storeTeamIdAndProceed(team: OSTeam) {
        let message = OSMessage("Successfully joined \(team.name)! 🥳", .success)
        Coordinator.global.send(message)
        OSAccount.current.player?.teamId = team.id
        toggleDialog(enabled: false)
    }
    
    @objc private func shadowViewTapped() {
        toggleDialog(enabled: false)
    }
    
    @objc private func joinButtonTapped(_ sender: OSButton) {
        viewModel.joinTeam(team, password: codeInputView.text)
    }
}

// MARK: - Code Input Delegate

extension JoinTeamViewController: CodeInputDelegate {
    
    func didType(input: String, finished: Bool) {
        if finished {
            viewModel.joinTeam(team, password: input)
        }
    }
}

// MARK: - Keyboard Handling

extension JoinTeamViewController {
    
    private func setupKeyboardObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        adjustViews(showing: true, notification: notification)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        adjustViews(showing: false, notification: notification)
    }
    
    private func adjustViews(showing: Bool, notification: Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let offset = showing ? keyboardSize.height : 0
        dialogBottomConstraint.constant = -offset
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: UIView.AnimationOptions(rawValue: curve),
                       animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
