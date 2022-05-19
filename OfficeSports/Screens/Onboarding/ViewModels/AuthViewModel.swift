//
//  AuthViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import UIKit

@objc protocol AuthViewModelDelegate: AnyObject {
    
    @objc optional func signInFailed(with error: Error)
    
    @objc optional func signedInSuccessfully()
    
    @objc optional func signOutFailed(with error: Error)
    
    @objc optional func signedOutSuccessfully()
    
    func shouldToggleLoading(enabled: Bool)
}

final class AuthViewModel {
    
    weak var delegate: AuthViewModelDelegate?
    
    private let api: SportsAPI
    
    init(api: SportsAPI, delegate: AuthViewModelDelegate?) {
        self.delegate = delegate
        self.api = api
    }
    
    func signIn(from viewController: UIViewController) {
        api.signIn(viewController) { [unowned self] error in
            guard let error = error else {
                delegate?.signedInSuccessfully?()
                return
            }
            delegate?.signInFailed?(with: error)
        }
    }
    
    func signOut() {
        if let error = api.signOut() {
            delegate?.signOutFailed?(with: error)
        } else {
            delegate?.signedOutSuccessfully?()
        }
    }
}
