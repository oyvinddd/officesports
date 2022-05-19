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
    
    static let current = OSAccount(player: OSPlayer(userId: "id#123", nickname: "o_hauge", emoji: "🧐", foosballScore: 1600, tableTennisScore: 1800))
    
    var player: OSPlayer
    
    var loggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
