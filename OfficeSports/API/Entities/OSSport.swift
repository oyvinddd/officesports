//
//  OSSport.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation

enum OSSport: Int, Codable {
    
    case foosball, tableTennis, unknown
    
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
