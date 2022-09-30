//
//  FirebaseAuthAPI.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 30/09/2022.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

final class FirebaseAuthAPI: AuthAPI {
    
    func signInWithGoogle(from viewController: UIViewController, result: @escaping (Result<Bool, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { (user, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                result(.failure(OSError.missingToken))
                return
            }
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credentials) { (_, error) in
                if let error = error {
                    result(.failure(error))
                } else {
                    result(.success(true))
                }
            }
        }
    }
    
    // https://firebase.google.com/docs/auth/ios/apple?authuser=0&hl=en
    func signInWithApple(from viewController: UIViewController, result: @escaping ((Result<Bool, Error>) -> Void)) {
        /*
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
         */
    }
    
    func signOut() -> Error? {
        do {
            try Auth.auth().signOut()
        } catch let error {
            return error
        }
        return nil
    }
    
    func signInWithGoogle(from viewController: UIViewController) async throws -> Bool {
        return try await withCheckedThrowingContinuation({ continuation in
            signInWithGoogle(from: viewController) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func signInWithApple(from viewController: UIViewController) async throws -> Bool {
        return try await withCheckedThrowingContinuation({ continuation in
            signInWithApple(from: viewController) { result in
                continuation.resume(with: result)
            }
        })
    }
}
