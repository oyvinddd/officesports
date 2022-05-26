//
//  PassthroughStackView.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 27/05/2022.
//

import UIKit

final class PassthroughStackView: UIStackView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        print("passthrough stack view")
        return true
    }
}
