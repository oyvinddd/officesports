//
//  QRCodeView.swift
//  CodeWidgetExtension
//
//  Created by Øyvind Hauge on 06/07/2022.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    
//    let color = UIColor.OS.Text.normal
//    let backgroundColor = UIColor.white
    
    var body: some View {
        Color(.sRGB, red: 106/255, green: 117/255, blue: 239/255, opacity: 1).ignoresSafeArea()
        ZStack {
            if let image = genrateQRImage() {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFill()
                    .padding()
//                    .padding(20)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8).stroke(.blue, lineWidth: 4)
//                    )
            } else {
                Text("✨").font(Font.system(size: 70))
            }
        }
    }
    
    private func genrateQRImage() -> UIImage? {
        let payload = UserDefaults.CodeWidget.loadCodePayload()
        let data = dataFromPayload(payload)
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue("H", forKey: "inputCorrectionLevel")
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        
        if let qrCodeImage = filter.outputImage?.transformed(by: transform) {
            if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                return UIImage(cgImage: qrCodeCGImage)
            }
        }
        return nil
    }
    
    private func dataFromPayload(_ payload: OSCodePayload?) -> Data? {
        guard let payload = payload else {
            print("invalid code payload")
            return nil
        }
        
        do {
            let json = try JSONEncoder().encode(payload)
            if let jsonString = String(data: json, encoding: .utf8) {
                return jsonString.data(using: String.Encoding.ascii)
            }
        } catch let error {
            print(error)
            return nil
        }
        return nil
    }
}

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView()
    }
}
