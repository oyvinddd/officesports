//
//  SportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseCore

protocol SportsAPI {
    
    static func signIn()
    
    static func registerNickname(nickname: String)
    
    static func registerEmoji(emoji: String)
    
    static func getScoreboard()
    
    static func getMatchHistory()
    
    static func deleteAccount()
}

// MARK: - Firebase Service implements the Sports API

final class FirebaseService: SportsAPI {
    
    //private static var db: Firestore
    
    static func signIn() {
        
    }
    
    static func registerNickname(nickname: String) {
    }
    
    static func registerEmoji(emoji: String) {
        
    }
    
    static func getScoreboard() {
        
    }
    
    static func getMatchHistory() {
        
    }
    
    static func deleteAccount() {
        
    }
}
