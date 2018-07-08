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


class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //
    }
    
    
    var currentStop: String = ""
    var currentStopCode: String = ""
    
    fileprivate var stopNameArr: NSArray = []
    fileprivate var stopIDArr: NSArray = []
    fileprivate var stopDistance: NSArray = []
    
    fileprivate var stopTableView: UITableView!
    
    var leftConstraint: NSLayoutConstraint!
    var searchBar = UISearchBar()
    let expandableView = ExpandableView()
    var resultSearchController = UISearchController()
    
    var mtdData: mtd_stop_loc? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gray
        
        //print(getDataFromText(fileName: "AllStops"))
        
        self.navigationController?.navigationBar.topItem?.title = "Stops"
        
        convertJSONtoArr()
        displayTable()
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = UIBarStyle.black
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.backgroundColor = UIColor.clear
            //self.stopTableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        //displaySearchBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        
        if resultSearchController.isActive {
            resultSearchController.isActive = false
        }
        super.viewWillDisappear(false)
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.resultSearchController.searchBar
    }
    
    func displaySearchBar(){
        // Expandable area.
        //navigationItem.titleView = (expandableView)
        
        // Search button.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(toggle))
        
        // Search bar.
        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        expandableView.addSubview(searchBar)
        leftConstraint = searchBar.leftAnchor.constraint(equalTo: expandableView.leftAnchor)
        leftConstraint.isActive = false
        searchBar.rightAnchor.constraint(equalTo: expandableView.rightAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: expandableView.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: expandableView.bottomAnchor).isActive = true

        
        // Match background color.
        //searchBar.barTintColor = UIColor.lightGray
    }
    
    @objc func toggle() {
        
        let isOpen = (leftConstraint.isActive == true)
        
        leftConstraint.isActive = isOpen ? false : true
        
        if isOpen {
            print("isOpen: True")
            navigationItem.titleView = nil
            navigationItem.title = "Stops"
            leftConstraint.isActive = false
            self.navigationController?.navigationBar.topItem?.title = "Stops"
        } else {
            print("isOpen: False")
            //displaySearchBar()
            navigationItem.titleView = expandableView
            leftConstraint.isActive = true
            navigationItem.setLeftBarButton(nil, animated: true)
        }
        
        // Animate change to visible.
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationItem.titleView?.alpha = isOpen ? 0 : 1
            self.navigationController?.view.layoutIfNeeded()
        })
        
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
        //print(text)
        return text
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentStop = stopNameArr[indexPath.item] as! String
        currentStopCode = stopIDArr[indexPath.item] as! String
        stopBusView()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(stopNameArr[indexPath.row])"
        return cell
    }
    
}

extension StopsViewController{
    func stopBusView(){
        navigationController?.pushViewController(StopBusListViewController(stop: currentStop, code: currentStopCode), animated: true)
        
    }
}

class ExpandableView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .none
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
}
