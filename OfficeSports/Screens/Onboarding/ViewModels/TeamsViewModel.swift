//
//  TeamsViewModel.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 07/07/2022.
//

import Foundation

final class TeamsViewModel {
    
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
}
