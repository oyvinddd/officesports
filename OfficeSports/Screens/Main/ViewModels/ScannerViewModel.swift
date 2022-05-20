//
//  ScannerViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 20/05/2022.
//

import Foundation

protocol ScannerViewModelDelegate: AnyObject {
    
    func matchRegistrationSuccess()
    
    func matchRegistrationFailed(error: Error)
    
    func shouldToggleLoading(enabled: Bool)
}

final class ScannerViewModel {
    
    private let api: SportsAPI
    
    weak var delegate: ScannerViewModelDelegate?
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func registerMatch(_ match: OSMatch) {
        delegate?.shouldToggleLoading(enabled: true)
        api.registerMatch(match) { [unowned self] error in
            self.delegate?.shouldToggleLoading(enabled: false)
            guard let error = error else {
                self.delegate?.matchRegistrationSuccess()
                return
            }
            delegate?.matchRegistrationFailed(error: error)
        }
    }
}
