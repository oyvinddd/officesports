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

private let maxResultsInScoreboard = 200
private let maxResultsInRecentMatches = 100

private let fbPlayersCollection = "players"
private let fbMatchesCollection = "matches"
private let fbInvitesCollection = "invites"

final class FirebaseSportsAPI: SportsAPI {

    private let database = Firestore.firestore()
    
    private var playersCollection: CollectionReference {
        database.collection(fbPlayersCollection)
    }
    
    private var matchesCollection: CollectionReference {
        database.collection(fbMatchesCollection)
    }
    
    private var invitesCollection: CollectionReference {
        database.collection(fbInvitesCollection)
    }
    
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
        let query = playersCollection.whereField("nickname", isEqualTo: nickname.lowercased())
        
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
        
        let data: [String: Any] = ["nickname": nickname, "emoji": emoji]
        
        playersCollection.document(uid).setData(data, mergeFields: Array(data.keys)) { error in
            result(error)
        }
    }
    
    func getPlayerProfile(result: @escaping ((OSPlayer?, Error?) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result(nil, OSError.unauthorized)
            return
        }
        playersCollection.document(uid).getDocument(as: OSPlayer.self) { fbResult in
            switch fbResult {
            case .success(let player):
                result(player, nil)
            case .failure(let error):
                result(nil, error)
            }
        }
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        fatalError("Delete account endpoint has not been implementet yet!")
    }
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void)) {
        playersCollection.limit(to: maxResultsInScoreboard).getDocuments { (snapshot, error) in
            guard let error = error else {
                let players = self.playersFromDocuments(snapshot!.documents)
                result(players, nil)
                return
            }
            result([], error)
        }
    }
    
    func getMatchHistory(sport: OSSport, result: @escaping (([OSMatch], Error?) -> Void)) {
        let query = matchesCollection.limit(to: maxResultsInRecentMatches).whereField("sport", isEqualTo: sport.rawValue)
        query.getDocuments { [unowned self] (snapshot, error) in
            guard let error = error else {
                let matches = matchesFromDocuments(snapshot!.documents)
                result(matches, nil)
                return
            }
            result([], error)
        }
    }
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Error?) -> Void)) {
        guard registration.winnerId != registration.loserId else {
            result(OSError.invalidOpponent)
            return
        }
        
        database.runTransaction { [unowned self] (transaction, errorPointer) in
            
            self.playersCollection.document(registration.loserId)
            
        } completion: { (object, error) in
        }
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping (Error?) -> Void) {
        guard let uid = OSAccount.current.userId else {
            result(OSError.unauthorized)
            return
        }
        guard uid != player.userId else {
            result(OSError.invalidInvite)
            return
        }
        
        let invitesCollection = database.collection(fbInvitesCollection)
        let invite = OSInvite(date: Date(), sport: sport, inviterId: uid, inviteeId: player.userId, inviteeNickname: player.nickname)
        
        do {
            let data = try Firestore.Encoder().encode(invite)
            invitesCollection.addDocument(data: data) { error in
                result(error)
            }
        } catch let error {
            result(error)
        }
    }
    
    func getActiveInvites(result: @escaping (([OSInvite], Error?) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result([], OSError.unauthorized)
            return
        }
        
        let query = invitesCollection.whereField("inviterId", isEqualTo: uid)
        
        query.getDocuments { (querySnapshot, error) in
            guard let error = error else {
                var invites = [OSInvite]()
                for document in querySnapshot!.documents {
                    do {
                        let invite = try document.data(as: OSInvite.self)
                        invites.append(invite)
                    } catch let error {
                        result([], error)
                    }
                }
                result(invites, nil)
                return
            }
            result([], error)
        }
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
}
