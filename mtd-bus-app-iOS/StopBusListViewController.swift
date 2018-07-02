//
//  StopBusListViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/2/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit

class StopBusListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return -1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        return cell
    }
    

    override func viewDidLoad() {
        view.backgroundColor = UIColor.darkGray
        print("Worked")
    }
}

extension StopBusListViewController{
    
}
