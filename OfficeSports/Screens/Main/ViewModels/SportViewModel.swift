//
//  ResultListViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

final class SportViewModel {
    
    enum State {
        case idle
        case loading
        case scoreboardSuccess
        case recentMatchesSuccess
        case failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    let sport: OSSport
    
    private(set) var scoreboard = [OSPlayer]()
    private(set) var recentMatches = [OSMatch]()
    
    private let api: SportsAPI
    
    init(api: SportsAPI, sport: OSSport) {
        self.api = api
        self.sport = sport
    }
    
    func fetchSportData() {
        fetchScoreboard()
        fetchRecentMatches()
    }
    
    func fetchScoreboard() {
        state = .loading
        
        Task {
            do {
                scoreboard = try await api.getScoreboard(sport: sport)
                state = .scoreboardSuccess
            } catch let error {
                state = .failure(error)
            }
        }
    }
    
    func fetchRecentMatches() {
        state = .loading
        
        Task {
            do {
                recentMatches = try await api.getMatchHistory(sport: sport)
                state = .recentMatchesSuccess
            } catch let error {
                state = .failure(error)
            }
        }
    }
}
