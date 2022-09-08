//
//  InvitePlayerViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 25/05/2022.
//

import Foundation

final class PlayerDetailsViewModel {
    
    enum State {
        
        case idle
        
        case loading
        
        case success(OSInvite)
        
        case failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    @Published private(set) var latestMatches: [OSMatch] = []
    
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
    
    func fetchLatestMatches(sport: OSSport, player1Id: String, player2Id: String) {
        Task {
            do {
                let matches = try await api.getLatestMatches(sport: sport, winnerId: player1Id, loserId: player2Id)
                self.latestMatches = matches
            } catch let error {
                // we don't really care too much if this fails
                print(error)
            }
        }
    }
}
