//
//  OSRank.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 16/09/2022.
//

import Foundation

private let diamondLowerBound = 1400
private let platinumLowerBound = 1300
private let goldLowerBound = 1200
private let silverLowerBound = 1100
private let bronzeLowerBound = 1000
private let copperLowerBound = 900

enum OSRank: Int {
    case unranked, diamond, platinum, gold, silver, bronze, copper
    
    static func rankFromElo(_ elo: Int) -> OSRank {
        if elo >= diamondLowerBound {
            return .diamond
        }
        if elo >= platinumLowerBound {
            return .platinum
        }
        if elo >= goldLowerBound {
            return .gold
        }
        if elo >= silverLowerBound {
            return .silver
        }
        if elo >= bronzeLowerBound {
            return .bronze
        }
        return .copper
    }
}
