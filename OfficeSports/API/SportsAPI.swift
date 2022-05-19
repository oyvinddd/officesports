//
//  SportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol SportsAPI {
    
    func signIn(_ viewController: UIViewController, result: @escaping ((Error?) -> Void))
    
    func registerProfileDetails(_ details: OSProfileDetails, result: @escaping ((Error?) -> Void))
    
    func registerMatch(winner: OSPlayer, loser: OSPlayer, result: @escaping ((Error?) -> Void))
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void))
    
    func getMatchHistory(sport: OSSport, result: @escaping (([OSMatchResult], Error?) -> Void))
    
    func deleteAccount(result: @escaping ((Error?) -> Void))
}

// MARK: - Firebase Sports API implements the Sports API protocol

private let fbDetailsCollection = "profileDetails"
private let fbUsersCollection = "users"
private let fbMatchHistoryCollection = "matchHistory"

final class FirebaseSportsAPI: SportsAPI {
    
    private let database = Firestore.firestore()
    
    func signIn(_ viewController: UIViewController, result: @escaping ((Error?) -> Void)) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { [unowned self] user, error in
            if let error = error {
                result(error)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                // TODO: return error
                return
            }
            
            let credentials = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: authentication.accessToken
            )
            
            Auth.auth().signIn(with: credentials) { [unowned self] authResult, error in
                if let error = error {
                    result(error)
                } else {
                    result(nil)
                }
            }
        }
    }
    
    func registerProfileDetails(_ details: OSProfileDetails, result: @escaping ((Error?) -> Void)) {
        do {
            // TODO: document should in this case be the users own user id
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
