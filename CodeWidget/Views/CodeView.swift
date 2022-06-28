//
//  CodeView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 23/06/2022.
//

import SwiftUI

struct CodeView: View {
    
    var container: CodeContainer
    
    var body: some View {
        ZStack {
            Color(.sRGB, red: 106/255, green: 117/255, blue: 239/255, opacity: 1).ignoresSafeArea()
            Image(uiImage: container.qrCodeImage ?? UIImage())
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView(container: CodeContainer.current)
    }
}
