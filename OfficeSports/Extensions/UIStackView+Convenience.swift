//
//  UIStackView+Convenience.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 07/06/2022.
//

import UIKit

extension UIStackView {
    
    func addArrangedSubviews(_ subviews: UIView...) {
        for view in subviews {
            addArrangedSubview(view)
        }
    }
}
