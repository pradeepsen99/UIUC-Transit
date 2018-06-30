//
//  TransitionedViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 6/29/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import Material

class TransitionedViewController: UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.green.base
        
        prepareToolbar()
    }
}

extension TransitionedViewController {
    fileprivate func prepareToolbar() {
        guard let tc = toolbarController else {
            return
        }
        
        tc.toolbar.title = "Favorites"
        tc.toolbar.detail = ""
    }
}
