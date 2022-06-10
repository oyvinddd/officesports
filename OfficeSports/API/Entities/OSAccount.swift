//
//  OSAccount.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import Foundation
import FirebaseAuth

final class OSAccount {
    
    static let current = OSAccount()
    
    var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var signedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var hasValidProfileDetails: Bool {
        return player != nil
    }
    
    var nickname: String? {
        return player?.nickname
    }
    
    var emoji: String? {
        return player?.emoji
    }
    
    @Published var player: OSPlayer?
    
    init() {
        player = UserDefaultsHelper.loadPlayerProfile()
        printStatus()
    }
    
    func qrCodePayloadForSport(_ sport: OSSport) -> OSCodePayload? {
        guard let uid = userId else {
            print("Unable to get user ID since user is not logged in.")
            return nil
        }
        return OSCodePayload(userId: uid, sport: sport)
    }
    
    func printStatus() {
        let currentUser = Auth.auth().currentUser
        let signedIn = currentUser != nil
        let userId = currentUser?.uid ?? ""
        print(
            "🔐 Signed in: [\(signedIn)]\n" +
            "🎁 User ID: [\(userId)]\n" +
            "🧸 Nickname: [\(player?.nickname ?? "None")]\n" +
            "🙃 Emoji: [\(player?.emoji ?? "None")]"
        )
    }
}
