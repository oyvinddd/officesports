//
//  Coordinator.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 11/05/2022.
//

import UIKit

enum AppState: Int, RawRepresentable {
    case authorized, unauthorized, missingNickname
}

class Coordinator {
    
    static let global = Coordinator()
    
    var window: UIWindow?
    
    var currentState: AppState = .missingNickname
    
    init() {}
    
    func changeState(_ state: AppState) {
        guard state != currentState else {
            return
        }
        
    }
}
