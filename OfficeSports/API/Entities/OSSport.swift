//
//  OSSport.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

enum OSSport: Int, Codable {
    
    case unknown = -1
    
    case foosball = 0
    
    case tableTennis = 1
    
    var humanReadableName: String {
        switch self {
        case .foosball:
            return "foosball"
        case .tableTennis:
            return "table tennis"
        case .unknown:
            return "unknown sport"
        }
    }
    
    var description: String {
        return humanReadableName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)
        self = OSSport.getSportType(rawValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    static func getSportType(_ number: Int) -> OSSport {
        switch number {
        case 0:
            return .foosball
        case 1:
            return .tableTennis
        default:
            return .unknown
        }
    }
}
