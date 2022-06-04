//
//  MockSportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 20/05/2022.
//

import UIKit

final class MockSportsAPI: SportsAPI {
    
    private static let fst = [
        OSStats(sport: .foosball, score: 0, matchesPlayed: 1),
        OSStats(sport: .foosball, score: 1, matchesPlayed: 20),
        OSStats(sport: .foosball, score: 0, matchesPlayed: 2),
        OSStats(sport: .foosball, score: 11, matchesPlayed: 10),
        OSStats(sport: .foosball, score: 0, matchesPlayed: 20),
        OSStats(sport: .foosball, score: 0, matchesPlayed: 700),
        OSStats(sport: .foosball, score: 110, matchesPlayed: 2),
        OSStats(sport: .foosball, score: 0, matchesPlayed: 2),
        OSStats(sport: .foosball, score: 100, matchesPlayed: 1)
    ]
    
    private static let tst = [
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 1),
        OSStats(sport: .tableTennis, score: 1, matchesPlayed: 2),
        OSStats(sport: .tableTennis, score: 200, matchesPlayed: 300),
        OSStats(sport: .tableTennis, score: 11, matchesPlayed: 10),
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 1000),
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 7),
        OSStats(sport: .tableTennis, score: 44, matchesPlayed: 30),
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 32),
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 1)
    ]
    
    private let players = [
        OSAccount.current.player!,
        OSPlayer(nickname: "heimegut", emoji: "💩", foosballStats: fst[1], tableTennisStats: tst[1]),
        OSPlayer(nickname: "salmaaan", emoji: "🧐", foosballStats: fst[2], tableTennisStats: tst[2]),
        OSPlayer(nickname: "patidati", emoji: "👻", foosballStats: fst[3], tableTennisStats: tst[3]),
        OSPlayer(nickname: "sekse", emoji: "🤖", foosballStats: fst[4], tableTennisStats: tst[4]),
        OSPlayer(nickname: "dimling", emoji: "👨🏻‍🎨", foosballStats: fst[5], tableTennisStats: tst[5]),
        OSPlayer(nickname: "konstant", emoji: "☀️", foosballStats: fst[6], tableTennisStats: tst[6]),
        OSPlayer(nickname: "eirik", emoji: "👑", foosballStats: fst[7], tableTennisStats: tst[7]),
        OSPlayer(nickname: "panzertax", emoji: "🐹", foosballStats: fst[8], tableTennisStats: tst[8])
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
    
    func createPlayerProfile(nickname: String, emoji: String, result: @escaping ((Result<OSPlayer, Error>) -> Void)) {
        let foosballStats = OSStats(id: nil, sport: .foosball, score: 0, matchesPlayed: 0)
        let tableTennisStats = OSStats(id: nil, sport: .tableTennis, score: 0, matchesPlayed: 0)
        let player = OSPlayer(id: "id#1337", nickname: nickname, emoji: emoji, foosballStats: foosballStats, tableTennisStats: tableTennisStats)
        result(.success(player))
    }
    
    func getPlayerProfile(result: @escaping ((Result<OSPlayer, Error>) -> Void)) {
        result(.success(OSAccount.current.player!))
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func getScoreboard(sport: OSSport, result: @escaping ((Result<[OSPlayer], Error>) -> Void)) {
        var sortedScoreboard: [OSPlayer] = []
        if sport == .foosball {
            sortedScoreboard = scoreboard.sorted(by: { $0.foosballStats.score > $1.foosballStats.score })
        } else if sport == .tableTennis {
            sortedScoreboard = scoreboard.sorted(by: { $0.tableTennisStats.score > $1.tableTennisStats.score })
        }
        result(.success(sortedScoreboard))
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

// MARK: - Confirm to the async/await versions of the API methods

extension MockSportsAPI {
    
    func createPlayerProfile(nickname: String, emoji: String) async throws -> OSPlayer {
        return try await withCheckedThrowingContinuation({ continuation in
            createPlayerProfile(nickname: nickname, emoji: emoji) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func getPlayerProfile() async throws -> OSPlayer {
        return try await withCheckedThrowingContinuation({ continuation in
            getPlayerProfile { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func getScoreboard(sport: OSSport) async throws -> [OSPlayer] {
        return try await withCheckedThrowingContinuation({ continuation in
            getScoreboard(sport: sport) { result in
                continuation.resume(with: result)
            }
        })
    }
}
