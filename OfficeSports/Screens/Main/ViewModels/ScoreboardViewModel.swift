//
//  ResultListViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

final class ScoreboardViewModel {

    private let results: [OSPlayer] = [
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", nickname: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800)
    ]
    
    var leaderboard: [OSPlayer] {
        return results
    }
    
    var recentMatches: [OSPlayer] {
        return results
    }
    
    private var sport: OSSport
    
    init(sport: OSSport) {
        self.sport = sport
    }
}
