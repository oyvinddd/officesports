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
            
            static let mainDark = UIColor(hex: 0x4C56C8)
            
            static let separator = UIColor(hex: 0xF1F0F2)
        }
        
        enum Text {
            static let normal = UIColor(hex: 0x545A66)
            
            static let subtitle = UIColor(hex: 0xC7C7C9)
            
            static let disabled = UIColor(hex: 0x9FA1A4)
        }
        
        enum Sport {
            static let foosball = UIColor(hex: 0xEB9F6C)
            
            static let tableTennis = UIColor(hex: 0x6CBEA8)
        }
        
        enum Status {
            static let failure = UIColor(hex: 0xEA4755)
            
            static let success = UIColor(hex: 0x65C775)
            
            static let warning = UIColor(hex: 0xF4BB52)
            
            static let info = UIColor(hex: 0x000000)
        }
        
        enum Button {
            static let primary = UIColor(hex: 0xFFFFFF)
            
            static let primaryForeground = UIColor.OS.General.main
            
            static let primaryInverted = UIColor(hex: 0xFFFFFF)
            
            static let primaryInvertedForeground = UIColor(hex: 0x000000)
            
            static let secondary = UIColor(hex: 0xFFFFFF)
            
            static let secondaryInverted = UIColor(hex: 0xFFFFFF)
        }
        
        enum Profile {
            static let color1 = UIColor(hex: 0x6CBEA8)
            
            static let color2 = UIColor(hex: 0x98C39A)
            
            static let color3 = UIColor(hex: 0x98AA8F)
            
            static let color4 = UIColor(hex: 0x969E8F)
            
            static let color5 = UIColor(hex: 0x7D9FB9)
            
            static let color6 = UIColor(hex: 0xBEC88B)
            
            static let color7 = UIColor(hex: 0xEACC7C)
            
            static let color8 = UIColor(hex: 0xEAB471)
            
            static let color9 = UIColor(hex: 0xE8A772)
            
            static let color10 = UIColor(hex: 0xCEA89A)
            
            static let color11 = UIColor(hex: 0xBF9A7A)
            
            static let color12 = UIColor(hex: 0xEB9F6C)
            
            static let color13 = UIColor(hex: 0xED8561)
            
            static let color14 = UIColor(hex: 0xEA7960)
            
            static let color15 = UIColor(hex: 0xCF7A89)
            
            static let color16 = UIColor(hex: 0xB98277)
            
            static let color17 = UIColor(hex: 0xE68669)
            
            static let color18 = UIColor(hex: 0xE76E5F)
            
            static let color19 = UIColor(hex: 0xE3615D)
            
            static let color20 = UIColor(hex: 0xC86286)
            
            static let color21 = UIColor(hex: 0x8A84C5)
            
            static let color22 = UIColor(hex: 0xB689B6)
            
            static let color23 = UIColor(hex: 0xB870AD)
            
            static let color24 = UIColor(hex: 0xB563AB)
            
            static let color25 = UIColor(hex: 0x9A65D5)
        }
        
        static var profileColors: [UIColor] {
            return [
                UIColor.OS.Profile.color1, UIColor.OS.Profile.color2, UIColor.OS.Profile.color3,
                UIColor.OS.Profile.color4, UIColor.OS.Profile.color5, UIColor.OS.Profile.color6,
                UIColor.OS.Profile.color7, UIColor.OS.Profile.color8, UIColor.OS.Profile.color9,
                UIColor.OS.Profile.color10, UIColor.OS.Profile.color11, UIColor.OS.Profile.color12,
                UIColor.OS.Profile.color13, UIColor.OS.Profile.color14, UIColor.OS.Profile.color15,
                UIColor.OS.Profile.color16, UIColor.OS.Profile.color17, UIColor.OS.Profile.color18,
                UIColor.OS.Profile.color19, UIColor.OS.Profile.color20, UIColor.OS.Profile.color21,
                UIColor.OS.Profile.color22, UIColor.OS.Profile.color23, UIColor.OS.Profile.color24,
                UIColor.OS.Profile.color25
            ]
        }
        
        static func hashedProfileColor(_ input: String) -> UIColor {
            let hashedIndex = input.count << 5 % profileColors.count
            return profileColors[abs(hashedIndex)]
        }
    }
}
