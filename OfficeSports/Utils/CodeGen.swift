//
//  CodeGen.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

struct CodeGen {
    
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        return generateQRCode(from: data)
    }
    
    static func generateQRCode(from data: Data?) -> UIImage? {
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let color = UIColor.OS.Text.normal.coreImageColor
                let backgroundColor = UIColor.white.coreImageColor
                if let coloredOutput = applyColors(image: output, color, backgroundColor) {
                    return UIImage(ciImage: coloredOutput)
                }
            }
        }
        return nil
    }
    
    static func generateQRCode(from payload: OSCodePayload) -> UIImage? {
        do {
            let json = try JSONEncoder().encode(payload)
            if let jsonString = String(data: json, encoding: .utf8) {
                return generateQRCode(from: jsonString)
            }
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        return nil
    }
    
    private static func applyColors(image: CIImage, _ color: CIColor, _ backgroundColor: CIColor) -> CIImage? {
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            return nil
        }
        colorFilter.setValue(image, forKey: kCIInputImageKey)
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        return colorFilter.outputImage
    }
}
