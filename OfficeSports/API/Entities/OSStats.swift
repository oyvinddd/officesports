//
//  OSStats.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 24/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct OSStats: Identifiable, Codable {
    
    @DocumentID public var id: String?
    
    var sport: OSSport
    
    var score: Int
    
    var matchesPlayed: Int
    
    // TODO:
    //var totalWins: Int
}
