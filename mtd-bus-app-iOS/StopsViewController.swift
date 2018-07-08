//
//  StopsViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/3/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Foundation


class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var currentStop: String = ""
    var currentStopCode: String = ""
    
    fileprivate var stopNameArr: NSArray = []
    fileprivate var stopIDArr: NSArray = []
    fileprivate var stopDistance: NSArray = []
    
    fileprivate var stopTableView: UITableView!
    var leftConstraint: NSLayoutConstraint!
    let searchBar = UISearchBar()
    
    var mtdData: mtd_stop_loc? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gray
        
        //print(getDataFromText(fileName: "AllStops"))
        
        self.navigationController?.navigationBar.topItem?.title = "Stops"

        convertJSONtoArr()
        displayTable()
        displaySearchBar()
    }
    
    func displaySearchBar(){
        // Expandable area.
        let expandableView = ExpandableView()
        navigationItem.titleView = expandableView
        
        // Search button.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(toggle))
        
        // Search bar.
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        expandableView.addSubview(searchBar)
        leftConstraint = searchBar.leftAnchor.constraint(equalTo: expandableView.leftAnchor)
        leftConstraint.isActive = false
        searchBar.rightAnchor.constraint(equalTo: expandableView.rightAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: expandableView.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: expandableView.bottomAnchor).isActive = true
    }
    
    @objc func toggle() {
        
        let isOpen = leftConstraint.isActive == true
        
        // Inactivating the left constraint closes the expandable header.
        leftConstraint.isActive = isOpen ? false : true
        
        if isOpen {
            leftConstraint.isActive = false
            self.navigationController?.navigationBar.topItem?.title = "Stops"
            //navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
            print("true")
        } else {
            leftConstraint.isActive = true
            navigationItem.setLeftBarButton(nil, animated: true)
            print("false")
        }
        
        // Animate change to visible.
        UIView.animate(withDuration: 1.5, animations: {
            self.navigationItem.titleView?.alpha = isOpen ? 0 : 1
            self.navigationController?.view.layoutIfNeeded()
        })
        self.navigationController?.navigationBar.topItem?.title = "Stops"

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
