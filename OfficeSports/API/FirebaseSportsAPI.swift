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

private let fbCloudFuncBaseUrl = "https://us-central1-officesports-5d7ac.cloudfunctions.net"
private let fbCloudFuncRegisterMatchUrl = "/winMatch"

private let maxResultsInScoreboard = 200
private let maxResultsInRecentMatches = 300
private let maxResultsInLatestMatches = 10

private let fbPlayersCollection = "players"
private let fbMatchesCollection = "matches"
private let fbInvitesCollection = "invites"
private let fbSeasonsCollection = "seasons"
private let fbTeamsCollection = "teams"

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
    
    private var seasonsCollection: CollectionReference {
        database.collection(fbSeasonsCollection)
    }
    
    private var teamsCollection: CollectionReference {
        database.collection(fbTeamsCollection)
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
    
    func createOrUpdatePlayerProfile(nickname: String, emoji: String, team: OSTeam?, result: @escaping ((Result<OSPlayer, Error>) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result(.failure(OSError.unauthorized))
            return
        }
        
        let fields = ["nickname", "emoji", "team"]
        var data: [String: Any] = ["nickname": nickname, "emoji": emoji]
        
        if let team = team {
            do {
                data["team"] = try Firestore.Encoder().encode(team)
            } catch let error {
                print(error)
            }
        }
        let player = OSPlayer(id: uid, nickname: nickname, emoji: emoji, team: team ?? OSTeam.noTeam)
        
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
            case .success(var player):
                player.id = uid
                result(.success(player))
            case .failure(let error):
                result(.failure(error))
            }
        }
    }
    
    func getScoreboard(sport: OSSport, result: @escaping ((Result<[OSPlayer], Error>) -> Void)) {
        var query = playersCollection
            .order(by: fieldPathForSport(sport), descending: true)
            .limit(to: maxResultsInScoreboard)
        
        // if player has chosen a team, only show scoreboard of players that has joined the same team
        if let currentTeamId = OSAccount.current.player?.team.id {
            query = query.whereField("team.id", isEqualTo: currentTeamId)
        }
        
        query.getDocuments { (snapshot, error) in
            guard let error = error else {
                let players = self.playersFromDocuments(snapshot!.documents, sport: sport)
                result(.success(players))
                return
            }
            result(.failure(error))
        }
    }
    
    func getMatchHistory(sport: OSSport, result: @escaping ((Result<[OSMatch], Error>) -> Void)) {
        let query = matchesCollection
            .whereField("sport", isEqualTo: sport.rawValue)
            .order(by: "date", descending: true)
            .limit(to: maxResultsInRecentMatches)
        
        query.getDocuments { [unowned self] (snapshot, error) in
            guard let error = error else {
                let matches = matchesFromDocuments(snapshot!.documents)
                result(.success(matches))
                return
            }
            result(.failure(error))
        }
    }
    
    func getLatestMatches(sport: OSSport, winnerId: String, loserId: String, result: @escaping ((Result<[OSMatch], Error>) -> Void)) {
        guard winnerId != loserId else {
            result(.failure(OSError.identicalUserIds))
            return
        }
        // create the query for recent matches between two players
        let query = matchesCollection
            .whereField(FieldPath(["winner", "userId"]), isEqualTo: winnerId)
            .whereField(FieldPath(["loser", "userId"]), isEqualTo: loserId)
            .order(by: "date", descending: true)
            .limit(to: maxResultsInLatestMatches)
        
        // execute the query
        query.getDocuments { (snapshot, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            let matches = snapshot?.documents.compactMap({ docSnapshot -> OSMatch? in
                return try? docSnapshot.data(as: OSMatch.self)
            })
            result(.success(matches ?? []))
        }
    }
    
    func registerMatch(_ registration: OSMatchRegistration, result: @escaping ((Result<OSMatch, Error>) -> Void)) {
        guard registration.winnerId != registration.loserId else {
            result(.failure(OSError.invalidOpponent))
            return
        }
        
        // build http request
        var request = URLRequest(url: URL(string: "\(fbCloudFuncBaseUrl)\(fbCloudFuncRegisterMatchUrl)")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(registration)
        
        // execute request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let urlResponse = response as? HTTPURLResponse, let data = data else {
                result(.failure(OSError.unknown))
                return
            }
            guard 200 ..< 300 ~= urlResponse.statusCode else {
                result(.failure(OSError.unknown))
                return
            }
            
            do {
                let match = try JSONDecoder().decode(OSMatch.self, from: data)
                result(.success(match))
            } catch let error {
                result(.failure(error))
            }
        }
        task.resume()
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport, result: @escaping ((Result<OSInvite, Error>) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result(.failure(OSError.unauthorized))
            return
        }
        guard uid != player.id, let inviteeId = player.id else {
            result(.failure(OSError.invalidInvite))
            return
        }
        
        let invite = OSInvite(date: Date(), sport: sport, inviterId: uid, inviteeId: inviteeId, inviteeNickname: player.nickname)
        
        do {
            let data = try Firestore.Encoder().encode(invite)
            
            invitesCollection.addDocument(data: data) { error in
                guard let error = error else {
                    result(.success(invite))
                    return
                }
                result(.failure(error))
            }
        } catch let error {
            result(.failure(error))
        }
    }
    
    func getActiveInvites(result: @escaping ((Result<[OSInvite], Error>) -> Void)) {
        guard let uid = OSAccount.current.userId else {
            result(.failure(OSError.unauthorized))
            return
        }
        
        // 24 hours from now
        // let calendar = Calendar.current
        // let date = calendar.date(byAdding: .hour, value: -24, to: Date())!
        
        // find invites the current user has sent that are not older than 24 hours
        let query = invitesCollection
            .whereField("inviterId", isEqualTo: uid)
            // .whereField("date", isGreaterThan: date)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                result(.success([]))
                return
            }
            let invites = documents.compactMap { documentSnapshot -> OSInvite? in
                return try? documentSnapshot.data(as: OSInvite.self)
            }
            result(.success(invites))
        }
    }
    
    func getSeasonStats(result: @escaping ((Result<[OSSeasonStats], Error>) -> Void)) {
        guard OSAccount.current.userId != nil else {
            result(.failure(OSError.unauthorized))
            return
        }
        
        let query = seasonsCollection.order(by: "date", descending: true)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                result(.success([]))
                return
            }
            let seasons = documents.compactMap { documentSnapshot -> OSSeasonStats? in
                return try? documentSnapshot.data(as: OSSeasonStats.self)
            }
            result(.success(seasons))
        }
    }
    
    func getTeams(result: @escaping ((Result<[OSTeam], Error>) -> Void)) {
        guard OSAccount.current.signedIn else {
            result(.failure(OSError.unauthorized))
            return
        }
        
        teamsCollection.getDocuments { (snapshot, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                result(.success([]))
                return
            }
            let teams = documents.compactMap { documentSnapshot -> OSTeam? in
                var team = try? documentSnapshot.data(as: OSTeam.self)
                team?.id = documentSnapshot.documentID
                return team
            }
            result(.success(teams))
        }
    }
    
    // ##################################
    // ##   PRIVATE HELPER FUNCTIONS   ##
    // ##################################
    
    private func playersFromDocuments(_ documents: [QueryDocumentSnapshot], sport: OSSport) -> [OSPlayer] {
        let requiredField = sport == .foosball ? "foosballStats" : "tableTennisStats"
        var players = [OSPlayer]()
        
        for document in documents {
            guard document.get(requiredField) != nil else {
                continue
            }
            do {
                var player = try document.data(as: OSPlayer.self)
                player.id = document.documentID
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
    
    private func fieldPathForSport(_ sport: OSSport) -> String {
        switch sport {
        case .foosball:
            return "foosballStats.score"
        case .tableTennis:
            return "tableTennisStats.score"
        case .pool:
            return "poolStats.score"
        case .unknown:
            return ""
        }
    }
}
