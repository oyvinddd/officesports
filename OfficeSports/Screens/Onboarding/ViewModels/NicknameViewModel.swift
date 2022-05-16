//
//  NicknameViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 16/05/2022.
//

import Foundation

protocol NicknameViewModelDelegate: AnyObject {
    
    func nicknameUpdatedSuccessfully()
    
    func nicknameUpdateFailed(with error: Error)
    
    func shouldToggleLoading(enabled: Bool)
}

final class NicknameViewModel {
    
    var api: SportsAPI
    
    weak var delegate: NicknameViewModelDelegate?
    
    init(api: SportsAPI, delegate: NicknameViewModelDelegate? = nil) {
        self.api = api
        self.delegate = delegate
    }
    
    func updateNickname(_ nickname: String) {
        
    }
}
