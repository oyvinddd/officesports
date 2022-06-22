//
//  AppDelegate.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit
import FirebaseCore
import GoogleSignIn

@main class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureGlobalAppearance()
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        Coordinator.global.window = window
        Coordinator.global.checkAndHandleAppState()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Coordinator.global.checkAndHandleAppState()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    private func configureGlobalAppearance() {
    }
}
