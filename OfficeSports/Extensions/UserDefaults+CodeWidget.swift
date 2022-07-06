//
//  UserDefaults+CodeWidget.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 24/06/2022.
//

import Foundation

private let userDefaultsSharedGroupId = "group.com.tietoevry.officesports"
private let userDefaultsCodePayloadKey = "codePayload"

extension UserDefaults {
    
    struct CodeWidget {
        
        static func saveCodePayloadDetails(_ nickname: String, _ userId: String?) -> Bool {
            guard let userId = userId else {
                return false
            }
            let payload = OSCodePayload(userId: userId, nickname: nickname, sport: .tableTennis)
            guard let sharedDefaults = UserDefaults(suiteName: userDefaultsSharedGroupId),
                  let encodedPayload = try? JSONEncoder().encode(payload) else {
                return false
            }
            sharedDefaults.set(encodedPayload, forKey: userDefaultsCodePayloadKey)
            return true
        }
        
        static func loadCodePayload() -> OSCodePayload? {
            let sharedDefaults = UserDefaults(suiteName: userDefaultsSharedGroupId)
            guard let data = sharedDefaults?.value(forKey: userDefaultsCodePayloadKey) as? Data else {
                return nil
            }
            return try? JSONDecoder().decode(OSCodePayload.self, from: data)
        }
    }
}
