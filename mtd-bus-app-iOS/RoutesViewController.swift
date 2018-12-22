//
//  StopBusListViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/2/18.
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
import UserNotifications


class RoutesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentStop:String = ""
    var currentStopCode: String = ""
    var initialLoad: Bool = false
    
    fileprivate var currentStopData: mtd_routes? = nil
    fileprivate var busNameArr: NSArray = []
    fileprivate var busTimeArr: NSArray = []
    fileprivate var stopTableView: UITableView!
    
    var alertController: UIAlertController?
    var alertTimer: Timer?
    var remainingTime = 0
    var baseMessage: String?
    
    var favButton: UIBarButtonItem? = nil
    
    let center = UNUserNotificationCenter.current()
    
    let options: UNAuthorizationOptions = [.alert, .sound];
    
    private let refreshControl = UIRefreshControl()
    
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
    
    /// Required function to have a constructor
    ///
    /// - Parameter aDecoder: un-used var
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Function to deselect cell on e unclicked.
    ///
    /// - Parameters:
    ///   - tableView: tableView clicked at
    ///   - indexPath: index of cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "MyCell")
        cell.textLabel!.text = "\(busNameArr[indexPath.row])"
        cell.detailTextLabel?.text = "\(busTimeArr[indexPath.row]) mins"
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        //TODO Revamp the 
        let share = UITableViewRowAction(style: .normal, title: "Add Reminder") { action, index in
            
            let defaults = UserDefaults.standard
            let notificationsCheck = defaults.bool(forKey: "notificationsCheck")
            
            if(notificationsCheck){
                let content = UNMutableNotificationContent()
                content.title = "Bus Reminder!"
                content.body = (self.busNameArr[editActionsForRowAt.row] as! String).description + " has arrived at " + self.currentStop
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = "UYLReminderCategory"
                
                print(self.busTimeArr[editActionsForRowAt.row])
                let busTimeStr: String = self.busTimeArr[editActionsForRowAt.row] as! String
                var busTimeInSec: Double = Double(busTimeStr)! * 60
                
                if(busTimeInSec == 0){
                    busTimeInSec = 1.0
                }
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: busTimeInSec,
                                                                repeats: false)
                
                let identifier = "UYLLocalNotification"
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content, trigger: trigger)
                self.center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        print("swipe error")
                    }
                })
                
                print("worked")
            }else{
                self.showAlertMsg(title: "You have notifications disabled, please re-enable them", message: "You will be redirected to the settings menu in: ", time: 5)

            }

        }
        share.backgroundColor = .blue
        
        return [share]
    }

    /// This function determines the color of the favorite by seeing if it is part of the favStopsName array and if it is changes it to blue, otherwise it chsanges it to white. Runs after favOnClick() is run
    func checkIfStopChangeColor(){
        favButton = nil
        
        favButton = UIBarButtonItem.init(
            image: UIImage(named: "star.png")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(favOnClick)
        )
        
        let defaults = UserDefaults.standard
        
        let arrayofStopsNameDatabase = defaults.stringArray(forKey: "favStopsName") ?? [String]()
        
        var isFound: Bool = false
        
        for i in 0..<arrayofStopsNameDatabase.count {
            if(currentStop == arrayofStopsNameDatabase[i]){
                isFound = true
            }
        }
        
        if(isFound){
            favButton?.tintColor = .blue
        }else{
            favButton?.tintColor = .white
        }
        
        self.navigationItem.rightBarButtonItem = favButton
    }
    
    func downloadBusNames(){
        guard let gitUrl = URL(string: "https://developer.cumtd.com/api/v2.2/JSON/getdeparturesbystop?key=f298fa4670de47f68a5630304e66227d&stop_id="+currentStopCode+"&pt=60") else { return }
        
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let mtdData = try decoder.decode(mtd_routes.self, from: data)
                self.currentStopData = mtdData
                DispatchQueue.main.async {
                    if(mtdData.departures.count == 0){
                        self.busNameArr = self.busNameArr.adding("Currently No Stops") as NSArray
                        self.busTimeArr = self.busTimeArr.adding("n/a") as NSArray
                    }else{
                        for i in 0..<mtdData.departures.count {
                            self.busNameArr = self.busNameArr.adding(mtdData.departures[i].headsign) as NSArray
                            self.busTimeArr = self.busTimeArr.adding(mtdData.departures[i].expected_mins.description) as NSArray
                        }
                    }
                    //runs a one time code that displays the table.
                    if(!self.initialLoad){
                        self.displayTable()
                        self.initialLoad = true
                    }
                    
                }
            } catch let err {
                print("Error Downloading data", err)
            }
            }.resume()
    }
    
    override func viewDidLoad() {
        checkIfStopChangeColor()
        
        view.backgroundColor = UIColor.darkGray
        self.title = currentStop
        
        //Adds the favorite button

        downloadBusNames()
        initTable()

    }
    
    //This function initalizes the tableView. To be run during 
    func initTable(){
        let barHeight: CGFloat = 0
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        self.stopTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        self.stopTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.stopTableView.dataSource = self
        self.stopTableView.delegate = self
        self.stopTableView.separatorStyle = .none
    }
    
    /// Displays the table using the given values.
    func displayTable(){

        view.addSubview(self.stopTableView)
        
        //Swiping down to refresh code.
        if #available(iOS 10.0, *) {
            stopTableView.refreshControl = refreshControl
        } else {
            stopTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshStopData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0, green:0, blue:0.85, alpha:1.0)
    }
    
    /// This functions runs when the user pulls down and activates the refreshControl.
    ///
    /// - Parameter sender: un-used var
    @objc private func refreshStopData(_ sender: Any) {
        self.refreshControl.beginRefreshing()
        // Re-Fetch Stop Data
        DispatchQueue.main.async {
            self.busNameArr = []
            self.busTimeArr = []
            self.downloadBusNames()
            self.stopTableView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
}

extension RoutesViewController{
    @objc func favOnClick(){
        
        let defaults = UserDefaults.standard
        
        var arrayOfStopsName: NSMutableArray = []
        var arrayOfStopsCode: NSMutableArray = []
        
        //Gets the data stored in the device on the favorited stops and the associated code for the stop.
        let arrayofStopsNameDatabase = defaults.stringArray(forKey: "favStopsName") ?? [String]()
        let arrayofStopsCodeDatabase = defaults.stringArray(forKey: "favStopsCode") ?? [String]()

        //If the name array stored in the database has no values then automatically adds selected stop to it without checking for redundencies.
        if(arrayofStopsNameDatabase.count == 0){
            arrayOfStopsName = NSMutableArray(array: arrayOfStopsName.adding(currentStop))
            arrayOfStopsCode = NSMutableArray(array: arrayOfStopsCode.adding(currentStopCode))
            defaults.set(arrayOfStopsName, forKey: "favStopsName")
            defaults.set(arrayOfStopsCode, forKey: "favStopsCode")
        }else{
            var isFound: Bool = false
            
            //Goes through the entire favorites array and checks if the current stop favorited is mentioned, if found it sets the flag var to True and removes the instance from the temp database array.
            for i in 0..<arrayofStopsNameDatabase.count{
                if(arrayofStopsNameDatabase[i].description == currentStop){
                    isFound = true
                    
                    arrayOfStopsName = NSMutableArray(array: arrayofStopsNameDatabase)
                    arrayOfStopsCode = NSMutableArray(array: arrayofStopsCodeDatabase)

                    arrayOfStopsName.remove(arrayOfStopsName[i])
                    arrayOfStopsCode.remove(arrayOfStopsCode[i])
                    
                }
            }
            //If not found then a new addition to the temp database name array is made.
            if(isFound == false){
                arrayOfStopsName = NSMutableArray(array: arrayofStopsNameDatabase)
                arrayOfStopsName = NSMutableArray(array: arrayOfStopsName.adding(currentStop))
                arrayOfStopsCode = NSMutableArray(array: arrayofStopsCodeDatabase)
                arrayOfStopsCode = NSMutableArray(array: arrayOfStopsCode.adding(currentStopCode))
            }
            
            //Temp array set to be the UserDefaults, stores the favorited stops name and corresponding stop code.
            defaults.set(arrayOfStopsName, forKey: "favStopsName")
            defaults.set(arrayOfStopsCode, forKey: "favStopsCode")
        }
        
        //Tells the FavoritesViewController to run the function load which refreshes the table values with the newly added ones.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        //Runs the function to determine wether the favorite button should change color depending on wether it's part of the favorited list.
        checkIfStopChangeColor()
    }
    
    
    func showAlertMsg(title: String, message: String, time: Int) {
        
        guard (self.alertController == nil) else {
            print("Alert already displayed")
            return
        }
        
        self.baseMessage = message
        self.remainingTime = time
        
        self.alertController = UIAlertController(title: title, message: self.alertMessage(), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.alertController=nil;
            self.alertTimer?.invalidate()
            self.alertTimer=nil
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 3
            }
        }
        
        self.alertController!.addAction(cancelAction)
        
        self.alertTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(RoutesViewController.countDown), userInfo: nil, repeats: true)
        
        self.present(self.alertController!, animated: true, completion: nil)
    }
    
    @objc func countDown() {
        
        self.remainingTime -= 1
        if (self.remainingTime < 0) {
            self.alertTimer?.invalidate()
            self.alertTimer = nil
            self.alertController!.dismiss(animated: true, completion: {
                self.alertController = nil
            })
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 3
            }
        } else {
            self.alertController!.message = self.alertMessage()
        }
        
    }
    
    func alertMessage() -> String {
        var message=""
        if let baseMessage=self.baseMessage {
            message=baseMessage+" "
        }
        return(message+"\(self.remainingTime)")
    }
}
