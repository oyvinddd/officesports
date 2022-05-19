//
//  MessageWindow.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 18/05/2022.
//

import UIKit

enum MessageType: Int {
    case success, failure, warning, info
}

private let messageMaxOpacity: CGFloat = 0.95
private let messageMinOpacity: CGFloat = 0
private let messageDisplayDuration: TimeInterval = 2 // seconds

final class MessageWindow: UIWindow {
    
    private lazy var messageViewController: MessageViewController = {
        return MessageViewController()
    }()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        translatesAutoresizingMaskIntoConstraints = false
        rootViewController = messageViewController
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
    
    func displayMessage(_ message: String, type: MessageType) {
        messageViewController.displayMessage(message, type: type)
    }
}

final class MessageViewController: UIViewController {
    
    private lazy var messageView: MessageView = {
        return MessageView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
    }
    
    private func setupChildViews() {
        view.addSubview(messageView)
        
        NSLayoutConstraint.activate([
            messageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            messageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            messageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }
    
    func displayMessage(_ message: String, type: MessageType, seconds: Int = 3) {
        messageView.updateMessageAndStyle(message, type: type)
    }
}

final class MessageView: UIView {
    
    private lazy var infoImageView: UIImageView = {
        return UIImageView.createImageView(nil)
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel.createLabel(.white, alignment: .left, text: nil)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        applyMediumDropShadow(.black)
        applyCornerRadius(6)
        setupChildViews()
        updateMessageAndStyle("This is a test success message...", type: .success)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, messageLabel, padding: 16)
    }
    
    func updateMessageAndStyle(_ message: String?, type: MessageType) {
        alpha = 0
        messageLabel.text = message
        switch type {
        case .success:
            backgroundColor = UIColor.OS.General.success
        case .failure:
            backgroundColor = UIColor.OS.General.failure
        case .warning:
            backgroundColor = UIColor.OS.General.warning
        case .info:
            break
        }
    }
}
