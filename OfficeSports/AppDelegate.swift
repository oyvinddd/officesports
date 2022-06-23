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
        FirebaseApp.configure()
        setRootViewControllerAndTakeAction(window: &window)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Coordinator.global.checkAndHandleAppState()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func setRootViewControllerAndTakeAction(window: inout UIWindow?) {
        window = UIWindow(frame: UIScreen.main.bounds)
        Coordinator.global.window = window
        Coordinator.global.checkAndHandleAppState()
    }
}
