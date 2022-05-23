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
    
    func registerPlayerProfile(nickname: String, emoji: String, result: @escaping ((Error?) -> Void))
    
    func checkNicknameAvailability(_ nickname: String, result: @escaping ((Error?) -> Void))
    
    func registerMatch(_ match: OSMatch, result: @escaping ((Error?) -> Void))
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void))
    
    func getMatchHistory(sport: OSSport, result: @escaping (([OSMatch], Error?) -> Void))
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping (Error?) -> Void)
}
