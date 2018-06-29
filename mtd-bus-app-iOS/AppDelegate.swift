//
//  AppDelegate.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 6/19/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import Material

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        let appToolbarController = AppToolbarController(rootViewController: ViewController())
        let leftViewController = LeftViewController()

        
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = AppNavigationDrawerController(rootViewController: appToolbarController, leftViewController: leftViewController)
        window!.makeKeyAndVisible()
    }


}

