//
//  KeyboardLayoutConstraint.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 24/05/2022.
//

import UIKit

/**
 * Let's see how long this class can live before iOS decides to break it.
 * Handling the UI on keyboard show/hide shouldn't be this cumbersome in the first place =/.
 */
final class KeyboardLayoutConstraint: NSLayoutConstraint {
    
    private var offset: CGFloat = 0
    private var keyboardVisibleHeight: CGFloat = 0
    private var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
    
    override init() {
        super.init()
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupKeyboardObservers() {
        let kbShowSelector = #selector(KeyboardLayoutConstraint.keyboardWillShowNotification)
        let kbHideSelector = #selector(KeyboardLayoutConstraint.keyboardWillHideNotification)
        
        NotificationCenter.default.addObserver(self,
                                               selector: kbShowSelector,
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: kbHideSelector,
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.cgRectValue
                keyboardVisibleHeight = frame.size.height
            }
            
            constant = offset - keyboardVisibleHeight
            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                    userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):
                
                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: UIView.AnimationOptions(rawValue: curve.uintValue),
                    animations: {
                        self.keyWindow?.layoutIfNeeded()
                        return
                    }, completion: nil)
            default:
                
                break
            }
            
        }
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        keyboardVisibleHeight = 0
        constant = offset - keyboardVisibleHeight
        
        if let userInfo = notification.userInfo {
            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                    userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):
                
                let options = UIView.AnimationOptions(rawValue: curve.uintValue)
                
                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        self.keyWindow?.layoutIfNeeded()
                        return
                    }, completion: nil)
            default:
                break
            }
        }
    }
}
