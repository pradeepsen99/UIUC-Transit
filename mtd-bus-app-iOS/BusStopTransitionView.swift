//
//  BusStopTransitionView.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/1/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import Material

class BusStopTransitionView: UIViewController {
    fileprivate var menuButton: IconButton!

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.green.base
        prepareMenuButton()
        prepareToolbar()
    }
}

extension BusStopTransitionView {
    fileprivate func prepareMenuButton() {
        menuButton = IconButton(image: Icon.cm.arrowBack)
        menuButton.addTarget(self, action: #selector(handleNextButton), for: .touchUpInside)
    }
    
    @objc
    func handleNextButton() {
        //navigationController?.pushViewController(BusStopTransitionView(), animated: true)
        toolbarController?.transition(to: ViewController())
    }
    
    fileprivate func prepareToolbar() {
        guard let tc = toolbarController else {
            return
        }

        tc.toolbar.title = "Stop: "
        tc.toolbar.detail = "___ Miles"
        
        tc.toolbar.leftViews = [menuButton]
    }
}
