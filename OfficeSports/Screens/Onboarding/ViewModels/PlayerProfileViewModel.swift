//
//  ProfileDetailsViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 16/05/2022.
//

import Foundation
import Combine

private let nicknameMinLength = 3
private let nicknameMaxLength = 22

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
                _ = UserDefaultsHelper.savePlayerProfile(player)
                OSAccount.current.player = player
                state = .success(player)
            } catch let error {
                state = .failure(error)
            }
        }
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
