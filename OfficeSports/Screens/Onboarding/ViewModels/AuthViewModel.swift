//
//  AuthViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import UIKit
import Combine

@objc protocol AuthViewModelDelegate: AnyObject {
    
    @objc optional func signInFailed(with error: Error)
    
    @objc optional func signedInSuccessfully()
    
    @objc optional func signOutFailed(with error: Error)
    
    @objc optional func signedOutSuccessfully()
    
    func shouldToggleLoading(enabled: Bool)
}

final class AuthViewModel {
    
    weak var delegate: AuthViewModelDelegate?
    
    private let api: AuthAPI
    
    init(api: AuthAPI, delegate: AuthViewModelDelegate?) {
        self.delegate = delegate
        self.api = api
    }
    
    func signIn(from viewController: UIViewController) {
        /*
        delegate?.shouldToggleLoading(enabled: true)
        api.signIn(viewController) { [unowned self] error in
            self.delegate?.shouldToggleLoading(enabled: false)
            guard let error = error else {
                delegate?.signedInSuccessfully?()
                return
            }
            delegate?.signInFailed?(with: error)
        }
        */
    }
    
    func signOut() {
        if let error = api.signOut() {
            delegate?.signOutFailed?(with: error)
        } else {
            delegate?.signedOutSuccessfully?()
        }
    }
}
