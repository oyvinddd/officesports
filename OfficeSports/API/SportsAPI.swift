//
//  SportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol SportsAPI {
    
    func signIn(result: @escaping ((Error?) -> Void))
    
    func registerProfileDetails(_ details: OSProfileDetails, result: @escaping ((Error?) -> Void))
    
    func registerMatch(winner: OSPlayer, loser: OSPlayer, result: @escaping ((Error?) -> Void))
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void))
    
    func getMatchHistory(sport: OSSport, result: @escaping (([OSMatchResult], Error?) -> Void))
    
    func deleteAccount(result: @escaping ((Error?) -> Void))
}

// MARK: - Firebase Sports API implements the Sports API protocol

private let fbDetailsCollection = "profileDetails"
private let fbScoreboardCollection = "scoreboard"
private let fbMatchHistoryCollection = "matchHistory"

final class FirebaseSportsAPI: SportsAPI {
    
    private let database = Firestore.firestore()
    
    func signIn(result: @escaping ((Error?) -> Void)) {
    }
    
    func registerProfileDetails(_ details: OSProfileDetails, result: @escaping ((Error?) -> Void)) {
        do {
            try database.collection(fbDetailsCollection).document("123").setData(from: details, merge: true)
            result(nil)
        } catch let error {
            result(error)
        }
    }
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void)) {
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
    
    func registerMatch(winner: OSPlayer, loser: OSPlayer, result: @escaping ((Error?) -> Void)) {
    }
    
    func getMatchHistory(sport: OSSport, result: @escaping (([OSMatchResult], Error?) -> Void)) {
        let query = database.collection(fbMatchHistoryCollection).whereField("sport", isEqualTo: sport.rawValue)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                result([], error)
            } else {
                
            }
        }
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
}
