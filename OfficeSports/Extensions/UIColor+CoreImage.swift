//
//  UIColor+CoreImage.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import UIKit

extension UIColor {
    
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    
    // swiftlint:disable large_tuple
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = coreImageColor
        return (color.red, color.green, color.blue, color.alpha)
    }
}
