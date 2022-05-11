//
//  ResultListViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

final class ScoreboardViewModel {

    let results: [OSPlayer] = [
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800),
        OSPlayer(userId: "123", username: "oyvindhauge", foosballScore: 1800, tableTennisScore: 1800)
    ]
    
    private var sport: OSSport
    
    init(sport: OSSport) {
        self.sport = sport
    }
}
