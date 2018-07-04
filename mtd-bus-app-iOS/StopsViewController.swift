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


class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentStop: String = ""
    
    fileprivate var stopNameArr: NSArray = []
    fileprivate var stopTableView: UITableView!
    
    var mtdData: mtd_stop_loc? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gray
        
        //print(getDataFromText(fileName: "AllStops"))
        
        self.navigationController?.navigationBar.topItem?.title = "Stops"

        convertJSONtoArr()
        displayTable()
        
    }
    
    func convertToJson(){
        
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
        stopBusView()
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
        navigationController?.pushViewController(StopBusListViewController(stop: currentStop), animated: true)
        
    }
}
