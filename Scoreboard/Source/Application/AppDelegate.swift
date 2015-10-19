//
//  AppDelegate.swift
//  Scoreboard
//
//  Created by Charles Magahern on 9/26/15.
//  Copyright (c) 2015 zanneth. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = ScoreboardViewController(gameName: "Tempest")
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
