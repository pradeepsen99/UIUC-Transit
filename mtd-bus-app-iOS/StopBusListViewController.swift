//
//  StopBusListViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/2/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit

struct mtd_routes: Codable{
    let departures: [DEPATURE_INFO]
    
    struct DEPATURE_INFO: Codable{
        let stop_id: String
        let headsign: String
        let route: [ROUTES]
        struct ROUTES: Codable{
            let route_color: String
            let route_id: String
            let route_long_name: Double
            let route_short_name: Double
            let route_text_color: String
        }
        let scheduled: String
        let expected: String
        let expected_mins: String
        let location: [LOCATION_INFO]
        struct LOCATION_INFO: Codable{
            let lat: Float
            let long: Float
        }
    }
}

class StopBusListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentStop:String = ""
    var currentStopCode: String = ""
    
    fileprivate var currentStopData: mtd_routes? = nil
    fileprivate var busNameArr: NSArray = []
    fileprivate var stopTableView: UITableView!
    
    
    /// Initializer of the class
    ///
    /// - Parameters:
    ///   - stop: the current stop name.
    ///   - code: the current stop code.
    init(stop: String, code: String) {
        self.currentStop = stop
        self.currentStopCode = code
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(busNameArr[indexPath.row])"
        return cell
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.darkGray
        //navigationController?
        self.title = currentStop
        //
        
        guard let gitUrl = URL(string: "https://developer.cumtd.com/api/v2.2/JSON/getdeparturesbystop?key=f298fa4670de47f68a5630304e66227d&stop_id="+currentStopCode) else { return }
        
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            //print(String(data: data!, encoding: .utf8)!)
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let mtdData = try decoder.decode(mtd_routes.self, from: data)
                self.currentStopData = mtdData
                DispatchQueue.main.async {
                    if(mtdData.departures.count == 0){
                        self.busNameArr = self.busNameArr.adding("Currently No Stops") as NSArray
                    }else{
                        for i in 0..<mtdData.departures.count {
                            self.busNameArr = self.busNameArr.adding(mtdData.departures[i].headsign) as NSArray
                        }
                    }
                    
                    self.displayTable()
                }
            } catch let err {
                print("Error Downloading data", err)
            }
            }.resume()
    }
    
    
    /// Displays the table using the given values.
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

extension StopBusListViewController{
    
}
