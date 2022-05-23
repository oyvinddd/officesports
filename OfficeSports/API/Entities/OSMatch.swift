//
//  OSMatch.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

struct OSMatch: Codable {
    
    var date: Date
    
    var sport: OSSport
    
    var winner: OSPlayer
    
    var loser: OSPlayer
    
    var loserDelta: Int
    
    var winnerDelta: Int
}
