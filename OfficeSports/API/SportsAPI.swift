//
//  SportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseFirestore

protocol SportsAPI {
    
    static func signIn(result: @escaping ((Error?) -> Void))
    
    static func registerNicknameAndEmoji(_ nickname: String, _ emoji: String, result: @escaping ((Error?) -> Void))
    
    static func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void))
    
    static func getMatchHistory(sport: OSSport, result: @escaping (([OSMatchResult], Error?) -> Void))
    
    static func deleteAccount(result: @escaping ((Error?) -> Void))
}

// MARK: - Firebase Service implements the Sports API

private let fbScoreboardCollection = "scoreboard"
private let fbMatchHistoryCollection = "matchHistory"

final class FirebaseService: SportsAPI {
    
    private static var database = Firestore.firestore()
    
    static func signIn(result: @escaping ((Error?) -> Void)) {
        
    }
    
    static func registerNicknameAndEmoji(_ nickname: String, _ emoji: String, result: @escaping ((Error?) -> Void)) {
        //var ref: DocumentReference? = nil
        //ref = database
    }
    
    static func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void)) {
        //database.collection(fbScoreboardCollection).getDocument(as: )
        /*
        database.collection(fbScoreboardCollection).getDocuments { (snapshot, error) in
            if let error = error {
                result([], error)
            } else {
                for doc in snapshot!.documents {
                    
                }
            }
        }
         */
    }
    
    static func getMatchHistory(sport: OSSport, result: @escaping (([OSMatchResult], Error?) -> Void)) {
        let query = database.collection(fbMatchHistoryCollection).whereField("sport", isEqualTo: sport.rawValue)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                result([], error)
            } else {
                
            }
        }
    }
    
    static func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
}
