//
//  InvitesViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 19/05/2022.
//

import Foundation

protocol InvitesViewModelDelegate: AnyObject {
    
}

final class InvitesViewModel {
    
    weak var delegate: InvitesViewModelDelegate?
    
    private let api: SportsAPI
    
    init(api: SportsAPI) {
        self.api = api
    }
}
