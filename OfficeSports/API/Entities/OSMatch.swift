//
//  OSMatch.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseFirestore

struct OSMatch: Codable {
    
//    enum CodingKeys: String, CodingKey {
//        case sport, winner, loser, loserDelta, winnerDelta
//    }
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }
    
    var date: Date?
    
    var sport: OSSport
    
    var winner: OSPlayer
    
    var loser: OSPlayer
    
    var loserDelta: Int
    
    var winnerDelta: Int
    
    func dateToString() -> String {
        guard let date = date else {
            return ""
        }
        return OSMatch.dateFormatter.string(from: date)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try? container.decode(Date.self, forKey: .date)
        sport = try container.decode(OSSport.self, forKey: .sport)
        winner = try container.decode(OSPlayer.self, forKey: .winner)
        loser = try container.decode(OSPlayer.self, forKey: .loser)
        winnerDelta = try container.decode(Int.self, forKey: .winnerDelta)
        loserDelta = try container.decode(Int.self, forKey: .loserDelta)
    }
}
