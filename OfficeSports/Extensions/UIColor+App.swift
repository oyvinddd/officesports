//
//  UIColor+App.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import CommonCrypto

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
            
            static let primaryInverted = UIColor.OS.General.main
            
            static let primaryInvertedForeground = UIColor(hex: 0xFFFFFF)
            
            static let secondary = UIColor(hex: 0xFFFFFF)
            
            static let secondaryForeground = UIColor.OS.General.main
            
            static let secondaryInverted = UIColor.clear
            
            static let secondaryInvertedForeground = UIColor.OS.General.main
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
        
        static func colorForSport(_ sport: OSSport) -> UIColor {
            switch sport {
            case .foosball:
                return UIColor.OS.Sport.foosball
            case .tableTennis:
                return UIColor.OS.Sport.tableTennis
            case .unknown:
                return UIColor.black
            }
        }
        
        static func hashedProfileColor(_ input: String) -> UIColor {
            let csum = Checksum.hash(data: input.data(using: .utf8)!, using: .md5)
            
            let index = csum.index(csum.startIndex, offsetBy: 6)
            let mySubstring = csum.prefix(upTo: index)
            
            let hueHex = Int(mySubstring, radix: 16)!
            let max: Float = 16777216
            let hue = Float(hueHex)/max
            
            return UIColor(hue: CGFloat(hue), saturation: 0.5, brightness: 0.6, alpha: 1)
        }
    }
}

struct Checksum {
    private init() {}

    static func hash(data: Data, using algorithm: HashAlgorithm) -> String {
        /// Creates an array of unsigned 8 bit integers that contains zeros equal in amount to the digest length
        var digest = [UInt8](repeating: 0, count: algorithm.digestLength())

        /// Call corresponding digest calculation
        data.withUnsafeBytes {
            algorithm.digestCalculation(data: $0.baseAddress, len: UInt32(data.count), digestArray: &digest)
        }

        var hashString = ""
        /// Unpack each byte in the digest array and add them to the hashString
        for byte in digest {
            hashString += String(format: "%02x", UInt8(byte))
        }

        return hashString
    }

    /**
    * Hash using CommonCrypto
    * API exposed from CommonCrypto-60118.50.1:
    * https://opensource.apple.com/source/CommonCrypto/CommonCrypto-60118.50.1/include/CommonDigest.h.auto.html
    **/
    enum HashAlgorithm {
        case md5
        case sha256

        func digestLength() -> Int {
            switch self {
            case .md5:
                return Int(CC_MD5_DIGEST_LENGTH)
            case .sha256:
                return Int(CC_SHA256_DIGEST_LENGTH)
            }
        }

        /// CC_[HashAlgorithm] performs a digest calculation and places the result in the caller-supplied buffer for digest
        /// Calls the given closure with a pointer to the underlying unsafe bytes of the data's contiguous storage.
        func digestCalculation(data: UnsafeRawPointer!, len: UInt32, digestArray: UnsafeMutablePointer<UInt8>!) {
            switch self {
            case .md5:
                CC_MD5(data, len, digestArray)
            case .sha256:
                CC_SHA256(data, len, digestArray)
            }
        }
    }
}
