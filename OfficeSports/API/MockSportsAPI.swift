//
//  MockSportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 20/05/2022.
//

import UIKit

final class MockSportsAPI: SportsAPI {
    
    private let players = [
        OSPlayer(userId: "id#1", nickname: "oyvindhauge", emoji: "🙃", foosballScore: 1699, tableTennisScore: 1550, matchesPlayed: 0),
        OSPlayer(userId: "id#2", nickname: "heimegut", emoji: "💩", foosballScore: 1558, tableTennisScore: 1500, matchesPlayed: 0),
        OSPlayer(userId: "id#3", nickname: "salmaaan", emoji: "🧐", foosballScore: 1619, tableTennisScore: 905, matchesPlayed: 0),
        OSPlayer(userId: "id#4", nickname: "patidati", emoji: "👻", foosballScore: 2100, tableTennisScore: 1480, matchesPlayed: 0),
        OSPlayer(userId: "id#5", nickname: "sekse", emoji: "🤖", foosballScore: 1558, tableTennisScore: 1200, matchesPlayed: 0),
        OSPlayer(userId: "id#6", nickname: "dimling", emoji: "👨🏻‍🎨", foosballScore: 1498, tableTennisScore: 1100, matchesPlayed: 0),
        OSPlayer(userId: "id#7", nickname: "konstant", emoji: "☀️", foosballScore: 1570, tableTennisScore: 1220, matchesPlayed: 0),
        OSPlayer(userId: "id#8", nickname: "eirik", emoji: "👑", foosballScore: 1300, tableTennisScore: 912, matchesPlayed: 0),
        OSPlayer(userId: "id#9", nickname: "panzertax", emoji: "🐹", foosballScore: 1483, tableTennisScore: 1799, matchesPlayed: 0)
    ]
    
    private lazy var scoreboard: [OSPlayer] = {
        return players
    }()
    
    private lazy var matches: [OSMatch] = {
        return [
            OSMatch(date: Date(), sport: .foosball, winner: players[0], loser: players[2], loserDelta: -16, winnerDelta: 16),
            OSMatch(date: Date(), sport: .foosball, winner: players[1], loser: players[0], loserDelta: -16, winnerDelta: 9),
            OSMatch(date: Date(), sport: .tableTennis, winner: players[4], loser: players[7], loserDelta: -8, winnerDelta: 12)
        ]
    }()
    
    private var signedIn = false
    private var profileEmoji = "🙃"
    private var profileNickname = "oyvindhauge"
    
    func signIn(_ viewController: UIViewController, result: @escaping ((Error?) -> Void)) {
        signedIn = true
        result(nil)
    }
    
    func signOut() -> Error? {
        signedIn = false
        return nil
    }
    
    func checkNicknameAvailability(_ nickname: String, result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func saveProfileDetails(nickname: String, emoji: String) {
        profileNickname = nickname
        profileEmoji = emoji
    }
    
    func loadProfileDetails() -> (String?, String?) {
        return (profileNickname, profileEmoji)
    }
    
    func registerMatch(_ match: OSMatch, result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void)) {
        var sortedScoreboard: [OSPlayer] = []
        if sport == .foosball {
            sortedScoreboard = scoreboard.sorted(by: { $0.foosballScore > $1.foosballScore })
        } else if sport == .tableTennis {
            sortedScoreboard = scoreboard.sorted(by: { $0.tableTennisScore > $1.tableTennisScore })
        }
        result(sortedScoreboard, nil)
    }
    
    func getMatchHistory(sport: OSSport, result: @escaping (([OSMatch], Error?) -> Void)) {
        var filteredMatches: [OSMatch] = []
        if sport == .foosball {
            filteredMatches = matches.filter({ $0.sport == .foosball })
        } else if sport == .tableTennis {
            filteredMatches = matches.filter({ $0.sport == .tableTennis })
        }
        result(filteredMatches, nil)
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping (Error?) -> Void) {
        result(nil)
    }
}
