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
        api.getActiveInvites { [unowned self] (invites, error) in
            if let error = error {
                
            }
        }
    }
}
