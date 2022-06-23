//
//  CodeContainer.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 23/06/2022.
//

import Foundation

struct CodeContainer {
    
    var nickname: String
    
    var userId: String? = UserDefaults.CodeWidget.loadCodePayload()?.userId
}

extension CodeContainer {
    
    static let current = CodeContainer(nickname: "0yv!nd")
}
