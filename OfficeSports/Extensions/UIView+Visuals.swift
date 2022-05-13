//
//  UIView+Visuals.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

extension UIView {
    
    func applyGradient(_ colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        let cgColors = colors.map { $0.cgColor }
        gradientLayer.colors = cgColors
        gradientLayer.frame = frame
        gradientLayer.locations = [0.2, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.3, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func applySmallDropShadow(_ color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.masksToBounds = false
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.4
        layer.shadowOffset = .zero
    }
    
    func applyMediumDropShadow(_ color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.masksToBounds = false
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = .zero
    }
    
    func applyCornerRadius(_ cornerRadius: CGFloat = 6) {
        layer.masksToBounds = false
        layer.cornerRadius = cornerRadius
    }
}
