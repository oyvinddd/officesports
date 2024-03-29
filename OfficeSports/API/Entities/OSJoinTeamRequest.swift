//
//  OSTeamRequest.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 05/10/2022.
//

import Foundation

struct OSJoinTeamRequest: Codable {
    
    var teamId: String?
    
    var playerId: String?
    
    var password: String?
}
