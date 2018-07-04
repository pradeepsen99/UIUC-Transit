//
//  StopBusListViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/2/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit

class StopBusListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentStop:String = ""
    
    init(stop: String) {
        self.currentStop = stop
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return -1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        return cell
    }
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.darkGray
        //navigationController?
        self.title = currentStop
        
        
    }
}

extension StopBusListViewController{
    
}
