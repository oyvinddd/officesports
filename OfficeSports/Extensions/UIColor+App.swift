//
//  UIColor+App.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

// swiftlint:disable type_name nesting
extension UIColor {
    
    enum OS {
        
        enum General {
            static let background = UIColor(hex: 0xE4E6EB)
            static let main = UIColor(hex: 0x656FED)
        }
        
        enum Text {
            
            static let normal = UIColor(hex: 0x414755)
            
            static let disabled = UIColor(hex: 0x9FA1A4)
        }
    }
}
