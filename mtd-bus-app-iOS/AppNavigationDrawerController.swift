//
//  AppNavigationDrawerController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 6/29/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import Material

class AppNavigationDrawerController: NavigationDrawerController {
    open override func prepare() {
        super.prepare()
        
        delegate = self
        Application.statusBarStyle = .default
    }
}

extension AppNavigationDrawerController: NavigationDrawerControllerDelegate {
    
}
