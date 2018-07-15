//
//  FavoritesViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/4/18.
//
//  Copyright (c) 2018, Pradeep Senthil
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name of the copyright holder nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


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
        
        //Title of the Tab
        self.navigationController?.navigationBar.topItem?.title = "Favorites"
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)

        
        displayTable()
        
    }
    
    /// Displays the table based on pre determined values. The table will fit in the middle of the screen, making sure to be under the tab bar and the navigation controller. Can change the values inside the function to make the table bigger or smaller, change color, etc.
    func displayTable(){
        print("displaying Table")
        
        let defaults = UserDefaults.standard
        
        let arrayofStopsNameDatabase = defaults.stringArray(forKey: "favStopsName") ?? [String]()
        let arrayofStopsCodeDatabase = defaults.stringArray(forKey: "favStopsCode") ?? [String]()
        
        
        stopNameArr = arrayofStopsNameDatabase as NSArray
        stopIDArr = arrayofStopsCodeDatabase as NSArray
        
        print("StopID: " + stopIDArr.count.description)
        print("StopArr: " + stopNameArr.count.description)
        
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
    
    @objc func loadList(){
        //load data here
        
        let defaults = UserDefaults.standard

        
        let arrayofStopsNameDatabase = defaults.stringArray(forKey: "favStopsName") ?? [String]()
        let arrayofStopsCodeDatabase = defaults.stringArray(forKey: "favStopsCode") ?? [String]()
        
        
        stopNameArr = arrayofStopsNameDatabase as NSArray
        stopIDArr = arrayofStopsCodeDatabase as NSArray
        
        print("reloading Data")
        self.stopTableView.reloadData()
    }
    
}

extension FavoritesViewController{
    func stopBusView(){
        navigationController?.pushViewController(RoutesViewController(stop: currentStop, code: currentStopCode), animated: true)
    }
}
