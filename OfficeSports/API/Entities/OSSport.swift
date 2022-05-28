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
}
