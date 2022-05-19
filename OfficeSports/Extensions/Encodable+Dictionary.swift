//
//  Encodable+Dictionary.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import Foundation

extension Encodable {
    
    /// Returns a JSON dictionary, with choice of minimal information
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any]
        }
    }
}
