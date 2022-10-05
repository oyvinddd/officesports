//
//  FirebaseSportsAPI+AsyncAwait.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 09/08/2022.
//

import UIKit

extension FirebaseSportsAPI {
    
    func createOrUpdatePlayerProfile(nickname: String, emoji: String, team: OSTeam) async throws -> OSPlayer {
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
    
    func getSeasonStats() async throws -> [OSSeasonStats] {
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
    
    func joinTeam(request: OSTeamRequest) async throws -> OSTeam {
        return try await withCheckedThrowingContinuation({ continuation in
            joinTeam(request) { result in
                continuation.resume(with: result)
            }
        })
    }
}
