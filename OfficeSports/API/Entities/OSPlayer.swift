//
//  OSPlayer.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct OSPlayer: Identifiable, Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case id, userId, nickname, emoji, foosballStats, tableTennisStats, poolStats, team
    }
    
    @DocumentID public var id: String?
    
    var nickname: String
    
    var emoji: String
    
    var team: OSTeam

    var foosballStats: OSStats?
    
    var tableTennisStats: OSStats?
    
    var poolStats: OSStats?
    
    var team: OSTeam?
    
    init(id: String? = nil, nickname: String, emoji: String, team: OSTeam? = nil, foosballStats: OSStats? = nil, tableTennisStats: OSStats? = nil, poolStats: OSStats? = nil) {
        self.id = id
        self.nickname = nickname
        self.emoji = emoji
        self.team = team
        self.foosballStats = foosballStats
        self.tableTennisStats = tableTennisStats
        self.poolStats = poolStats
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(nickname, forKey: .nickname)
            try container.encode(emoji, forKey: .emoji)
            try container.encode(foosballStats, forKey: .foosballStats)
            try container.encode(tableTennisStats, forKey: .tableTennisStats)
            try container.encode(poolStats, forKey: .poolStats)
            try container.encode(team, forKey: .team)
        } catch let error {
            print("Error encoding player: \(error)")
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .userId)
        nickname = try container.decode(String.self, forKey: .nickname)
        emoji = try container.decode(String.self, forKey: .emoji)
        foosballStats = try? container.decode(OSStats.self, forKey: .foosballStats)
        tableTennisStats = try? container.decode(OSStats.self, forKey: .tableTennisStats)
        poolStats = try? container.decode(OSStats.self, forKey: .poolStats)
        team = try? container.decode(OSTeam.self, forKey: .team)
    }
    
    func statsForSport(_ sport: OSSport) -> OSStats? {
        switch sport {
        case .foosball:
            return foosballStats
        case .tableTennis:
            return tableTennisStats
        case .pool:
            return poolStats
        default:
            return nil
        }
    }
    
    func scoreForSport(_ sport: OSSport) -> Int {
        return statsForSport(sport)?.score ?? 0
    }
    
    func noOfmatchesForSport(_ sport: OSSport) -> Int {
        guard let stats = statsForSport(sport) else {
            return 0
        }
        return stats.matchesPlayed
    }
    
    func noOfWinsForSport(_ sport: OSSport) -> Int {
        return statsForSport(sport)?.matchesWon ?? 0
    }
    
    func totalSeasonWins() -> Int {
        var totalWins = 0
        totalWins += (foosballStats?.seasonWins ?? 0)
        totalWins += (tableTennisStats?.seasonWins ?? 0)
        return totalWins
    }
    
    // MARK: - Equatable protocol conformance
    
    static func == (lhs: OSPlayer, rhs: OSPlayer) -> Bool {
        if let id1 = lhs.id, let id2 = rhs.id {
            return id1 == id2
        }
        return false
    }
}
