//
//  SportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

protocol SportsAPI {
    
    @available(*, renamed: "createOrUpdatePlayerProfile(nickname:emoji:)")
    func createOrUpdatePlayerProfile(nickname: String, emoji: String, result: @escaping (Result<OSPlayer, Error>) -> Void)
    
    @available(*, renamed: "getPlayerProfile()")
    func getPlayerProfile(result: @escaping ((Result<OSPlayer, Error>) -> Void))
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Error?) -> Void))
    
    @available(*, renamed: "getScoreboard(sport:)")
    func getScoreboard(sport: OSSport, result: @escaping ((Result<[OSPlayer], Error>) -> Void))
    
    @available(*, renamed: "getMatchHistory(sport:)")
    func getMatchHistory(sport: OSSport, result: @escaping ((Result<[OSMatch], Error>) -> Void))
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping ((Error?) -> Void))
    
    @available(*, renamed: "getActiveInvites()")
    func getActiveInvites(result: @escaping ((Result<[OSInvite], Error>) -> Void))
    
    // MARK: - Async/await API
    
    func createOrUpdatePlayerProfile(nickname: String, emoji: String) async throws -> OSPlayer
    
    func getPlayerProfile() async throws -> OSPlayer
    
    func getScoreboard(sport: OSSport) async throws -> [OSPlayer]
    
    func getMatchHistory(sport: OSSport) async throws -> [OSMatch]
    
    func getActiveInvites() async throws -> [OSInvite]
}
