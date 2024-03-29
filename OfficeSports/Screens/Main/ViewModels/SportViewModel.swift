//
//  ResultListViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

private let fanaticalPlayerThreshold = 10
private let specialIndicatorScoreboardMinLength = 5

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
    private(set) var boring: OSPlayer?
    
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
                boring = findMostBoringPlayer(scoreboard)
                
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
        let matchesPlayed = player.statsForSport(sport)?.matchesPlayed ?? 0
        return matchesPlayed == 0
    }
    
    private func findFanaticalPlayer(_ players: [OSPlayer]) -> OSPlayer? {
        // don't show any special indicator if there are less than 5 people on the scoreboard
        guard players.count >= specialIndicatorScoreboardMinLength else {
            return nil
        }
        let sortedPlayers = players.sorted {
            $0.noOfmatchesForSport(sport) > $1.noOfmatchesForSport(sport)
        }
        // if the two top players have the same score, don't add indicator
        let p1Stats = sortedPlayers[0].statsForSport(sport)?.score ?? 0
        let p2Stats = sortedPlayers[1].statsForSport(sport)?.score ?? 0
        if p1Stats != 0 && p2Stats != 0 && p1Stats == p2Stats {
            return nil
        }
        let player = sortedPlayers.first
        guard let matchesPlayed = player?.noOfmatchesForSport(sport) else {
            return nil
        }
        // to be fanatical, one has to have played at least 10
        // matches and be the player with the most matches overall
        return matchesPlayed >= fanaticalPlayerThreshold ? player : nil
    }
    
    private func findMostBoringPlayer(_ players: [OSPlayer]) -> OSPlayer? {
        // don't show any special indicator if there are less than 5 people on the scoreboard
        guard players.count >= specialIndicatorScoreboardMinLength else {
            return nil
        }
        let sortedPlayers = players.sorted {
            $0.noOfmatchesForSport(sport) < $1.noOfmatchesForSport(sport)
        }
        let p1Matches = sortedPlayers[0].statsForSport(sport)?.matchesPlayed ?? 0
        let p2Matches = sortedPlayers[1].statsForSport(sport)?.matchesPlayed ?? 0
        if p1Matches == p2Matches || p1Matches == 0 {
            return nil
        }
        return sortedPlayers.first
    }
}
