//
//  OSStats.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 24/05/2022.
//

import Foundation

struct OSStats: Codable {
    
    var sport: OSSport
    
    var score: Int
    
    var matchesPlayed: Int
    
    var matchesWon: Int
    
    var seasonWins: Int
}
