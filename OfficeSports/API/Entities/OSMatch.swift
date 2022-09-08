//
//  OSMatch.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseFirestore

struct OSMatch: Codable {
    
    private static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d. MMMM, yyyy @ HH:mm"
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
    
    init(sport: OSSport, winner: OSPlayer, loser: OSPlayer, winnerDt: Int, loserDt: Int) {
        self.date = Date()
        self.sport = sport
        self.winner = winner
        self.loser = loser
        self.winnerDelta = winnerDt
        self.loserDelta = loserDt
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
