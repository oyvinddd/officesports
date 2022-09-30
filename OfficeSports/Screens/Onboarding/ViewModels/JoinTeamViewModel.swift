//
//  JoinTeamViewModel.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 29/09/2022.
//

import Foundation

final class JoinTeamViewModel {
    
    enum State {
        
        case idle
        
        case loading
        
        case success
        
        case failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    private(set) var teams: [OSTeam] = []
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func fetchTeams() {
        state = .loading
        Task {
            do {
                teams = try await api.getTeams().sorted(by: { $0.name < $1.name })
                self.state = .success
            } catch let error {
                state = .failure(error)
            }
        }
    }
    
    func joinTeam() {
        state = .loading
        Task {
            
        }
    }
}
