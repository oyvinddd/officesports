//
//  MockAuthAPI.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 09/06/2022.
//

import UIKit

final class MockAuthAPI: AuthAPI {
    
    private var signedIn = false
    
    func signIn(_ viewController: UIViewController, result: @escaping (Result<Bool, Error>) -> Void) {
        signedIn = true
        result(.success(true))
    }
    
    func signOut() -> Error? {
        signedIn = false
        return nil
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        result(nil)
    }
}

// MARK: - Confirm to the async/await versions of the API methods

extension MockAuthAPI {
    
    func signIn(viewController: UIViewController) async throws -> Bool {
        return try await withCheckedThrowingContinuation({ continuation in
            signIn(viewController) { result in
                continuation.resume(with: result)
            }
        })
    }
}
