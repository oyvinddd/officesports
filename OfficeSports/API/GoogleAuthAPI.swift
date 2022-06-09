//
//  GoogleAuthAPI.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 09/06/2022.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

final class GoogleAuthAPI: AuthAPI {
    
    func signIn(_ viewController: UIViewController, result: @escaping ((Error?) -> Void)) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { (user, error) in
            if let error = error {
                result(error)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                result(OSError.missingToken)
                return
            }
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credentials) { (_, error) in
                result(error)
            }
        }
    }
    
    func signOut() -> Error? {
        do {
            try Auth.auth().signOut()
        } catch let error {
            return error
        }
        return nil
    }
    
    func deleteAccount(result: @escaping ((Error?) -> Void)) {
        fatalError("Delete account endpoint has not been implementet yet!")
    }
}
