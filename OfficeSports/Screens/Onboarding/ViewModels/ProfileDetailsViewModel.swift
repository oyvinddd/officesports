//
//  ProfileDetailsViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 16/05/2022.
//

import Foundation

private let userDefaultsNicknameKey = "nickname"
private let userdefaultsEmojiKey = "emoji"

protocol ProfileDetailsViewModelDelegate: AnyObject {
    
    func detailsUpdatedSuccessfully()
    
    func detailsUpdateFailed(with error: Error)
    
    func shouldToggleLoading(enabled: Bool)
}

final class ProfileDetailsViewModel {
    
    var api: SportsAPI
    
    weak var delegate: ProfileDetailsViewModelDelegate?
    
    init(api: SportsAPI, delegate: ProfileDetailsViewModelDelegate? = nil) {
        self.api = api
        self.delegate = delegate
    }
    
    func updateProfileDetails(nickname: String, emoji: String) {
        api.checkNicknameAvailability(nickname) { [unowned self] error in
            if let error = error {
                self.delegate?.detailsUpdateFailed(with: error)
            } else {
                self.saveProfileDetails(nickname: nickname, emoji: emoji)
                self.delegate?.detailsUpdatedSuccessfully()
            }
        }
    }
    
    private func saveProfileDetails(nickname: String, emoji: String) {
        let standardDefaults = UserDefaults.standard
        standardDefaults.set(nickname, forKey: userDefaultsNicknameKey)
        standardDefaults.set(emoji, forKey: userdefaultsEmojiKey)
    }
}
