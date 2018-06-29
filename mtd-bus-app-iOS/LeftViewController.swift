//
//  LeftViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 6/29/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import Material

class LeftViewController: UIViewController {
    fileprivate var transitionButton: FlatButton!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.blue.base
        
        prepareTransitionButton()
    }
}

extension LeftViewController {
    fileprivate func prepareTransitionButton() {
        transitionButton = FlatButton(title: "Transition VC", titleColor: .white)
        transitionButton.pulseColor = .white
        transitionButton.addTarget(self, action: #selector(handleTransitionButton), for: .touchUpInside)
        
        view.layout(transitionButton).horizontally().center()
    }
}

extension LeftViewController {
    @objc
    fileprivate func handleTransitionButton() {
        toolbarController?.transition(to: TransitionedViewController(), completion: closeNavigationDrawer)
    }
    
    fileprivate func closeNavigationDrawer(result: Bool) {
        navigationDrawerController?.closeLeftView()
    }
}
