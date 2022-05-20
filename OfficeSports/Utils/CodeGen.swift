//
//  CodeGenerator.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

struct CodeGen {
    
    private static let qrCodeFilterKey = "CIQRCodeGenerator"
    private static let qrCodeDataKey = "inputMessage"
    
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        return generateQRCode(from: data)
    }
    
    static func generateQRCode(from data: Data?) -> UIImage? {
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

extension CodeGen {
    
    static func generateQRCode(from payload: OSCodePayload) -> UIImage? {
        do {
            let json = try JSONEncoder().encode(payload)
            if let jsonString = String(data: json, encoding: .utf8) {
                return generateQRCode(from: jsonString)
            }
            return nil
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
