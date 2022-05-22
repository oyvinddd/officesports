//
//  OSAccount.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseAuth

private let userDefaultsNicknameKey = "nickname"
private let userdefaultsEmojiKey = "emoji"

struct OSAccount: Codable {
    
    static let current = OSAccount()
    
    var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var signedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var validProfileDetails: Bool {
        return nickname != nil && emoji != nil
    }
    
    var player: OSPlayer? {
        guard signedIn,
                let uid = userId,
                let nickname = nickname,
                let emoji = emoji else {
            return nil
        }
        return OSPlayer(
            userId: uid,
            nickname: nickname,
            emoji: emoji,
            foosballScore: foosballScore,
            tableTennisScore: tableTennisScore,
            matchesPlayed: 0
        )
    }
    
    var nickname: String?
    
    var emoji: String?
    
    var foosballScore: Int = 0
    
    var tableTennisScore: Int = 0
    
    init() {
        let (nick, emoji) = loadProfileDetails()
        self.nickname = nick
        self.emoji = emoji
        printStatus()
    }
    
    func qrCodePayloadForSport(_ sport: OSSport) -> OSCodePayload? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Unable to get user ID since user is not logged in.")
            return nil
        }
        return OSCodePayload(userId: uid, sport: sport)
    }
    
    func loadProfileDetails() -> (String?, String?) {
        let standardDefaults = UserDefaults.standard
        let nickname = standardDefaults.object(forKey: userDefaultsNicknameKey) as? String
        let emoji = standardDefaults.object(forKey: userdefaultsEmojiKey) as? String
        return (nickname, emoji)
    }
    
    func printStatus() {
        let currentUser = Auth.auth().currentUser
        let signedIn = currentUser != nil
        let userId = currentUser?.uid ?? ""
        print(
            "🔐 Signed in: [\(signedIn)]\n" +
            "🎁 User ID: [\(userId)]\n" +
            "🧸 Nickname: [\(nickname ?? "None")]\n" +
            "🙃 Emoji: [\(emoji ?? "None")]"
        )
    }
}
