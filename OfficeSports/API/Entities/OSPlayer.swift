//
//  OSPlayer.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct OSPlayer: Identifiable, Codable {
    
    @DocumentID public var id: String?
    
    var nickname: String
    
    var emoji: String
    
    var foosballStats: OSStats
    
    var tableTennisStats: OSStats
    
    func statsForSport(_ sport: OSSport) -> OSStats {
        sport == .foosball ? foosballStats : tableTennisStats
    }
    
    func scoreForSport(_ sport: OSSport) -> Int {
        return statsForSport(sport).score
    }
}
