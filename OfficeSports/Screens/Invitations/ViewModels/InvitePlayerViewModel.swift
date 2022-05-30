//
//  InvitePlayerViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 25/05/2022.
//

import Foundation

protocol InvitePlayerViewModelDelegate: AnyObject {
    
    func invitePlayerSuccess()
    
    func invitePlayerFailed(with error: Error)
}

final class InvitePlayerViewModel {
    
    @Published var shouldShowLoading: Bool = false
    
    private let api: SportsAPI
    
    weak var delegate: InvitePlayerViewModelDelegate?
    
    init(api: SportsAPI, delegate: InvitePlayerViewModelDelegate? = nil) {
        self.api = api
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport) {
        shouldShowLoading = true
        api.invitePlayer(player, sport: sport) { [unowned self] error in
            shouldShowLoading = false
            guard let error = error else {
                self.delegate?.invitePlayerSuccess()
                return
            }
            self.delegate?.invitePlayerFailed(with: error)
        }
    }
}
