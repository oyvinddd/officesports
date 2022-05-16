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
    
    static let current = OSAccount(
        accountId: "id#123",
        totalFoosballScore: 2100,
        totalTableTennisScore: 800
    )
    
    var accountId: String
    
    var nickname: String?
    
    var emoji: String?
    
    var totalFoosballScore: Int
    
    var totalTableTennisScore: Int
    
    var loggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}

extension OSAccount {
    
    mutating func loadNicknameAndEmoji() {
        let defaults = UserDefaults.standard
        nickname = defaults.object(forKey: nicknameUserDefaultsKey) as? String
        emoji = defaults.object(forKey: emojiUserDefaultsKey) as? String
    }
}
