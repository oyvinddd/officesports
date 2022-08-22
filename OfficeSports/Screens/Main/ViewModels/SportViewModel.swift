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
    private(set) var idlePlayers = [OSPlayer]()
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
                let allPlayers = try await api.getScoreboard(sport: sport)
                scoreboard = getNormalPlayers(allPlayers, sport: sport)
                idlePlayers = getIdlePlayers(allPlayers, sport: sport)
                
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
    
    private func getNormalPlayers(_ players: [OSPlayer], sport: OSSport) -> [OSPlayer] {
        return players.filter({ !isIdlePlayer($0, sport: sport) })
    }
    
    private func getIdlePlayers(_ players: [OSPlayer], sport: OSSport) -> [OSPlayer] {
        return players.filter({ isIdlePlayer($0, sport: sport) })
    }
    
    private func isIdlePlayer(_ player: OSPlayer, sport: OSSport) -> Bool {
        let tableTennisMatches = player.tableTennisStats?.matchesPlayed ?? 0
        let foosballMatches = player.foosballStats?.matchesPlayed ?? 0
        return sport == .tableTennis ? tableTennisMatches == 0 : foosballMatches == 0
    }
}
