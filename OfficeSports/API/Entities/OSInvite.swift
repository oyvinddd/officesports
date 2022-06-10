//
//  OSInvite.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct OSInvite: Identifiable, Codable {
    
    @DocumentID public var id: String?
    
    var date: Date
    
    var sport: OSSport
    
    var inviterId: String
    
    var inviteeId: String
    
    var inviteeNickname: String
    
    var accepted: Bool = false
}
