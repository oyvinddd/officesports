//
//  SettingsViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 16/05/2022.
//

import Foundation

protocol SettingsViewModelDelegate: AnyObject {
    
}

final class SettingsViewModel {
    
    weak var delegate: SettingsViewModelDelegate?
    
    init(delegate: SettingsViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func signOut() {
        
    }
}
