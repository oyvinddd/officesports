//
//  OSMatchRegistration.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import Foundation

struct OSMatchRegistration: Codable {
    
    var sport: OSSport
    
    var winnerIds: [String]
    
    var loserIds: [String]
}
