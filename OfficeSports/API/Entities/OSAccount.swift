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

final class OSAccount: Codable {
    
    static let current = OSAccount()
    
    var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var signedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var hasValidProfileDetails: Bool {
        return nickname != nil && emoji != nil
    }
    
    var nickname: String?
    
    var emoji: String?
    
    var player: OSPlayer? {
        guard signedIn,
                let uid = userId,
                let nickname = nickname,
                let emoji = emoji else {
            return nil
        }
        let foosballStats = OSStats(sport: .foosball, totalScore: 0, totalMatches: 10)
        let tableTennisStats = OSStats(sport: .tableTennis, totalScore: 12, totalMatches: 40)
        return OSPlayer(
            userId: uid,
            nickname: nickname,
            emoji: emoji,
            foosballStats: foosballStats,
            tableTennisStats: tableTennisStats
        )
    }
    
    init() {
        let (nick, emoji) = loadProfileDetails()
        self.nickname = nick
        self.emoji = emoji
        printStatus()
    }
    
    func qrCodePayloadForSport(_ sport: OSSport) -> OSCodePayload? {
        guard let uid = userId, let nickname = nickname else {
            print("Unable to get user ID since user is not logged in.")
            return nil
        }
        return OSCodePayload(userId: uid, nickname: nickname, sport: sport)
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
