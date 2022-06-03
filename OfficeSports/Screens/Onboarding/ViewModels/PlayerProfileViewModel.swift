//
//  ProfileDetailsViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 16/05/2022.
//

import Foundation
import Combine

private let userDefaultsNicknameKey = "nickname"
private let userdefaultsEmojiKey = "emoji"

protocol PlayerProfileViewModelDelegate: AnyObject {
    
    func detailsUpdatedSuccessfully()
    
    func detailsUpdateFailed(with error: Error)
}

final class PlayerProfileViewModel {
    
    @Published var shouldToggleLoading: Bool = false
    
    let api: SportsAPI
    var emoijs = [String]()
    
    var randomEmoji: String {
        let randomIndex = Int.random(in: 0..<emoijs.count)
        return emoijs[randomIndex]
    }
    
    weak var delegate: PlayerProfileViewModelDelegate?
    
    init(api: SportsAPI, delegate: PlayerProfileViewModelDelegate? = nil) {
        self.api = api
        self.delegate = delegate
        do {
            self.emoijs = try loadEmojisFromFile(filename: "emojis")
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func registerProfileDetails(nickname: String, emoji: String) async {
        do {
            _ = try await api.createPlayerProfile(nickname: nickname, emoji: emoji)
        } catch let error {
            
        }
        /*
         shouldToggleLoading = true
         api.createPlayerProfile(nickname: nickname, emoji: emoji) { [unowned self] error in
         self.shouldToggleLoading = false
         if let error = error {
         self.delegate?.detailsUpdateFailed(with: error)
         } else {
         self.saveProfileDetails(nickname: nickname, emoji: emoji)
         self.delegate?.detailsUpdatedSuccessfully()
         }
         }
         */
    }
    
    private func saveProfileDetails(nickname: String, emoji: String) {
        // store profile details in user defaults
        let standardDefaults = UserDefaults.standard
        standardDefaults.set(nickname, forKey: userDefaultsNicknameKey)
        standardDefaults.set(emoji, forKey: userdefaultsEmojiKey)
        // update the profile details on the current account
        OSAccount.current.nickname = nickname
        OSAccount.current.emoji = emoji
    }
    
    private func loadEmojisFromFile(filename: String) throws -> [String] {
        if let filePath = Bundle.main.path(forResource: filename, ofType: "csv") {
            let contents = try String(contentsOfFile: filePath)
            return contents.components(separatedBy: ",")
        }
        print("CSV file containing emojis not found")
        return []
    }
}
