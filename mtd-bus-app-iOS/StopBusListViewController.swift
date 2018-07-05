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
        let route: ROUTES
        struct ROUTES: Codable{
            let route_color: String
            let route_id: String
            let route_long_name: String
            let route_text_color: String
        }
        let scheduled: String
        let expected: String
        let expected_mins: Int
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
    
    let favButton = UIBarButtonItem.init(
        image: UIImage(named: "heart.png")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(favOnClick)
    )
    
    @objc func favOnClick(){
        let defaults = UserDefaults.standard
        
        var arrayOfStopsName: NSArray = []
        var arrayOfStopsCode: NSArray = []
        
        let arrayofStopsNameDatabase = defaults.stringArray(forKey: "favStopsName") ?? [String]()
        let arrayofStopsCodeDatabase = defaults.stringArray(forKey: "favStopsCode") ?? [String]()
        
        if(arrayofStopsNameDatabase.count == 0){
            arrayOfStopsName.adding(currentStop)
            arrayOfStopsCode.adding(currentStopCode)
            defaults.set(arrayOfStopsName, forKey: "favStopsName")
            defaults.set(arrayOfStopsCode, forKey: "favStopsCode")
        }else{
            var isFound: Bool = false
            for i in 0..<arrayofStopsNameDatabase.count{
                if(arrayofStopsNameDatabase[i] == currentStop){
                    isFound = true
                }
            }
            if(isFound == false){
                arrayOfStopsName = arrayofStopsNameDatabase as NSArray
                arrayOfStopsName.adding(currentStop)
                arrayOfStopsCode = arrayofStopsCodeDatabase as NSArray
                arrayOfStopsCode.adding(currentStopCode)
            }
        }
        
        FavoritesViewController().viewDidLoad()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.darkGray
        //navigationController?
        self.title = currentStop
        
        //Adds the favorite button
        self.navigationItem.rightBarButtonItem = favButton

        
        guard let gitUrl = URL(string: "https://developer.cumtd.com/api/v2.2/JSON/getdeparturesbystop?key=f298fa4670de47f68a5630304e66227d&stop_id="+currentStopCode) else { return }
        
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            print(String(data: data!, encoding: .utf8)!)
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
