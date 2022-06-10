//
//  InvitePlayerViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 25/05/2022.
//

import Foundation

final class InvitePlayerViewModel {
    
    enum State {
        
        case idle
        
        case loading
        
        case success(OSInvite)
        
        case failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func invitePlayer(_ player: OSPlayer, sport: OSSport) {
        state = .loading
        Task {
            do {
                let invite = try await api.invitePlayer(player, sport: sport)
                state = .success(invite)
            } catch let error {
                state = .failure(error)
            }
        }
    }
}
