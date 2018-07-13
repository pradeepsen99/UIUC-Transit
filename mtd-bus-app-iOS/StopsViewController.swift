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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gray
        
        self.definesPresentationContext = true
        
        self.navigationController?.navigationBar.topItem?.title = "Stops"
        
        convertJSONtoArr()
        displayTable()
        
        //Search-Bar properties.
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.delegate = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = UIBarStyle.black
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.backgroundColor = UIColor.clear
            return controller
        })()
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = resultSearchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            stopTableView.tableHeaderView = resultSearchController.searchBar
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        self.resultSearchController.searchBar.sizeToFit()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = true
        
        //Reset arrays
        stopNameArrFiltered = []
        stopIDArrFiltered = []
        
        for i in 0..<stopNameArr.count {
            var currentStrArr: String = stopNameArr[i] as! String
            currentStrArr = currentStrArr.lowercased()
            let currentStrSearch: String = searchBar.text!.lowercased()
            if((currentStrArr.range(of: currentStrSearch)) != nil){
                stopNameArrFiltered = stopNameArrFiltered.adding(stopNameArr[i]) as NSArray
                stopIDArrFiltered = stopIDArrFiltered.adding(stopIDArr[i]) as NSArray
            }
        }
        
        stopTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        isSearching = false
        
        //Removing search vars
        stopNameArrFiltered = []
        stopIDArrFiltered = []
        stopTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return resultSearchController.searchBar.frame.height
    }
    
    
    func convertJSONtoArr(){
        let allStopsTxt = getDataFromText(fileName: "AllStops")
        let decoder = JSONDecoder()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return stopNameArrFiltered.count
        }else{
            return stopNameArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func stopBusView(){
        navigationController?.pushViewController(StopBusListViewController(stop: currentStop, code: currentStopCode), animated: true)
    }
}
