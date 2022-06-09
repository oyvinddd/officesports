//
//  FirebaseSportsAPI.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import FirebaseCore
import GoogleSignIn
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
    
    func signIn(_ viewController: UIViewController, result: @escaping (Result<Bool, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { (user, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                result(.failure(OSError.missingToken))
                return
            }
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credentials) { (_, error) in
                if let error = error {
                    result(.failure(error))
                } else {
                    result(.success(true))
                }
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
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        fatalError("Delete account endpoint has not been implementet yet!")
    }
    
    func createOrUpdatePlayerProfile(nickname: String, emoji: String, result: @escaping ((Result<OSPlayer, Error>) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result(.failure(OSError.unauthorized))
            return
        }
        
        let fields = ["nickname", "emoji"]
        let data = ["nickname": nickname, "emoji": emoji]
        let player = OSPlayer(nickname: nickname, emoji: emoji)
        
        playersCollection.document(uid).setData(data, mergeFields: fields) { error in
            guard let error = error else {
                result(.success(player))
                return
            }
            result(.failure(error))
        }
    }
    
    func getPlayerProfile(result: @escaping ((Result<OSPlayer, Error>) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result(.failure(OSError.unauthorized))
            return
        }
        playersCollection.document(uid).getDocument(as: OSPlayer.self) { fbResult in
            switch fbResult {
            case .success(let player):
                result(.success(player))
            case .failure(let error):
                result(.failure(error))
            }
        }
    }
    
    func getScoreboard(sport: OSSport, result: @escaping ((Result<[OSPlayer], Error>) -> Void)) {
        let fieldPath = sport == .foosball ? "foosballStats.score" : "tableTennisStats.score"
        playersCollection.order(by: fieldPath, descending: true).limit(to: maxResultsInScoreboard).getDocuments { (snapshot, error) in
            guard let error = error else {
                let players = self.playersFromDocuments(snapshot!.documents, sport: sport)
                result(.success(players))
                return
            }
            result(.failure(error))
        }
    }
    
    func getMatchHistory(sport: OSSport, result: @escaping ((Result<[OSMatch], Error>) -> Void)) {
        let query = matchesCollection.limit(to: maxResultsInRecentMatches).whereField("sport", isEqualTo: sport.rawValue)
        query.getDocuments { [unowned self] (snapshot, error) in
            guard let error = error else {
                let matches = matchesFromDocuments(snapshot!.documents)
                result(.success(matches))
                return
            }
            result(.failure(error))
        }
    }
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Error?) -> Void)) {
        fatalError("registerMatch has not been implemented yet!")
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping (Error?) -> Void) {
        guard let uid = OSAccount.current.userId else {
            result(OSError.unauthorized)
            return
        }
        guard uid != player.id, let inviteeId = player.id else {
            result(OSError.invalidInvite)
            return
        }
        
        let invitesCollection = database.collection(fbInvitesCollection)
        let invite = OSInvite(date: Date(), sport: sport, inviterId: uid, inviteeId: inviteeId, inviteeNickname: player.nickname)
        
        do {
            let data = try Firestore.Encoder().encode(invite)
            invitesCollection.addDocument(data: data) { error in
                result(error)
            }
        } catch let error {
            result(error)
        }
    }
    
    func getActiveInvites(result: @escaping ((Result<[OSInvite], Error>) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result(.failure(OSError.unauthorized))
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
                        result(.failure(error))
                    }
                }
                result(.success(invites))
                return
            }
            result(.failure(error))
        }
    }
    
    // ##################################
    // ##   PRIVATE HELPER FUNCTIONS   ##
    // ##################################
    
    private func playersFromDocuments(_ documents: [QueryDocumentSnapshot], sport: OSSport) -> [OSPlayer] {
        // https://peterfriese.dev/posts/firestore-codable-the-comprehensive-guide/
        let requiredField = sport == .foosball ? "foosballStats" : "tableTennisStats"
        var players = [OSPlayer]()
        
        for document in documents {
            guard document.get(requiredField) != nil else {
                continue
            }
            do {
                let player = try document.data(as: OSPlayer.self)
                players.append(player)
            } catch let error {
                print(error)
                continue
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
                print(error)
                continue
            }
        }
        return matches
    }
}

// MARK: - Conform to the async/await versions of the API methods

extension FirebaseSportsAPI {
    
    func signIn(viewController: UIViewController) async throws -> Bool {
        return try await withCheckedThrowingContinuation({ continuation in
            signIn(viewController) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func createOrUpdatePlayerProfile(nickname: String, emoji: String) async throws -> OSPlayer {
        return try await withCheckedThrowingContinuation({ continuation in
            createOrUpdatePlayerProfile(nickname: nickname, emoji: emoji) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func getPlayerProfile() async throws -> OSPlayer {
        return try await withCheckedThrowingContinuation({ continuation in
            getPlayerProfile { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func getScoreboard(sport: OSSport) async throws -> [OSPlayer] {
        return try await withCheckedThrowingContinuation({ continuation in
            getScoreboard(sport: sport) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func getMatchHistory(sport: OSSport) async throws -> [OSMatch] {
        return try await withCheckedThrowingContinuation({ continuation in
            getMatchHistory(sport: sport) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func  getActiveInvites() async throws -> [OSInvite] {
        return try await withCheckedThrowingContinuation({ continuation in
            getActiveInvites { result in
                continuation.resume(with: result)
            }
        })
    }
}
