//
//  OSMatchResult.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

struct OSMatchResult: Codable {
    
    var timestamp: Date
    
    var winner: OSPlayer
    
    var loser: OSPlayer
    
    var sport: OSSport
}
