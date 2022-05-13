//
//  CodeGenerator.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

private let qrCodeFilterKey = "CIQRCodeGenerator"
private let qrCodeDataKey = "inputMessage"

struct CodeGen {
    
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: qrCodeFilterKey) {
            filter.setValue(data, forKey: qrCodeDataKey)
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
