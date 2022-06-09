//
//  ProfileDetailsViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 16/05/2022.
//

import Foundation
import Combine

private let nicknameMinLength = 3
private let nicknameMaxLength = 20

private let userDefaultsNicknameKey = "nickname"
private let userdefaultsEmojiKey = "emoji"

final class PlayerProfileViewModel {
    
    enum State {
        case idle
        case loading
        case success(OSPlayer)
        case failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    private let api: SportsAPI
    private(set) var emoijs = [String]()
    
    var randomEmoji: String {
        let randomIndex = Int.random(in: 0..<emoijs.count)
        return emoijs[randomIndex]
    }
    
    init(api: SportsAPI) {
        self.api = api
        do {
            self.emoijs = try loadEmojisFromFile(filename: "emojis")
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func processAndValidateNickname(_ nickname: String?) throws -> String {
        guard let nickname = nickname else {
            throw OSError.nicknameMissing
        }
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedNickname = trimmedNickname.lowercased()
        
        if lowercasedNickname.rangeOfCharacter(from: .whitespacesAndNewlines) != nil {
            throw OSError.invalidNickname
        }
        if lowercasedNickname.count < nicknameMinLength {
            throw OSError.nicknameTooShort
        }
        if lowercasedNickname.count > nicknameMaxLength {
            throw OSError.nicknameTooLong
        }
        return lowercasedNickname
    }
    
    func registerProfileDetails(nickname: String, emoji: String) {
        state = .loading
        
        Task {
            do {
                let player = try await api.createOrUpdatePlayerProfile(nickname: nickname, emoji: emoji)
                saveProfileDetails(nickname: nickname, emoji: emoji)
                state = .success(player)
            } catch let error {
                state = .failure(error)
            }
        }
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
