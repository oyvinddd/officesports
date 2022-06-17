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
    
    var isReady: Bool {
        switch state {
        case .idle:
            return true
        default:
            return false
        }
    }
    
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func registerMatch(_ registration: OSMatchRegistration) {
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
