//
//  RootViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 6/29/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import Material

class RootViewController: UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.grey.lighten5
        
        prepareToolbar()
    }
}

extension RootViewController {
    fileprivate func prepareToolbar() {
        guard let tc = toolbarController else {
            return
        }
        
        tc.toolbar.title = "Material"
        tc.toolbar.detail = "Build Beautiful Software"
    }
}
