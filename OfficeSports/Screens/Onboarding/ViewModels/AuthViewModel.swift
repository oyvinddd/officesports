//
//  AuthViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import UIKit
import Combine

final class AuthViewModel {
    
    enum State {
        case idle
        case loading
        case signInSuccess
        case signInFailure(Error)
        case signOutSuccess
        case signOutFailure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func signIn(from viewController: UIViewController) {
        state = .loading
        
        Task {
            do {
                _ = try await api.signIn(viewController: viewController)
                
                do {
                    let player = try await api.getPlayerProfile()
                    _ = UserDefaultsHelper.savePlayerProfile(player)
                    _ = UserDefaults.CodeWidget.saveCodePayloadDetails(player.nickname, player.id)
                    OSAccount.current.player = player
                } catch {
                    // this just mean that the user hasn't registered a player profile yet, so just move along
                }
                state = .signInSuccess
            } catch let error {
                state = .signInFailure(error)
            }
        }
    }
    
    func signOut() {
        guard let error = api.signOut() else {
            state = .signOutSuccess
            return
        }
        state = .signOutFailure(error)
    }
}
