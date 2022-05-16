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
            
            static let mainDark = UIColor(hex: 0x7071C1)
            
            static let separator = UIColor(hex: 0xF1F0F2)
        }
        
        enum Text {
            
            static let normal = UIColor(hex: 0x545A66) // 414755
            
            static let subtitle = UIColor(hex: 0xC7C7C9)
            
            static let disabled = UIColor(hex: 0x9FA1A4)
        }
        
        enum Profile {
            
            static let red = UIColor(hex: 0xD2574D)
            
            static let blue = UIColor(hex: 0x2E69B4)
        }
    }
}
