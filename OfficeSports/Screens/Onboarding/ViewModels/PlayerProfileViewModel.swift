//
//  ProfileDetailsViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 16/05/2022.
//

import Foundation

private let userDefaultsNicknameKey = "nickname"
private let userdefaultsEmojiKey = "emoji"

protocol PlayerProfileViewModelDelegate: AnyObject {
    
    func detailsUpdatedSuccessfully()
    
    func detailsUpdateFailed(with error: Error)
    
    func shouldToggleLoading(enabled: Bool)
}

final class PlayerProfileViewModel {
    
    var api: SportsAPI
    
    weak var delegate: PlayerProfileViewModelDelegate?
    
    init(api: SportsAPI, delegate: PlayerProfileViewModelDelegate? = nil) {
        self.api = api
        self.delegate = delegate
    }
    
    func registerProfileDetails(nickname: String, emoji: String) {
        delegate?.shouldToggleLoading(enabled: true)
        api.registerPlayerProfile(nickname: nickname, emoji: emoji) { [unowned self] error in
            self.delegate?.shouldToggleLoading(enabled: true)
            if let error = error {
                self.delegate?.detailsUpdateFailed(with: error)
            } else {
                self.saveProfileDetails(nickname: nickname, emoji: emoji)
                self.delegate?.detailsUpdatedSuccessfully()
            }
        }
    }
    
    private func saveProfileDetails(nickname: String, emoji: String) {
        // store profile details in user defaults
        let standardDefaults = UserDefaults.standard
        standardDefaults.set(nickname, forKey: userDefaultsNicknameKey)
        standardDefaults.set(emoji, forKey: userdefaultsEmojiKey)
        // add profile details to the current account
        OSAccount.current.nickname = nickname
        OSAccount.current.emoji = emoji
    }
}
