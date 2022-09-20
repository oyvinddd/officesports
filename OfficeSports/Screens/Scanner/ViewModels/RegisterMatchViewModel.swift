//
//  RegisterMatchViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 20/05/2022.
//

import Foundation

final class RegisterMatchViewModel {
    
    enum State {
        case idle
        
        case loading
        
        case success(OSMatch)
        
        case failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func registerMatch(_ registration: OSMatchRegistration) {
        guard !isWeekendAndIsNotTestUser(registration) else {
            Coordinator.global.send(OSError.noWeekendRegistrations)
            return
        }
        state = .loading
        Task {
            do {
                let match = try await api.registerMatch(registration: registration)
                state = .success(match)
            } catch let error {
                state = .failure(error)
            }
        }
    }
    
    private func isWeekendAndIsNotTestUser(_ registration: OSMatchRegistration) -> Bool {
        // bypass weekend check if we're working with test users
        for id in registration.winnerIds + registration.loserIds where id.contains("test_") {
            print("Test user(s) found! Can register matches even if it's weekend 👻")
            return false
        }
        // players are not allowed to register matches if it's currently weekend.
        // all matches counting towards a player's score should be played at the office.
        return !Calendar.current.isDateInWeekend(Date.now)
    }
}
