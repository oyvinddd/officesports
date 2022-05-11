//
//  OSAccount.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

struct OSAccount: Codable {
    
    static let current = OSAccount(accountId: "123", username: "oyvindhauge", totalScore: 1800)
    
    var accountId: String
    
    var username: String
    
    var totalScore: Int
    
    var loggedIn: Bool {
        return false
    }
}
