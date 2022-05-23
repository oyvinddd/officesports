//
//  UIButton+Loading.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import UIKit

extension UIButton {
    
    var activityIndicatorTag: Int {
        return 8080
    }
    
    func toggleLoading(_ enabled: Bool) {
        isEnabled = !enabled
        if enabled {
            addActivityIndicator()
        } else {
            removeActivityIndicator()
        }
    }
    
    func addActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = titleColor(for: .normal)
        activityIndicator.tag = activityIndicatorTag
        activityIndicator.hidesWhenStopped = true
        let width = bounds.size.width
        let height = bounds.size.height
        activityIndicator.center = CGPoint(x: width / 2, y: height / 2)
        addSubview(activityIndicator)
        titleLabel?.alpha = 0
        activityIndicator.startAnimating()
    }
    
    func removeActivityIndicator() {
        if let indicator = viewWithTag(activityIndicatorTag) as? UIActivityIndicatorView {
            titleLabel?.alpha = 1
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}
