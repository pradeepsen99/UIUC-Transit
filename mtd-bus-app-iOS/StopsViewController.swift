//
//  StopsViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/3/18.
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
import Foundation


class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    
    var currentStop: String = ""
    var currentStopCode: String = ""
    
    fileprivate var stopNameArr: NSArray = []
    fileprivate var stopIDArr: NSArray = []
    
    fileprivate var stopNameArrFiltered: NSArray = []
    fileprivate var stopIDArrFiltered: NSArray = []
    
    fileprivate var isSearching: Bool = false
    
    fileprivate var stopTableView: UITableView!
    
    var resultSearchController = UISearchController()
    
    var mtdData: mtd_stop_loc? = nil
    
    //This function runs then the application comes into view. It runs convertJSONtoArr(), displayTable() and displaySearchBar() functions.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gray
        
        self.definesPresentationContext = true
        
        self.navigationController?.navigationBar.topItem?.title = "Stops"
        

        
        convertJSONtoArr()
        displayTable()
        displaySearchBar()
        
    }
    
    //This function checks to see if the iOS version is 11+. If it is then it adds a custom searchbar below the title of the viewController. In the event that the devide doesn't have ios11+ then
    func displaySearchBar(){
        //Checking if iOS Version is 11+ then can use navigationItem.searchController

        if #available(iOS 11.0, *) {
            let sc = UISearchController(searchResultsController: nil)
            sc.searchBar.delegate = self
            sc.dimsBackgroundDuringPresentation = false
            
            let scb = sc.searchBar
            scb.tintColor = UIColor.white
            scb.barTintColor = UIColor.white
            
            //Added this piece of code in to fix the issue where the search bar text was hard to see.
            if let textfield = scb.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.black
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                }
            }
            navigationItem.searchController = sc
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            resultSearchController.dimsBackgroundDuringPresentation = false
            //resultSearchController.obscuresBackgroundDuringPresentation = false
            stopTableView.tableHeaderView = resultSearchController.searchBar
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        self.resultSearchController.searchBar.sizeToFit()
    }
    
    /// This funciton is run when the user types in something into the search bar, anytime the string changes this function is run with the updated string.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Flag variable, used in deciding wether to sue the regular array or the filtered array.
        isSearching = true
        
        //Reset arrays to prevent repeats
        stopNameArrFiltered = []
        stopIDArrFiltered = []
        
        //Iterates through all the stops and anything that has a matching string (all lowercased) will be added to the Filtered array
        for i in 0..<stopNameArr.count {
            var currentStrArr: String = stopNameArr[i] as! String
            currentStrArr = currentStrArr.lowercased()
            let currentStrSearch: String = searchBar.text!.lowercased()
            if((currentStrArr.range(of: currentStrSearch)) != nil){
                stopNameArrFiltered = stopNameArrFiltered.adding(stopNameArr[i]) as NSArray
                stopIDArrFiltered = stopIDArrFiltered.adding(stopIDArr[i]) as NSArray
            }
        }
        
        //Reloads the tableView
        stopTableView.reloadData()
    }
    
    //This function resets the array that is displayed on the table to reflect all of the stops.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        isSearching = false
        
        //Removing search vars
        stopNameArrFiltered = []
        stopIDArrFiltered = []
        stopTableView.reloadData()
    }
    
    //Converts the JSON text from the file and sends the data to it's respective arrays.
    func convertJSONtoArr(){
        //All the stops are stored in a txt file named AllStops, access it through here.
        let allStopsTxt = getDataFromText(fileName: "AllStops")
        let decoder = JSONDecoder()
        
        //Decodes the whole JSON file using the mtd_stop_loc struct declated in StructsJSON.swift
        do{
            mtdData = try decoder.decode(mtd_stop_loc.self, from: allStopsTxt.data(using: String.Encoding.utf8)!)
        }catch{
            print(error)
        }
        for i in 0..<mtdData!.stops.count {
            self.stopNameArr = self.stopNameArr.adding(mtdData!.stops[i].stop_name) as NSArray
            self.stopIDArr = self.stopIDArr.adding(mtdData!.stops[i].stop_id) as NSArray
        }
    }
    
    
    /// Helper function to get all of the contents from the described .txt file.
    func getDataFromText(fileName: String) -> String{
        var text: String = ""
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                text = myStrings.joined(separator: "")
            } catch {
                print(error)
            }
        }
        return text
    }
    
    //Displays the table with the predetermined values.
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
    
    //didSelectRowAt function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If isSearching is true then uses values from the filtered array because that's what is being displayed, if false, then uses the regular array.
        if(isSearching){
            currentStop = stopNameArrFiltered[indexPath.item] as! String
            currentStopCode = stopIDArrFiltered[indexPath.item] as! String
        }else{
            currentStop = stopNameArr[indexPath.item] as! String
            currentStopCode = stopIDArr[indexPath.item] as! String
        }
        
        stopBusView()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //numberOfRowsInSection function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //If isSearching is true then uses count from the filtered array because that's what is being displayed, if false, then uses the regular array.
        if isSearching {
            return stopNameArrFiltered.count
        }else{
            return stopNameArr.count
        }
    }
    
    //cellForRowAt function
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //If isSearching is true then uses values from the filtered array because that's what is being displayed, if false, then uses the refular array.
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        if(isSearching){
            cell.textLabel!.text = "\(stopNameArrFiltered[indexPath.row])"
        }else{
            cell.textLabel!.text = "\(stopNameArr[indexPath.row])"
        }
        return cell
    }
}


extension StopsViewController{
    //This function goes over to the RoutesViewController with the values of currentStop and currentStopCode to dispaly the routes for the selected stop.
    func stopBusView(){
        navigationController?.pushViewController(RoutesViewController(stop: currentStop, code: currentStopCode), animated: true)
    }
}
