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
    
    func displayMessage(_ message: String, type: MessageType) {
        messageView.setMessage(message)
        switch type {
        case .success:
            break
        case .failure:
            break
        case .warning:
            break
        default: // info
            break
        }
    }
}

final class MessageView: UIView {
    
    private lazy var messageLabel: UILabel = {
        return UILabel.createLabel(.white, alignment: .left, text: "Hello world!")
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        applyMediumDropShadow(.black)
        applyCornerRadius(15)
        backgroundColor = .green
        setupChildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupChildViews() {
        NSLayoutConstraint.pinToView(self, messageLabel, padding: 8)
    }
    
    func setMessage(_ message: String) {
        messageLabel.text = message
    }
}
