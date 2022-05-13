//
//  Coordinator.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

enum ApplicationState: Int, RawRepresentable {
    case authorized, unauthorized, missingNickname
}

final class Coordinator {
    
    static var global = Coordinator(window: nil, account: OSAccount.current)
    
    var window: UIWindow? {
        didSet { updateRootViewController(animated: false) }
    }
    
    var currentState: ApplicationState = .missingNickname {
        didSet { updateRootViewController(animated: false) }
    }
    
    private lazy var currentViewController: UIViewController? = {
        // TODO: return top most vc here instead
        return window?.rootViewController
    }()
    
    init(window: UIWindow?, account: OSAccount) {
        self.window = window
    }
    
    func updateApplicationState(_ state: ApplicationState, animated: Bool = true) {
        guard state != currentState else {
            return
        }
        currentState = state
    }
    
    private func updateRootViewController(animated: Bool) {
        guard let window = window else {
            fatalError("Application window doesn't exist.")
        }
        var viewController: UIViewController?
        switch currentState {
        case .authorized:
            viewController = mainViewController
        case .missingNickname:
            viewController = nicknameViewController
        default: // unauthorized
            viewController = welcomeViewController
        }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        if animated {
            // a mask of options indicating how you want to perform the animations.
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            // the duration of the transition animation, measured in seconds.
            let duration: TimeInterval = 0.3
            // creates a transition animation
            UIView.transition(
                with: window,
                duration: duration,
                options: options,
                animations: {},
                completion: nil
            )
        }
    }
}

// MARK: - Main Application View Controllers

extension Coordinator {
    
    var welcomeViewController: WelcomeViewController {
        return WelcomeViewController(viewModel: AuthViewModel())
    }
    
    var nicknameViewController: NicknameViewController {
        return NicknameViewController()
    }
    
    var mainViewController: MainViewController {
        return MainViewController()
    }
    
    var settingsViewController: SettingsViewController {
        return SettingsViewController()
    }
}
