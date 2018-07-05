//
//  FavoritesViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/4/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate var stopNameArr: NSArray = []
    fileprivate var stopIDArr: NSArray = []
    fileprivate var stopTableView: UITableView!
    
    var currentStop: String = ""
    var currentStopCode: String = ""
    
    /// On click option for each table cell
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: Index of the selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentStop = stopNameArr[indexPath.item] as! String
        currentStopCode = stopIDArr[indexPath.item] as! String
        stopBusView()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// Returns number of rows in the specified table.
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: the selected section
    /// - Returns: The number of rows the the specified table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopNameArr.count
    }
    
    
    /// Gives the value and a unique identifier to each of the rows in the table.
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: Current Index of the row being added.
    /// - Returns: Completed UITableViewCell with values.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(stopNameArr[indexPath.row])"
        return cell
    }
    
    override func viewDidLoad() {
        
    }
        
}

extension FavoritesViewController{
    func stopBusView(){
        navigationController?.pushViewController(StopBusListViewController(stop: currentStop, code: currentStopCode), animated: true)
    }
}
