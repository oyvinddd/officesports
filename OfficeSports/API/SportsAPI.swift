//
//  SportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseFirestore

protocol SportsAPI {
    
    static func signIn()
    
    static func registerNicknameAndEmoji(_ nickname: String, _ emoji: String)
    
    static func getScoreboard()
    
    static func getMatchHistory()
    
    static func deleteAccount()
}

// MARK: - Firebase Service implements the Sports API

final class FirebaseService: SportsAPI {
    
    private static var database = Firestore.firestore()
    
    static func signIn() {
        
    }
    
    static func registerNicknameAndEmoji(_ nickname: String, _ emoji: String) {
        var ref: DocumentReference? = nil
        
        ref = database
    }
    
    static func getScoreboard() {
        
    }
    
    static func getMatchHistory() {
        
    }
    
    static func deleteAccount() {
        
    }
}
