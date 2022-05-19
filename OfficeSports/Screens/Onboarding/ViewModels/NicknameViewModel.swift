//
//  NicknameViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 16/05/2022.
//

import Foundation

protocol NicknameViewModelDelegate: AnyObject {
    
    func detailsUpdatedSuccessfully()
    
    func detailsUpdateFailed(with error: Error)
    
    func shouldToggleLoading(enabled: Bool)
}

final class NicknameViewModel {
    
    var api: SportsAPI
    
    weak var delegate: NicknameViewModelDelegate?
    
    init(api: SportsAPI, delegate: NicknameViewModelDelegate? = nil) {
        self.api = api
        self.delegate = delegate
    }
    
    func updateProfileDetails(nickname: String, emoji: String) {
        api.saveProfileDetails(nickname: nickname, emoji: emoji)
        delegate?.detailsUpdatedSuccessfully()
    }
}
