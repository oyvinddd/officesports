//
//  UILabel+Visuals.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 05/09/2022.
//

import Foundation
import UIKit

extension UILabel {
    
    func applyLargeDropShadow(_ backgroundColor: UIColor) {
        layer.shadowColor = backgroundColor.cgColor
        layer.shadowRadius = 25
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero
        layer.masksToBounds = false
    }
}
