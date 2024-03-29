//
//  OSTeam.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 22/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct OSTeam: Identifiable, Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    @DocumentID public var id: String?
    
    var name: String
    
    init(id: String?, name: String) {
        self.id = id
        self.name = name
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try? container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
        } catch let error {
            print("Error encoding team: \(error)")
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    // MARK: - Equatable protocol conformance
    
    static func == (lhs: OSTeam, rhs: OSTeam) -> Bool {
        guard let id1 = lhs.id, let id2 = rhs.id else {
            return lhs.id == nil && rhs.id == nil
        }
        return id1 == id2
    }
}
