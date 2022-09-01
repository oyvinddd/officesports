//
//  ResultListViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

private let fanaticalPlayerThreshold = 10

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
    private(set) var fanatic: OSPlayer?
    
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
                scoreboard = getActivePlayers(allPlayers, sport: sport)
                idlePlayers = getIdlePlayers(allPlayers, sport: sport)
                fanatic = findFanaticalPlayer(scoreboard)
                
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
    
    private func getActivePlayers(_ players: [OSPlayer], sport: OSSport) -> [OSPlayer] {
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
    
    private func findFanaticalPlayer(_ players: [OSPlayer]) -> OSPlayer? {
        let player = players.max {
            $0.matchesPlayed(sport: sport) < $1.matchesPlayed(sport: sport)
        }
        guard let matchesPlayed = player?.matchesPlayed(sport: sport) else {
            return nil
        }
        // to be fanatical, one has to have played at least 10
        // matches and be the player with the most matches overall
        return matchesPlayed >= fanaticalPlayerThreshold ? player : nil
    }
}
