//
//  OSInvite.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import Foundation

struct OSInvite: Codable {
    
    var date: Date
    
    var sport: OSSport
    
    var inviter: OSPlayer
    
    var invitee: OSPlayer
}
