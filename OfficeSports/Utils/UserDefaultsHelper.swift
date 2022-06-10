//
//  UserDefaultsHelper.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import Foundation

private let userDefaultsPlayerKey = "player"

struct UserDefaultsHelper {
    
    static func savePlayerProfile(_ player: OSPlayer) -> Bool {
        let encoder = JSONEncoder()
        let defaults = UserDefaults.standard
        
        if let encodedPlayer = try? encoder.encode(player) {
            defaults.set(encodedPlayer, forKey: userDefaultsPlayerKey)
            return true
        }
        return false
    }
    
    static func loadPlayerProfile() -> OSPlayer? {
        let defaults = UserDefaults.standard
        if let encodedPlayer = defaults.object(forKey: userDefaultsPlayerKey) as? Data {
            let decoder = JSONDecoder()
            let decodedPlayer = try? decoder.decode(OSPlayer.self, from: encodedPlayer)
            return decodedPlayer
        }
        return nil
    }
    
    static func clearProfileDetails() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
