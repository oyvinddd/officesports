//
//  AuthViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@objc protocol AuthViewModelDelegate: AnyObject {
    
    @objc optional func signInFailed(with error: Error)
    
    @objc optional func signedInSuccessfully()
    
    @objc optional func signOutFailed(with error: Error)
    
    @objc optional func signedOutSuccessfully()
}

final class AuthViewModel {
    
    weak var delegate: AuthViewModelDelegate?
    
    func signIn(from viewController: UIViewController) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { [unowned self] user, error in
            if let error = error {
                delegate?.signInFailed?(with: error)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                return
            }
            
            let credentials = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: authentication.accessToken
            )
            
            Auth.auth().signIn(with: credentials) { [unowned self] authResult, error in
                if let error = error {
                    self.delegate?.signInFailed?(with: error)
                } else {
                    print(authResult ?? "")
                    delegate?.signedInSuccessfully?()
                }
            }
        }
    }
    
    private func proceedWithFirebaseAuth(credentials: AuthCredential) {
        Auth.auth().signIn(with: credentials) { authResult, error in
            /*
             if let error = error {
             let authError = error as NSError
             if isMFAEnabled, authError.code == AuthErrorCode.secondFactorRequired.rawValue {
             // The user is a multi-factor user. Second factor challenge is required.
             let resolver = authError
             .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
             var displayNameString = ""
             for tmpFactorInfo in resolver.hints {
             displayNameString += tmpFactorInfo.displayName ?? ""
             displayNameString += " "
             }
             self.showTextInputPrompt(
             withMessage: "Select factor to sign in\n\(displayNameString)",
             completionBlock: { userPressedOK, displayName in
             var selectedHint: PhoneMultiFactorInfo?
             for tmpFactorInfo in resolver.hints {
             if displayName == tmpFactorInfo.displayName {
             selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
             }
             }
             PhoneAuthProvider.provider()
             .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
             multiFactorSession: resolver
             .session) { verificationID, error in
             if error != nil {
             print(
             "Multi factor start sign in failed. Error: \(error.debugDescription)"
             )
             } else {
             self.showTextInputPrompt(
             withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
             completionBlock: { userPressedOK, verificationCode in
             let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
             .credential(withVerificationID: verificationID!,
             verificationCode: verificationCode!)
             let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
             .assertion(with: credential!)
             resolver.resolveSignIn(with: assertion!) { authResult, error in
             if error != nil {
             print(
             "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
             )
             } else {
             self.navigationController?.popViewController(animated: true)
             }
             }
             }
             )
             }
             }
             }
             )
             } else {
             self.showMessagePrompt(error.localizedDescription)
             return
             }
             // ...
             return
             }*/
            // User is signed in
            // ...
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            delegate?.signedOutSuccessfully?()
        } catch let error {
            delegate?.signOutFailed?(with: error)
        }
    }
}
