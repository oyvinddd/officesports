//
//  OSAccount.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseAuth

struct OSAccount: Codable {
    
    static let current = OSAccount(
        accountId: "id#123",
        username: "o_hauge",
        totalFoosballScore: 2100,
        totalTableTennisScore: 800
    )
    
    var accountId: String
    
    var username: String
    
    var totalFoosballScore: Int
    
    var totalTableTennisScore: Int
    
    var loggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
