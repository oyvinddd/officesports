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
        delegate?.shouldToggleLoading(enabled: true)
        api.registerProfileDetails(OSProfileDetails(nickname: nickname, emoji: emoji)) { [weak self] error in
            self?.delegate?.shouldToggleLoading(enabled: false)
            if let error = error {
                self?.delegate?.detailsUpdateFailed(with: error)
            } else {
                self?.delegate?.detailsUpdatedSuccessfully()
            }
        }
    }
}
