//
//  OSTeam.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 22/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct OSTeam: Identifiable, Codable {
    
    @DocumentID public var id: String?
    
    var orgId: String
    
    var name: String
}
