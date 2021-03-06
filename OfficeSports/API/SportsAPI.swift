//
//  SportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

protocol SportsAPI {
    
    @available(*, renamed: "signIn(viewController:)")
    func signIn(_ viewController: UIViewController, result: @escaping ((Result<Bool, Error>) -> Void))
    
    func signOut() -> Error?
    
    func deleteAccount(result: @escaping ((Error?) -> Void))
    
    @available(*, renamed: "createOrUpdatePlayerProfile(nickname:emoji:)")
    func createOrUpdatePlayerProfile(nickname: String, emoji: String, result: @escaping ((Result<OSPlayer, Error>) -> Void))
    
    @available(*, renamed: "getPlayerProfile()")
    func getPlayerProfile(result: @escaping ((Result<OSPlayer, Error>) -> Void))
    
    @available(*, renamed: "registerMatch(registration:)")
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Result<OSMatch, Error>) -> Void))
    
    @available(*, renamed: "getScoreboard(sport:)")
    func getScoreboard(sport: OSSport, result: @escaping ((Result<[OSPlayer], Error>) -> Void))
    
    @available(*, renamed: "getMatchHistory(sport:)")
    func getMatchHistory(sport: OSSport, result: @escaping ((Result<[OSMatch], Error>) -> Void))
    
    @available(*, renamed: "invitePlayer(player:sport:)")
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping ((Result<OSInvite, Error>) -> Void))
    
    @available(*, renamed: "getActiveInvites()")
    func getActiveInvites(result: @escaping ((Result<[OSInvite], Error>) -> Void))
    
    @available(*, renamed: "getSeasonStats()")
    func getSeasonStats(result: @escaping ((Result<[OSSeasonStats], Error>) -> Void))
    
    // MARK: - Async/await API
    
    func signIn(viewController: UIViewController) async throws -> Bool
    
    func createOrUpdatePlayerProfile(nickname: String, emoji: String) async throws -> OSPlayer
    
    func getPlayerProfile() async throws -> OSPlayer
    
    func registerMatch(registration: OSMatchRegistration) async throws -> OSMatch
    
    func getScoreboard(sport: OSSport) async throws -> [OSPlayer]
    
    func getMatchHistory(sport: OSSport) async throws -> [OSMatch]
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport) async throws -> OSInvite
    
    func getActiveInvites() async throws -> [OSInvite]
    
    func getSeasonStats() async throws -> [OSSeasonStats]
}
