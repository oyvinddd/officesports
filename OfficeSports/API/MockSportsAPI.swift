//
//  MockSportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 20/05/2022.
//

import UIKit

final class MockSportsAPI: SportsAPI {

    private static let fst = [
        OSStats(sport: .foosball, score: 0, matchesPlayed: 1, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .foosball, score: 1, matchesPlayed: 20, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .foosball, score: 0, matchesPlayed: 2, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .foosball, score: 11, matchesPlayed: 10, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .foosball, score: 0, matchesPlayed: 20, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .foosball, score: 0, matchesPlayed: 700, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .foosball, score: 110, matchesPlayed: 2, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .foosball, score: 0, matchesPlayed: 2, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .foosball, score: 100, matchesPlayed: 1, matchesWon: 0, seasonWins: 0)
    ]
    
    private static let tst = [
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 1, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .tableTennis, score: 1, matchesPlayed: 2, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .tableTennis, score: 200, matchesPlayed: 300, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .tableTennis, score: 11, matchesPlayed: 10, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 1000, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 7, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .tableTennis, score: 44, matchesPlayed: 30, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 32, matchesWon: 0, seasonWins: 0),
        OSStats(sport: .tableTennis, score: 0, matchesPlayed: 1, matchesWon: 0, seasonWins: 0)
    ]
    
    private let players = [
        OSAccount.current.player!,
        
        OSPlayer(nickname: "heimegut", emoji: "💩", team: OSTeam(id: "id#123", name: "Ekornes AS"), foosballStats: fst[1], tableTennisStats: tst[1]),
        OSPlayer(nickname: "salmaaan", emoji: "🧐", team: OSTeam(id: "id#123", name: "Ekornes AS"), foosballStats: fst[2], tableTennisStats: tst[2]),
        OSPlayer(nickname: "patidati", emoji: "👻", team: OSTeam(id: "id#123", name: "Ekornes AS"), foosballStats: fst[3], tableTennisStats: tst[3]),
        OSPlayer(nickname: "sekse", emoji: "🤖", team: OSTeam(id: "id#123", name: "Ekornes AS"), foosballStats: fst[4], tableTennisStats: tst[4]),
        OSPlayer(nickname: "dimling", emoji: "👨🏻‍🎨", team: OSTeam(id: "id#123", name: "Ekornes AS"), foosballStats: fst[5], tableTennisStats: tst[5]),
        OSPlayer(nickname: "konstant", emoji: "☀️", team: OSTeam(id: "id#123", name: "Ekornes AS"), foosballStats: fst[6], tableTennisStats: tst[6]),
        OSPlayer(nickname: "eirik", emoji: "👑", team: OSTeam(id: "id#123", name: "Ekornes AS"), foosballStats: fst[7], tableTennisStats: tst[7]),
        OSPlayer(nickname: "panzertax", emoji: "🐹", team: OSTeam(id: "id#123", name: "Ekornes AS"), foosballStats: fst[8], tableTennisStats: tst[8])
    ]
    
    private lazy var scoreboard: [OSPlayer] = {
        return players
    }()
    
    private lazy var matches: [OSMatch] = {
        return [
//            OSMatch(date: Date(), sport: .foosball, winner: players[0], loser: players[2], loserDelta: -16, winnerDelta: 16),
//            OSMatch(date: Date(), sport: .foosball, winner: players[1], loser: players[0], loserDelta: -16, winnerDelta: 9),
//            OSMatch(date: Date(), sport: .tableTennis, winner: players[4], loser: players[7], loserDelta: -8, winnerDelta: 12)
        ]
    }()
    
    private var profileEmoji = "🙃"
    private var profileNickname = "oyvindhauge"
    private var signedIn = false
    
    func signIn(_ viewController: UIViewController, result: @escaping (Result<Bool, Error>) -> Void) {
        signedIn = true
        result(.success(true))
    }
    
    func signOut() -> Error? {
        signedIn = false
        return nil
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func createOrUpdatePlayerProfile(nickname: String, emoji: String, team: OSTeam?, result: @escaping ((Result<OSPlayer, Error>) -> Void)) {
        let foosballStats = OSStats(sport: .foosball, score: 0, matchesPlayed: 0, matchesWon: 0, seasonWins: 0)
        let tableTennisStats = OSStats(sport: .tableTennis, score: 0, matchesPlayed: 0, matchesWon: 0, seasonWins: 0)
        let player = OSPlayer(id: "id#1337", nickname: nickname, emoji: emoji, team: OSTeam.noTeam, foosballStats: foosballStats, tableTennisStats: tableTennisStats)
        result(.success(player))
    }
    
    func getPlayerProfile(result: @escaping ((Result<OSPlayer, Error>) -> Void)) {
        result(.success(OSAccount.current.player!))
    }
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Result<OSMatch, Error>) -> Void)) {
//        let winner = OSAccount.current.player
//        let foosballStats = OSStats(id: nil, sport: .foosball, score: 0, matchesPlayed: 0)
//        let tableTennisStats = OSStats(id: nil, sport: .tableTennis, score: 0, matchesPlayed: 0)
//        let loser = OSPlayer(id: "id#1337", nickname: "salmaaan", emoji: "🌹", foosballStats: foosballStats, tableTennisStats: tableTennisStats)
//        let match = OSMatch(date: Date(), sport: registration.sport, winner: winner!, loser: loser, loserDelta: 14, winnerDelta: 12)
//        result(.success(match))
    }
    
    func getScoreboard(sport: OSSport, result: @escaping ((Result<[OSPlayer], Error>) -> Void)) {
        var sortedScoreboard: [OSPlayer] = []
        if sport == .foosball {
            sortedScoreboard = scoreboard.sorted(by: { $0.foosballStats!.score > $1.foosballStats!.score })
        } else if sport == .tableTennis {
            sortedScoreboard = scoreboard.sorted(by: { $0.tableTennisStats!.score > $1.tableTennisStats!.score })
        }
        result(.success(sortedScoreboard))
    }
    
    func getMatchHistory(sport: OSSport, result: @escaping ((Result<[OSMatch], Error>) -> Void)) {
        var filteredMatches: [OSMatch] = []
        if sport == .foosball {
            filteredMatches = matches.filter({ $0.sport == .foosball })
        } else if sport == .tableTennis {
            filteredMatches = matches.filter({ $0.sport == .tableTennis })
        }
        result(.success(filteredMatches))
    }
    
    func getLatestMatches(sport: OSSport, winnerId: String, loserId: String, result: @escaping ((Result<[OSMatch], Error>) -> Void)) {
        let player1 = OSPlayer(nickname: "oyvinddd", emoji: "🙂")
        let player2 = OSPlayer(nickname: "salmaaan", emoji: "😞")
        let match1 = OSMatch(sport: sport, winner: player1, loser: player2, winnerDt: 12, loserDt: 12)
        let match2 = OSMatch(sport: sport, winner: player1, loser: player2, winnerDt: 8, loserDt: 8)
        let match3 = OSMatch(sport: sport, winner: player1, loser: player2, winnerDt: 4, loserDt: 4)
        result(.success([match1, match2, match3]))
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping ((Result<OSInvite, Error>) -> Void)) {
        let invite = OSInvite(date: Date(), sport: .foosball, inviterId: "id#1", inviteeId: "id#2", inviteeNickname: "heimegut")
        result(.success(invite))
    }
    
    func getActiveInvites(result: @escaping ((Result<[OSInvite], Error>) -> Void)) {
        let invite = OSInvite(date: Date(), sport: .foosball, inviterId: "id#1", inviteeId: "id#2", inviteeNickname: "heimegut")
        result(.success([invite]))
    }
    
    func getSeasonStats(result: @escaping ((Result<[OSSeasonStats], Error>) -> Void)) {
        result(.success([OSSeasonStats(date: Date(), winner: OSAccount.current.player!, sport: .tableTennis)]))
    }
    
    func getTeams(result: @escaping ((Result<[OSTeam], Error>) -> Void)) {
        let team1 = OSTeam(id: "id123", name: "Tietoevry Create - Bergen")
        let team2 = OSTeam(id: "id321", name: "Tietoevry Banking - Bergen")
        result(.success([team1, team2]))
    }
}

// MARK: - Conform to the async/await versions of the API methods

extension MockSportsAPI {
    
    func signIn(viewController: UIViewController) async throws -> Bool {
        return try await withCheckedThrowingContinuation({ continuation in
            signIn(viewController) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func createOrUpdatePlayerProfile(nickname: String, emoji: String, team: OSTeam?) async throws -> OSPlayer {
        return try await withCheckedThrowingContinuation({ continuation in
            createOrUpdatePlayerProfile(nickname: nickname, emoji: emoji, team: team) { result in
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
    
    func registerMatch(registration: OSMatchRegistration) async throws -> OSMatch {
        return try await withCheckedThrowingContinuation({ continuation in
            registerMatch(registration) { result in
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
    
    func getMatchHistory(sport: OSSport) async throws -> [OSMatch] {
        return try await withCheckedThrowingContinuation({ continuation in
            getMatchHistory(sport: sport) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func getLatestMatches(sport: OSSport, winnerId: String, loserId: String) async throws -> [OSMatch] {
        return try await withCheckedThrowingContinuation({ continuation in
            getLatestMatches(sport: sport, winnerId: winnerId, loserId: loserId) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport) async throws -> OSInvite {
        return try await withCheckedThrowingContinuation({ continuation in
            invitePlayer(player, sport: sport) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func  getActiveInvites() async throws -> [OSInvite] {
        return try await withCheckedThrowingContinuation({ continuation in
            getActiveInvites { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func  getSeasonStats() async throws -> [OSSeasonStats] {
        return try await withCheckedThrowingContinuation({ continuation in
            getSeasonStats { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func getTeams() async throws -> [OSTeam] {
        return try await withCheckedThrowingContinuation({ continuation in
            getTeams { result in
                continuation.resume(with: result)
            }
        })
    }
}
