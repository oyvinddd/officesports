//
//  CodeContainer.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 23/06/2022.
//

import UIKit

struct CodeContainer {
    
    static let current = CodeContainer()
    
    var qrCodeImage: UIImage? = QRCodeGenerator.loadCodePayloadAndGenerateImage() {
        didSet {
            print(qrCodeImage ?? "Image not loaded from UD!")
        }
    }
}
