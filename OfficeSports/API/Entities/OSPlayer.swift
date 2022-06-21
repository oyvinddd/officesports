//
//  OSPlayer.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct OSPlayer: Identifiable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id, nickname, emoji, foosballStats, tableTennisStats
    }
    
    @DocumentID public var id: String?
    
    var nickname: String
    
    var emoji: String
    
    var foosballStats: OSStats?
    
    var tableTennisStats: OSStats?
    
    init(id: String? = nil, nickname: String, emoji: String, foosballStats: OSStats? = nil, tableTennisStats: OSStats? = nil) {
        self.id = id
        self.nickname = nickname
        self.emoji = emoji
        self.foosballStats = foosballStats
        self.tableTennisStats = tableTennisStats
    }
    
    func statsForSport(_ sport: OSSport) -> OSStats? {
        sport == .foosball ? foosballStats : tableTennisStats
    }
    
    func scoreForSport(_ sport: OSSport) -> Int? {
        return statsForSport(sport)?.score
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(foosballStats, forKey: .foosballStats)
        try container.encode(tableTennisStats, forKey: .tableTennisStats)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // id = try? container.decode(String.self, forKey: .id)
        nickname = try container.decode(String.self, forKey: .nickname)
        emoji = try container.decode(String.self, forKey: .emoji)
        foosballStats = try? container.decode(OSStats.self, forKey: .foosballStats)
        tableTennisStats = try? container.decode(OSStats.self, forKey: .tableTennisStats)
    }
}
