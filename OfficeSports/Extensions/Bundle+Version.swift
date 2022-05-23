//
//  Bundle+Version.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import Foundation

extension Bundle {
    
    var appVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var appBuildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
