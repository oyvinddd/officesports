//
//  Coordinator.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

enum AppState: Int, RawRepresentable {
    case authorized, unauthorized, missingOrg, missingProfileDetails
}

final class Coordinator {
    
    static var global = Coordinator(account: OSAccount.current, window: nil)
    
    var account: OSAccount
    
    var window: UIWindow?
    
    var messageWindow: MessageWindow = {
        return MessageWindow()
    }()
    
    var currentState: AppState = .authorized {
        didSet { updateRootViewController(animated: true) }
    }
    
    init(account: OSAccount, window: UIWindow?) {
        self.account = account
        self.window = window
    }
    
    func checkAndHandleAppState() {
        if !account.signedIn {
            changeAppState(.unauthorized)
        } else if !account.hasValidProfileDetails {
            changeAppState(.missingProfileDetails)
        } else {
            changeAppState(.authorized)
        }
    }
    
    func changeAppState(_ state: AppState) {
        guard state != currentState || window?.rootViewController == nil else {
            return
        }
        currentState = state
    }
    
    func send(_ message: OSMessage) {
        messageWindow.showMessage(message)
    }
    
    func send(_ error: Error) {
        let message = OSMessage(error.localizedDescription, .failure)
        messageWindow.showMessage(message)
    }
    
    func presentPlayerProfile(from viewController: UIViewController) {
        viewController.present(playerProfileViewController, animated: true)
    }
    
    func presentSettings(from viewController: UIViewController) {
        viewController.present(settingsViewController, animated: false)
    }
    
    func presentPreferences(from viewController: UIViewController) {
        viewController.present(preferencesViewController, animated: true)
    }
    
    func presentAbout(from viewController: UIViewController) {
        viewController.present(aboutViewController, animated: true)
    }
    
    func presentEmojiPicker(from parent: UIViewController, emojis: [String], animated: Bool = true) {
        let viewController = EmojiPickerViewController(emojis: emojis)
        parent.present(viewController, animated: animated)
    }
    
    func presentPlayerDetails(_ player: OSPlayer, sport: OSSport) {
        let viewModel = InvitePlayerViewModel(api: FirebaseSportsAPI())
        let viewController = PlayerDetailsViewController(viewModel: viewModel, player: player, sport: sport)
        window?.rootViewController?.present(viewController, animated: false)
    }
    
    private func updateRootViewController(animated: Bool) {
        guard let window = window else {
            fatalError("Application window doesn't exist.")
        }
        var viewController: UIViewController?
        switch currentState {
        case .authorized:
            viewController = mainViewController
        case .missingProfileDetails:
            viewController = playerProfileViewController
        case .missingOrg:
            viewController = playerProfileViewController
        case .unauthorized:
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
        let viewModel = AuthViewModel(api: FirebaseSportsAPI())
        return WelcomeViewController(viewModel: viewModel)
    }
    
    var playerProfileViewController: PlayerProfileViewController {
        let viewModel = PlayerProfileViewModel(api: FirebaseSportsAPI())
        return PlayerProfileViewController(viewModel: viewModel)
    }
    
    var mainViewController: MainViewController {
        return MainViewController()
    }
    
    var settingsViewController: SettingsViewController {
        return SettingsViewController()
    }
    
    var preferencesViewController: PreferencesViewController {
        return PreferencesViewController()
    }
    
    var aboutViewController: AboutViewController {
        return AboutViewController()
    }
}
