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
    fileprivate var transitionButton1: FlatButton!
    fileprivate var transitionButton2: FlatButton!

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.blue.darken1
        
        prepareTransitionButton1()
        prepareTransitionButton2()
    }
}

extension LeftViewController {
    fileprivate func prepareTransitionButton1() {
        transitionButton1 = FlatButton(title: "Near Me", titleColor: .white)
        transitionButton1.pulseColor = .white
        transitionButton1.addTarget(self, action: #selector(handleTransitionButtonNearMe), for: .touchUpInside)
        view.layout(transitionButton1).horizontally().center()
        view.layout(transitionButton1).vertically(top: -400).center()
    }
    
    
    fileprivate func prepareTransitionButton2() {
        transitionButton2 = FlatButton(title: "Favorites", titleColor: .white)
        transitionButton2.pulseColor = .white
        transitionButton2.addTarget(self, action: #selector(handleTransitionButtonFavorites), for: .touchUpInside)
        view.layout(transitionButton2).horizontally().center()
        view.layout(transitionButton2).vertically(top: 400).center()
    }
}

extension LeftViewController {
    @objc
    fileprivate func handleTransitionButtonNearMe() {
        toolbarController?.transition(to: ViewController(), completion: closeNavigationDrawer)
    }
    
    @objc
    fileprivate func handleTransitionButtonFavorites() {
        toolbarController?.transition(to: TransitionedViewController(), completion: closeNavigationDrawer)
    }
    
    fileprivate func closeNavigationDrawer(result: Bool) {
        navigationDrawerController?.closeLeftView()
    }
}
