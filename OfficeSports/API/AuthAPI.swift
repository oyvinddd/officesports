//
//  AuthAPI.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 09/06/2022.
//

import UIKit

protocol AuthAPI {
    
    @available(*, renamed: "signIn(viewController:)")
    func signIn(_ viewController: UIViewController, result: @escaping (Result<Bool, Error>) -> Void)
    
    func signOut() -> Error?
    
    func deleteAccount(result: @escaping ((Error?) -> Void))
    
    func signIn(viewController: UIViewController) async throws -> Bool
}
