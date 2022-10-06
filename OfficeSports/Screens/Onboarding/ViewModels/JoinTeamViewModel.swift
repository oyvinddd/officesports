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
        
        case success(OSTeam)
        
        case failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    private(set) var teams: [OSTeam] = []
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func joinTeam(_ team: OSTeam, password: String) {
        state = .loading
        
        // build our request join team request
        let request = OSJoinTeamRequest(
            teamId: team.id,
            playerId: OSAccount.current.userId,
            password: password
        )
        
        Task {
            do {
                let team = try await api.joinTeam(request: request)
                state = .success(team)
            } catch let error {
                state = .failure(error)
            }
        }
    }
}
