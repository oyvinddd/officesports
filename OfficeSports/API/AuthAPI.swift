//
//  AuthAPI.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 30/09/2022.
//

import UIKit

protocol AuthAPI {
    
    @available(*, renamed: "signInWithGoogle(viewController:)")
    func signInWithGoogle(from viewController: UIViewController, result: @escaping ((Result<Bool, Error>) -> Void))
    
    @available(*, renamed: "signInWithApple(viewController:)")
    func signInWithApple(from viewController: UIViewController, result: @escaping ((Result<Bool, Error>) -> Void))
    
    func signOut() -> Error?
    
    // MARK: - Async/await API
    
    func signInWithGoogle(from viewController: UIViewController) async throws -> Bool
    
    func signInWithApple(from viewController: UIViewController) async throws -> Bool
}
