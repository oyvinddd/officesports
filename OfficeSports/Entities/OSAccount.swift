//
//  OSAccount.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseAuth

private let nicknameUserDefaultsKey = "nickname"
private let emojiUserDefaultsKey = "emoji"

struct OSAccount: Codable {
    
    static let current = OSAccount()
    
    var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var loggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var player: OSPlayer? {
        guard loggedIn, let uid = userId else {
            return nil
        }
        return OSPlayer(
            userId: uid,
            nickname: nickname,
            emoji: emoji,
            foosballScore: foosballScore,
            tableTennisScore: tableTennisScore
        )
    }
    
    var nickname: String = ""
    
    var emoji: String = ""
    
    var foosballScore: Int = 0
    
    var tableTennisScore: Int = 0
    
    func qrCodePayloadForSport(_ sport: OSSport) -> OSCodePayload? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Unable to get user ID since user is not logged in.")
            return nil
        }
        return OSCodePayload(userId: uid, sport: sport)
    }
    
    func printStatus() {
        let currentUser = Auth.auth().currentUser
        let signedIn = currentUser != nil
        let userId = currentUser?.uid ?? ""
        print(
            "🔐 Signed in: [\(signedIn)]\n" +
            "🎁 User ID: [\(userId)]\n" +
            "🧸 Nickname: [\(nickname)]\n" +
            "🙃 Emoji: [\(emoji)]"
        )
    }
}
