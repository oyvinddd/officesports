//
//  MockAuthAPI.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 09/06/2022.
//

import UIKit

final class MockAuthAPI: AuthAPI {
    
    private var signedIn = false
    
    func signIn(_ viewController: UIViewController, result: @escaping ((Error?) -> Void)) {
        signedIn = true
        result(nil)
    }
    
    func signOut() -> Error? {
        signedIn = false
        return nil
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
}
