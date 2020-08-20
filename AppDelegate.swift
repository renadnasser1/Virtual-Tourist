//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 13/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        
        /// Set data controller to Notebooks List ViewController
        let mapViewController = navigationController.topViewController as! MapViewController
        
        mapViewController.dataController = dataController
        return true
        
    }
    
    
}

