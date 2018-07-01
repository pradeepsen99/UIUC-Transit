//
//  AppNavigationController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/1/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import Material

class AppNavigationController: NavigationController {
    open override func prepare() {
        super.prepare()
        isMotionEnabled = true
        
        guard let v = navigationBar as? NavigationBar else {
            return
        }
        
        v.backgroundColor = .white
        v.depthPreset = .none
        v.dividerColor = Color.grey.lighten2
    }
}
