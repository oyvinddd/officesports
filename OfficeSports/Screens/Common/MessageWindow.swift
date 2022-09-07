//
//  MessageWindow.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 18/05/2022.
//

import UIKit

private let messageMaxOpacity: CGFloat = 0.9
private let messageMinOpacity: CGFloat = 0
private let messageAnimateDuration: TimeInterval = 0.2  // seconds
private let messageDisplayDuration: TimeInterval = 3.5  // seconds

final class MessageWindow: UIWindow {
    
    private var windowViewController = WindowViewController()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        translatesAutoresizingMaskIntoConstraints = false
        rootViewController = windowViewController
        windowLevel = .alert
        makeKeyAndVisible()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event), view.isKind(of: MessageView.self) {
            return view
        }
        return nil
    }
    
    func showMessage(_ message: OSMessage, seconds: Int = 3) {
        windowViewController.createAndShowMessageView(message: message, seconds: seconds)
    }
    
    func showConfetti(seconds: Float) {
        windowViewController.showConfetti(seconds: seconds)
    }
}

final class WindowViewController: UIViewController {
    
    private lazy var confettiView: ConfettiView = {
        return ConfettiView(intensity: 1)
    }()
    
    private var isShowingMessage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLayoutConstraint.pinToView(view, confettiView)
    }
    
    func createAndShowMessageView(message: OSMessage, seconds: Int = 3) {
        // only show one message at a time
        guard !isShowingMessage else {
            return
        }
        isShowingMessage = true
        let messageView = createAndPlaceMessageView(message: message)
        
        UIView.animate(
            withDuration: messageAnimateDuration,
            delay: 0,
            options: [.curveEaseOut]) {
                messageView.alpha = messageMaxOpacity
            } completion: { _ in
                UIView.animate(
                    withDuration: messageAnimateDuration,
                    delay: messageDisplayDuration,
                    options: [.curveEaseIn]) {
                        messageView.alpha = messageMinOpacity
                    } completion: { [unowned self] _ in
                        self.isShowingMessage = false
                        messageView.removeFromSuperview()
                    }
            }
    }
    
    func showConfetti(seconds: Float) {
        confettiView.start()
        
        let interval = TimeInterval(seconds)
        Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.confettiView.stop()
        }
    }
    
    private func createAndPlaceMessageView(message: OSMessage) -> MessageView {
        let messageView = MessageView(message)
        view.addSubview(messageView)
        
        NSLayoutConstraint.activate([
            messageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            messageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            messageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        return messageView
    }
}

// MARK: Message View

private final class MessageView: UIView {
    
    private lazy var infoImageView: UIImageView = {
        return UIImageView.createImageView(nil)
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .left)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 5
        return label
    }()
    
    init(_ message: OSMessage) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        configureUI(message)
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, messageLabel, padding: 16)
    }
    
    private func configureUI(_ message: OSMessage) {
        alpha = messageMinOpacity
        applyMediumDropShadow(UIColor.OS.Text.normal)
        applyCornerRadius(6)
        messageLabel.text = message.text
        switch message.category {
        case .success:
            backgroundColor = UIColor.OS.Status.success
        case .failure:
            backgroundColor = UIColor.OS.Status.failure
        case .warning:
            backgroundColor = UIColor.OS.Status.warning
        case .info:
            backgroundColor = UIColor.black
        }
    }
}
