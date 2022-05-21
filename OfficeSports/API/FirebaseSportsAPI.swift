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

private let fbUsersCollection = "users"
private let fbMatchesCollection = "matches"
private let fbInvitesCollection = "invites"

private let userDefaultsNicknameKey = "nickname"
private let userdefaultsEmojiKey = "emoji"

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
                result(APIError.missingToken)
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
        clearProfileDetails()
        return nil
    }
    
    func saveProfileDetails(nickname: String, emoji: String) {
        let standardDefaults = UserDefaults.standard
        standardDefaults.set(nickname, forKey: userDefaultsNicknameKey)
        standardDefaults.set(emoji, forKey: userdefaultsEmojiKey)
    }
    
    func loadProfileDetails() -> (String?, String?) {
        let standardDefaults = UserDefaults.standard
        let nickname = standardDefaults.object(forKey: userDefaultsNicknameKey) as? String
        let emoji = standardDefaults.object(forKey: userdefaultsEmojiKey) as? String
        return (nickname, emoji)
    }
    
    func checkNicknameAvailability(_ nickname: String, result: @escaping ((Error?) -> Void)) {
        let usersCollection = database.collection(fbUsersCollection)
        let query = usersCollection.whereField("nickname", isEqualTo: nickname.lowercased())
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                result(error)
            } else {
                let count = snapshot!.documents.count
                result(count > 0 ? APIError.nicknameTaken : nil)
            }
        }
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
    
    func getScoreboard(sport: OSSport, result: @escaping (([OSPlayer], Error?) -> Void)) {
        database.collection(fbUsersCollection).getDocuments { (snapshot, error) in
            if let error = error {
                result([], error)
            } else {
                let players = self.playersFromDocuments(snapshot!.documents)
                result(players, nil)
            }
        }
    }
    
    func registerMatch(_ match: OSMatch, result: @escaping ((Error?) -> Void)) {
        let data: [String: Any] = [
            "date": FieldValue.serverTimestamp(),
            "winnerDelta": 0,
            "loserDelta": 0
        ]
        
        database.collection(fbMatchesCollection).addDocument(data: data) { error in
            result(error)
        }
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
            result(APIError.missingPlayer)
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
    
    private func clearProfileDetails() {
        let standardDefaults = UserDefaults.standard
        let dictionary = standardDefaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            standardDefaults.removeObject(forKey: key)
        }
    }
}

// MARK: - Custom Errors for the sports API

private enum APIError: LocalizedError {
    
    case missingToken
    
    case nicknameTaken
    
    case missingPlayer
    
    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "Missing ID token"
        case .nicknameTaken:
            return "Nickname already taken"
        case .missingPlayer:
            return "Unauthorized. Missing player details."
        }
    }
}
