//
//  CodeGen.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit
import SwiftUI

struct CodeGen {
    
    static func generateQRCode(from data: Data?, color: UIColor, backgroundColor: UIColor) -> UIImage? {
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                if let coloredOutput = applyColors(image: output, color.ciColor, backgroundColor.ciColor) {
                    return UIImage(ciImage: coloredOutput)
                }
            }
        }
        return nil
    }
    
    static func generateQRCode(from payload: OSCodePayload, color: UIColor = .black, backgroundColor: UIColor = .white) -> UIImage? {
        do {
            let json = try JSONEncoder().encode(payload)
            if let jsonString = String(data: json, encoding: .utf8) {
                let data = jsonString.data(using: String.Encoding.ascii)
                return generateQRCode(from: data, color: color, backgroundColor: backgroundColor)
            }
        } catch let error {
            print(error)
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

// MARK: - Fetch QR code from the widget

extension CodeGen {
    
    static func loadCodePayloadAndGenerateImage() -> Image? {
        guard let payload = UserDefaults.CodeWidget.loadCodePayload() else {
            print("Unable to load code payload since it doesn't exist")
            return nil
        }
        guard let qrCodeImage = generateQRCode(from: payload) else {
            print("Unable to generate QR code from payload")
            return nil
        }
        return Image(uiImage: qrCodeImage)
    }
}
