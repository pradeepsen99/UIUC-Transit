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
        let defaults = UserDefaults.standard
        
        //Title of the Tab
        self.navigationController?.navigationBar.topItem?.title = "Favorites"

        let arrayofStopsNameDatabase = defaults.stringArray(forKey: "favStopsName") ?? [String]()
        let arrayofStopsCodeDatabase = defaults.stringArray(forKey: "favStopsCode") ?? [String]()
        
        stopNameArr = arrayofStopsNameDatabase as NSArray
        
        displayTable()
    }
    
    /// Displays the table based on pre determined values. The table will fit in the middle of the screen, making sure to be under the tab bar and the navigation controller. Can change the values inside the function to make the table bigger or smaller, change color, etc.
    func displayTable(){
        let barHeight: CGFloat = 0
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        self.stopTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        self.stopTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.stopTableView.dataSource = self
        self.stopTableView.delegate = self
        self.stopTableView.separatorStyle = .none
        view.addSubview(self.stopTableView)
    }
        
}

extension FavoritesViewController{
    func stopBusView(){
        navigationController?.pushViewController(StopBusListViewController(stop: currentStop, code: currentStopCode), animated: true)
    }
}
