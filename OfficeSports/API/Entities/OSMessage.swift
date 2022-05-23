//
//  OSMessage.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 22/05/2022.
//

import Foundation

struct OSMessage {
    
    enum Category: Int {
        case success, failure, warning, info
    }
    
    let category: Category
    
    let text: String
    
    init(_ text: String, _ category: Category) {
        self.text = text
        self.category = category
    }
}
