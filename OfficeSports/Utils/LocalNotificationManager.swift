//
//  LocalNotificationManager.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 30/05/2022.
//

import Foundation
import UserNotifications

final class LocalNotificationManager {
    
    class func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        var dateComponents = DateComponents()
        dateComponents.hour = 14
    }
}
