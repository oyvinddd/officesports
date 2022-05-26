//
//  MockSportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 20/05/2022.
//

import UIKit

final class MockSportsAPI: SportsAPI {

    private static let fs = [
        OSStats(sport: .foosball, totalScore: 0, totalMatches: 1),
        OSStats(sport: .foosball, totalScore: 1, totalMatches: 0),
        OSStats(sport: .foosball, totalScore: 0, totalMatches: 0),
        OSStats(sport: .foosball, totalScore: 11, totalMatches: 10),
        OSStats(sport: .foosball, totalScore: 0, totalMatches: 0),
        OSStats(sport: .foosball, totalScore: 0, totalMatches: 7),
        OSStats(sport: .foosball, totalScore: 44, totalMatches: 10),
        OSStats(sport: .foosball, totalScore: 0, totalMatches: 0),
        OSStats(sport: .foosball, totalScore: 100, totalMatches: 0)
    ]
    
    private static let tts = [
        OSStats(sport: .tableTennis, totalScore: 0, totalMatches: 1),
        OSStats(sport: .tableTennis, totalScore: 1, totalMatches: 0),
        OSStats(sport: .tableTennis, totalScore: 0, totalMatches: 0),
        OSStats(sport: .tableTennis, totalScore: 11, totalMatches: 10),
        OSStats(sport: .tableTennis, totalScore: 0, totalMatches: 0),
        OSStats(sport: .tableTennis, totalScore: 0, totalMatches: 7),
        OSStats(sport: .tableTennis, totalScore: 44, totalMatches: 10),
        OSStats(sport: .tableTennis, totalScore: 0, totalMatches: 0),
        OSStats(sport: .tableTennis, totalScore: 100, totalMatches: 0)
    ]
    
    private let players = [
        OSPlayer(userId: "id#1", nickname: "oyvindhauge", emoji: "🙃", foosballStats: fs[0], tableTennisStats: tts[0]),
        OSPlayer(userId: "id#2", nickname: "heimegut", emoji: "💩", foosballStats: fs[1], tableTennisStats: tts[1]),
        OSPlayer(userId: "id#3", nickname: "salmaaan", emoji: "🧐", foosballStats: fs[2], tableTennisStats: tts[2]),
        OSPlayer(userId: "id#4", nickname: "patidati", emoji: "👻", foosballStats: fs[3], tableTennisStats: tts[3]),
        OSPlayer(userId: "id#5", nickname: "sekse", emoji: "🤖", foosballStats: fs[4], tableTennisStats: tts[4]),
        OSPlayer(userId: "id#6", nickname: "dimling", emoji: "👨🏻‍🎨", foosballStats: fs[5], tableTennisStats: tts[5]),
        OSPlayer(userId: "id#7", nickname: "konstant", emoji: "☀️", foosballStats: fs[6], tableTennisStats: tts[6]),
        OSPlayer(userId: "id#8", nickname: "eirik", emoji: "👑", foosballStats: fs[7], tableTennisStats: tts[7]),
        OSPlayer(userId: "id#9", nickname: "panzertax", emoji: "🐹", foosballStats: fs[8], tableTennisStats: tts[8])
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
    
    func registerPlayerProfile(nickname: String, emoji: String, result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void)) {
        var sortedScoreboard: [OSPlayer] = []
        if sport == .foosball {
            sortedScoreboard = scoreboard.sorted(by: { $0.foosballStats.totalScore > $1.foosballStats.totalScore })
        } else if sport == .tableTennis {
            sortedScoreboard = scoreboard.sorted(by: { $0.tableTennisStats.totalScore > $1.tableTennisStats.totalScore })
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
    
    func getActiveInvites(result: @escaping (([OSInvite], Error?) -> Void)) {
        let invite = OSInvite(date: Date(), sport: .foosball, inviterId: "id#1", inviteeId: "id#2", inviteeNickname: "heimegut")
        result([invite], nil)
    }
}
