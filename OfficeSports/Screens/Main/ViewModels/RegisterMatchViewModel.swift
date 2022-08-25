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
        // players are not allowed to register matches if it's currently weekend.
        // all matches counting towards a player's score should be played at the office.
        guard !Calendar.current.isDateInWeekend(Date.now) else {
            let message = OSMessage("Not allowed to register matches during the weekend 🍺", .info)
            Coordinator.global.send(message)
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
}
