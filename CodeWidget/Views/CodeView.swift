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
        VStack {
            Text(container.nickname)
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView(container: CodeContainer.current)
    }
}
