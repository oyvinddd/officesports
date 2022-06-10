//
//  MyInvitesViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import Foundation
import Combine

final class MyInvitesViewModel {
    
    enum State {
        case idle, loading, success, failure(Error)
    }
    
    @Published private(set) var state: State = .idle
    
    private(set) var invites = [OSInvite]()
    
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func getActiveInvites() {
        state = .loading
        Task {
            do {
                invites = try await api.getActiveInvites()
                state = .success
            } catch let error {
                state = .failure(error)
            }
        }
    }
}
