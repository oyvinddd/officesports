//
//  OSStats.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 24/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct OSStats: Codable {
    
    
    
    //@DocumentID public var id: String?
    
    var sport: OSSport
    
    var score: Int
    
    var matchesPlayed: Int
    
    var seasonWins: Int
    
//    init(from decoder: Decoder) throws {
//
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(sport, forKey: .sport)
//        try container.encode(score, forKey: .score)
//        try container.encode(matchesPlayed, forKey: .matchesPlayed)
//        try container.encode(seasonWins, forKey: .seasonWins)
//    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        sport = try container.decode(OSSport.self, forKey: .nickname)
//        score = try container.decode(Int.self, forKey: .emoji)
//        matchesPlayed = try? container.decode(Int.self, forKey: .matchesPlayed)
//        seasonWins = try? container.decode(Int.self, forKey: .seasonWins)
//    }
}
