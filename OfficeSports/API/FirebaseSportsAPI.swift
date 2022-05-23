//
//  FirebaseSportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

private let fbPlayersCollection = "players"
private let fbMatchesCollection = "matches"
private let fbInvitesCollection = "invites"

final class FirebaseSportsAPI: SportsAPI {
    
    private let database = Firestore.firestore()
    
    func signIn(_ viewController: UIViewController, result: @escaping ((Error?) -> Void)) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { (user, error) in
            if let error = error {
                result(error)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                result(OSError.missingToken)
                return
            }
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credentials) { (_, error) in
                result(error)
            }
        }
    }
    
    func signOut() -> Error? {
        do {
            try Auth.auth().signOut()
        } catch let error {
            return error
        }
        return nil
    }
    
    func checkNicknameAvailability(_ nickname: String, result: @escaping ((Error?) -> Void)) {
        let usersCollection = database.collection(fbPlayersCollection)
        let query = usersCollection.whereField("nickname", isEqualTo: nickname.lowercased())
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                result(error)
            } else {
                let count = snapshot!.documents.count
                result(count > 0 ? OSError.nicknameTaken : nil)
            }
        }
    }
    
    func registerPlayerProfile(nickname: String, emoji: String, result: @escaping ((Error?) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result(OSError.unauthorized)
            return
        }
        
        let playersCollection = database.collection(fbPlayersCollection)
        let data: [String: Any] = ["nickname": nickname, "emoji": emoji]
        
        playersCollection.document(uid).setData(data, mergeFields: Array(data.keys)) { error in
            result(error)
        }
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void)) {
        database.collection(fbPlayersCollection).getDocuments { (snapshot, error) in
            if let error = error {
                result([], error)
            } else {
                let players = self.playersFromDocuments(snapshot!.documents)
                result(players, nil)
            }
        }
    }
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Error?) -> Void)) {
        guard registration.winnerId != registration.loserId else {
            result(OSError.invalidOpponent)
            return
        }
        
        let playersCollection = database.collection(fbPlayersCollection)
        
        database.runTransaction { (transaction, errorPointer) in
            
            playersCollection.document(registration.loserId)
            
        } completion: { (object, error) in
        }

        /*
        let data: [String: Any] = [:]
        database.collection(fbMatchesCollection).addDocument(data: data) { error in
            result(error)
        }
        */
    }
    
    func getMatchHistory(sport: OSSport, result: @escaping (([OSMatch], Error?) -> Void)) {
        let query = database.collection(fbMatchesCollection).whereField("sport", isEqualTo: sport.rawValue)
        query.getDocuments { [unowned self] (snapshot, error) in
            if let error = error {
                result([], error)
            } else {
                let matches = matchesFromDocuments(snapshot!.documents)
                result(matches, nil)
            }
        }
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping (Error?) -> Void) {
        guard let accountPlayer = OSAccount.current.player else {
            result(OSError.missingPlayer)
            return
        }
        _ = OSInvite(date: Date(), sport: sport, inviter: accountPlayer, invitee: player)
        // database.collection(fbInvitesCollection).addDocument(from: invite)
    }
    
    // ##################################
    // ##   PRIVATE HELPER FUNCTIONS   ##
    // ##################################
    
    private func playersFromDocuments(_ documents: [QueryDocumentSnapshot]) -> [OSPlayer] {
        // https://peterfriese.dev/posts/firestore-codable-the-comprehensive-guide/
        var players = [OSPlayer]()
        
        for document in documents {
            do {
                let player = try document.data(as: OSPlayer.self)
                players.append(player)
            } catch let error {
                print(error.localizedDescription)
                return []
            }
        }
        return players
    }
    
    private func matchesFromDocuments(_ documents: [QueryDocumentSnapshot]) -> [OSMatch] {
        var matches = [OSMatch]()
        
        for document in documents {
            do {
                let match = try document.data(as: OSMatch.self)
                matches.append(match)
            } catch let error {
                print(error.localizedDescription)
                return []
            }
        }
        return matches
    }
    
    // never used
    private func clearProfileDetails() {
        let standardDefaults = UserDefaults.standard
        let dictionary = standardDefaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            standardDefaults.removeObject(forKey: key)
        }
    }
}
