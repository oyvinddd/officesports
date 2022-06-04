//
//  SportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

protocol SportsAPI {
    
    func signIn(_ viewController: UIViewController, result: @escaping ((Error?) -> Void))
    
    func signOut() -> Error?
    
    func deleteAccount(result: @escaping ((Error?) -> Void))
    
    @available(*, renamed: "createPlayerProfile(nickname:emoji:)")
    func createPlayerProfile(nickname: String, emoji: String, result: @escaping (Result<OSPlayer, Error>) -> Void)
    
    @available(*, renamed: "getPlayerProfile()")
    func getPlayerProfile(result: @escaping ((Result<OSPlayer, Error>) -> Void))
    
    func checkNicknameAvailability(_ nickname: String, result: @escaping ((Error?) -> Void))
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Error?) -> Void))
    
    @available(*, renamed: "getScoreboard(sport:)")
    func getScoreboard(sport: OSSport, result: @escaping ((Result<[OSPlayer], Error>) -> Void))
    
    func getMatchHistory(sport: OSSport, result: @escaping (([OSMatch], Error?) -> Void))
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping ((Error?) -> Void))
    
    func getActiveInvites(result: @escaping (([OSInvite], Error?) -> Void))
    
    // MARK: - Async/await API
    
    func createPlayerProfile(nickname: String, emoji: String) async throws -> OSPlayer
    
    func getPlayerProfile() async throws -> OSPlayer
    
    func getScoreboard(sport: OSSport) async throws -> [OSPlayer]
}
