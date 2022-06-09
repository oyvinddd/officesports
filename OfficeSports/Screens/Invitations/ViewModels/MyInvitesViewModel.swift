//
//  MyInvitesViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import Foundation
import Combine

final class MyInvitesViewModel {
    
    @Published var showLoading: Bool = false
    @Published var invites: [OSInvite] = []
    
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func getActiveInvites() {
        self.showLoading = true
        Task {
            do {
                invites = try await api.getActiveInvites()
            } catch let error {
                print(error)
            }
        }
    }
}
