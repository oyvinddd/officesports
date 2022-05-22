//
//  OSPlayer.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

struct OSPlayer: Codable {
    
    var userId: String
    
    var nickname: String
    
    var emoji: String
    
    var foosballScore: Int
    
    var tableTennisScore: Int
    
    var matchesPlayed: Int
}
