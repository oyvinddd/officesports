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
    
    var isBusy: Bool = false
    
    private let api: SportsAPI
    
    weak var delegate: ScannerViewModelDelegate?
    
    init(api: SportsAPI) {
        self.api = api
    }
    
    func registerMatch(_ registration: OSMatchRegistration) {
        delegate?.shouldToggleLoading(enabled: true)
        isBusy = true
        api.registerMatch(registration) { [unowned self] error in
            self.delegate?.shouldToggleLoading(enabled: false)
            guard let error = error else {
                self.delegate?.matchRegistrationSuccess()
                return
            }
            delegate?.matchRegistrationFailed(error: error)
            self.isBusy = false
        }
    }
}
