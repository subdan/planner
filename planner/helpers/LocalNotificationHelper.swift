//
//  LocalNotificationBuilder.swift
//  planner
//
//  Created by Daniil Subbotin on 08/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationHelper {
    
    static func cancel(_ uuid: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [uuid])
    }
    
    static func create(title: String,
                       body: String,
                       date: Date,
                       type: NotificationType,
                       handler: @escaping (_ uuid: String?)->Void) {
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            
            if settings.authorizationStatus == .denied {
                handler(nil)
            } else if settings.authorizationStatus == .notDetermined {
                requestAuthorization()
            } else if settings.authorizationStatus == .authorized {
                buildNotification()
            }
            
        }
        
        func requestAuthorization() {
            center.requestAuthorization(options: [.alert]) { (granted, error) in
                
                guard granted == true else {
                    handler(nil)
                    return
                }
                
                buildNotification()
            }
        }
        
        func buildNotification() {
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            
            let component: Calendar.Component = type.dateComponent()
            let value: Int = type.dateValue()
            let theDate = Calendar.current.date(byAdding: component, value: -value, to: date)!
            
            var triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: theDate)
            triggerDate.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                        repeats: false)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString,
                                                content: content,
                                                trigger: trigger)
            
            handler(uuidString)
            
            center.add(request) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
            }
        }
        
    }
    
}
