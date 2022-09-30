//
//  UIViewController+Sheet.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 29/09/2022.
//

import UIKit

extension UIViewController {
    
    func applySheetPresentation() {
        let sheet = sheetPresentationController
        sheet?.detents = [.medium()]
        sheet?.largestUndimmedDetentIdentifier = .none
        sheet?.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet?.prefersEdgeAttachedInCompactHeight = true
        sheet?.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        sheet?.prefersGrabberVisible = true
    }
}
