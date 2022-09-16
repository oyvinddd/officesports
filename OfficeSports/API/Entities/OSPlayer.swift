//
//  OSPlayer.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

private let defaultPoints: Int = 1200

struct OSPlayer: Identifiable, Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case id, userId, nickname, emoji, teamId, foosballStats, tableTennisStats, poolStats, team, lastActive
    }
    
    @DocumentID public var id: String?
    
    var teamId: String?
    
    var nickname: String
    
    var emoji: String

    var foosballStats: OSStats?
    
    var tableTennisStats: OSStats?
    
    var poolStats: OSStats?
    
    var team: OSTeam?
    
    var lastActive: Date?
    
    var wasRecentlyActive: Bool {
        let calendar = Calendar.current
        let now = Date.now
        
        guard let date = lastActive else {
            return false
        }
        guard let twoHoursAgo = calendar.date(byAdding: .hour, value: -2, to: now) else {
            return false
        }
        return (twoHoursAgo...now).contains(date)
    }
    
    init(id: String? = nil, nickname: String, emoji: String, team: OSTeam, foosballStats: OSStats? = nil, tableTennisStats: OSStats? = nil, poolStats: OSStats? = nil, lastActive: Date? = nil) {
        self.id = id
        self.nickname = nickname
        self.emoji = emoji
        self.foosballStats = foosballStats
        self.tableTennisStats = tableTennisStats
        self.poolStats = poolStats
        self.team = team
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
            try? container.encode(teamId, forKey: .teamId)
            try? container.encode(lastActive, forKey: .lastActive)
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
        teamId = try? container.decodeIfPresent(String.self, forKey: .teamId)
        lastActive = try? container.decodeIfPresent(Date.self, forKey: .lastActive)
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
    
    func pointsForSport(_ sport: OSSport) -> Int {
        return statsForSport(sport)?.score ?? defaultPoints
    }
    
    func noOfmatchesForSport(_ sport: OSSport) -> Int {
        return statsForSport(sport)?.matchesPlayed ?? 0
    }
    
    func noOfWinsForSport(_ sport: OSSport) -> Int {
        return statsForSport(sport)?.matchesWon ?? 0
    }
    
    func totalSeasonWinsForSport(_ sport: OSSport) -> Int {
        return statsForSport(sport)?.seasonWins ?? 0
    }
    
    func rankForSport(_ sport: OSSport) -> OSRank {
        if let stats = statsForSport(sport) {
            return OSRank.rankFromElo(stats.score)
        }
        return .unranked
    }
    
    // MARK: - Equatable protocol conformance
    
    static func == (lhs: OSPlayer, rhs: OSPlayer) -> Bool {
        if let id1 = lhs.id, let id2 = rhs.id {
            return id1 == id2
        }
        return false
    }
}
