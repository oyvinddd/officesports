//
//  UserDefaultsHelper.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import Foundation

private let userDefaultsSharedSuiteName = "group.com.tietoevry.officesports"
private let userDefaultsPlayerKey = "player"
private let userDefaultsInviteTimestampKey = "inviteTimestamp"
private let userDefaultsDefaultScreenKey = "defaultScreen"
private let userDefaultsIsNotFirstRun = "isNotFirstRun"

struct UserDefaultsHelper {
    
    private static let standardDefaults = UserDefaults.standard
    private static let sharedDefaults = UserDefaults(suiteName: userDefaultsSharedSuiteName)!
    
    static func savePlayerProfile(_ player: OSPlayer) -> Bool {
        if let encodedPlayer = try? JSONEncoder().encode(player) {
            standardDefaults.set(encodedPlayer, forKey: userDefaultsPlayerKey)
            return true
        }
        return false
    }
    
    static func loadPlayerProfile() -> OSPlayer? {
        if let encodedPlayer = standardDefaults.object(forKey: userDefaultsPlayerKey) as? Data {
            let decodedPlayer = try? JSONDecoder().decode(OSPlayer.self, from: encodedPlayer)
            return decodedPlayer
        }
        return nil
    }
    
    static func saveInviteTimestamp(_ timestamp: Date) {
        standardDefaults.set(timestamp.timeIntervalSince1970, forKey: userDefaultsInviteTimestampKey)
    }
    
    static func loadInviteTimestamp() -> Date? {
        let timestampDouble = standardDefaults.double(forKey: userDefaultsInviteTimestampKey)
        return Date(timeIntervalSince1970: timestampDouble)
    }
    
    static func saveDefaultScreen(index: Int) {
        var validIndex = index
        if validIndex < 0 {
            validIndex = 0
        } else if validIndex > 2 {
            validIndex = 2
        }
        standardDefaults.set(validIndex, forKey: userDefaultsDefaultScreenKey)
    }
    
    static func loadDefaultScreen() -> Int {
        if let defaultScreenIndex = standardDefaults.value(forKey: userDefaultsDefaultScreenKey) as? Int {
            return defaultScreenIndex
        }
        return 1 // 1 = table tennis screen is the fallback
    }
    
    static func clearProfileDetails() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    static func checkAndUpdateIsFirstRun() -> Bool {
        if !standardDefaults.bool(forKey: userDefaultsIsNotFirstRun) {
            standardDefaults.set(true, forKey: userDefaultsIsNotFirstRun)
            return true
        }
        return false
    }
}
