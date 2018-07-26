//
//  AppDelegate.swift
//  planner
//
//  Created by Daniil Subbotin on 30/06/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = #colorLiteral(red: 0.4588235294, green: 0.2509803922, blue: 0.9333333333, alpha: 1)
        return true
    }

}
