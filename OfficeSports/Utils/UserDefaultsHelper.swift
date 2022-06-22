//
//  UserDefaultsHelper.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import Foundation

private let userDefaultsPlayerKey = "player"
private let userDefaultsInviteTimestampKey = "inviteTimestamp"
private let userDefaultsDefaultScreenKey = "defaultScreen"

struct UserDefaultsHelper {
    
    private static let defaults = UserDefaults.standard
    
    static func savePlayerProfile(_ player: OSPlayer) -> Bool {
        let encoder = JSONEncoder()
        if let encodedPlayer = try? encoder.encode(player) {
            defaults.set(encodedPlayer, forKey: userDefaultsPlayerKey)
            return true
        }
        return false
    }
    
    static func loadPlayerProfile() -> OSPlayer? {
        if let encodedPlayer = defaults.object(forKey: userDefaultsPlayerKey) as? Data {
            let decoder = JSONDecoder()
            let decodedPlayer = try? decoder.decode(OSPlayer.self, from: encodedPlayer)
            return decodedPlayer
        }
        return nil
    }
    
    static func saveInviteTimestamp(_ timestamp: Date) {
        defaults.set(timestamp.timeIntervalSince1970, forKey: userDefaultsInviteTimestampKey)
    }
    
    static func loadInviteTimestamp() -> Date? {
        let timestampDouble = defaults.double(forKey: userDefaultsInviteTimestampKey)
        return Date(timeIntervalSince1970: timestampDouble)
    }
    
    static func saveDefaultScreen(index: Int) {
        var validIndex = index
        if validIndex < 0 {
            validIndex = 0
        } else if validIndex > 2 {
            validIndex = 2
        }
        defaults.set(validIndex, forKey: userDefaultsDefaultScreenKey)
    }
    
    static func loadDefaultScreen() -> Int {
        if let defaultScreenIndex = defaults.value(forKey: userDefaultsDefaultScreenKey) as? Int {
            return defaultScreenIndex
        }
        return 1 // 1 = foosball screen is the fallback
    }
    
    static func clearProfileDetails() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
