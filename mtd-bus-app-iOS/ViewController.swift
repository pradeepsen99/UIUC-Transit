
//
//  ViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 6/19/18.
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
import UserNotifications


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate {
    
    let numberOfStops: Int = 15
    let feetToMileConv: Double = 0.000189393939
    
    var currentStop: String = ""
    var currentStopCode: String = ""
    
    fileprivate var lat: Double = 0
    fileprivate var long: Double = 0
    
    fileprivate var stopNameArr: NSArray = []
    fileprivate var stopIDArr: NSArray = []
    fileprivate var stopDistance: NSArray = []
    fileprivate var stopTableView: UITableView!
    
    fileprivate var currentStopData: mtd_stop_loc? = nil
    
    private let refreshControl = UIRefreshControl()
    
    let locationManager = CLLocationManager()
    
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound];
    
    var initialLoad: Bool = false
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        //view.backgroundColor = UIColor.gray
        initTable()
        
        // For use when the app is open
        DispatchQueue.main.async {
            //Requests the user to provide access to use their location.
            self.locationManager.requestWhenInUseAuthorization()
            
            //Requests the user to provide access to give them notifications for stuff like bus timings.
            self.center.requestAuthorization(options: self.options) { (granted, error) in
                if !granted {
                    print("Something went wrong")
                }
            }
            
        }
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //Title of the Tab
        self.navigationController?.navigationBar.topItem?.title = "Nearby"
        
        downloadCurrentStopData()
        
        if(!isStopArrEmpty()){
            //Set up for 3D Touch in the cells of stopTableView
            registerForPreviewing(with: self, sourceView: stopTableView)
        }
        
    }
    
    func isStopArrEmpty() -> Bool{
        return stopNameArr.count == 0
    }
    
    /// Displays the table based on pre determined values. The table will fit in the middle of the screen, making sure to be under the tab bar and the navigation controller. Can change the values inside the function to make the table bigger or smaller, change color, etc.
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
    
    func displayTable(){
        if(!isStopArrEmpty()){
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
    }
    
    
    /// This functions runs when the user pulls down and activates the refreshControl.
    ///
    /// - Parameter sender: un-used var
    @objc private func refreshStopData(_ sender: Any) {
        self.refreshControl.beginRefreshing()
        // Re-Fetch Stop Data
        DispatchQueue.main.async {
            self.stopNameArr = []
            self.stopIDArr = []
            self.stopDistance = []
            self.downloadCurrentStopData()
            self.stopTableView.reloadData()
        }
        self.refreshControl.endRefreshing()
    }
    
    
    
    /// This function updates the current Lat and Long values. It also downloads the stop data based on the current lat+long values
    @IBAction func downloadCurrentStopData (){
        
        //If for some reason location location is not acessible, then it will display prompt that location services was not enabled for the app.
        if(locationManager.location?.coordinate.latitude != nil || ((locationManager.location?.coordinate.longitude) != nil)){
            
            lat = (locationManager.location?.coordinate.latitude)!
            long = (locationManager.location?.coordinate.longitude)!
            
            //had to add this because adding it directly to the url made swift throw an error.
            let countStopsAPI = "&count=" + numberOfStops.description
            
            guard let apiURL = URL(string: "https://developer.cumtd.com/api/v2.2/JSON/getstopsbylatlon?key=" + mainApiKey.description + "&lat="+lat.description + "&lon=" + long.description + countStopsAPI) else { return }
            
            URLSession.shared.dataTask(with: apiURL) { (data, response
                , error) in
                
                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    //Decodes the JSON recieved from the url.
                    let mtdData = try decoder.decode(mtd_stop_loc.self, from: data)
                    self.currentStopData = mtdData
                    DispatchQueue.main.async {
                        //Iterates through all of the stops in the decoded data (stops) in mtdData.
                        for i in 0..<mtdData.stops.count {
                            //Adds the stop name and stop id to respective arrays.
                            self.stopNameArr = self.stopNameArr.adding(mtdData.stops[i].stop_name) as NSArray
                            self.stopIDArr = self.stopIDArr.adding(mtdData.stops[i].stop_id) as NSArray
                            
                            //Gets the distance, in feet, and converts it to miles and adds it to the array.
                            let currentDistacne = ((mtdData.stops[i].distance)*self.feetToMileConv)
                            let roundedDownDistance = String(format: "%.2f", currentDistacne) + " mi"
                            self.stopDistance = self.stopDistance.adding(roundedDownDistance) as NSArray
                        }
                        //Code to acess the coreData functinality.
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context = appDelegate.persistentContainer.viewContext
                        let entity = NSEntityDescription.entity(forEntityName: "StopData", in: context)
                        let newUser = NSManagedObject(entity: entity!, insertInto: context)
                        
                        //Adds the stop data to the currentStopList.
                        newUser.setValue(mtdData, forKey: "currentStopList")
                        
                        if(!self.initialLoad){
                            self.initialLoad = true
                            self.displayTable()
                            
                        }
                        if(!self.isStopArrEmpty()){
                            self.stopTableView.reloadData()
                            print(self.view.subviews.count)
                        }
                        
                    }
                } catch let err {
                    print("Error Downloading data", err)
                }
                }.resume()
        }else{
            showLocationDisabledPopUp()
        }
    }
    
    
    /// If location has been deined access, give the user the option to change it
    ///
    /// - Parameters:
    ///   - manager: Location Manager
    ///   - status: CLAuthorizationStatus
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    
    /// Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to get information about your closest stops we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Function runs if memory is too high, this function will reduce the resources until memory goes down.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
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
        //let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "MyCell")
        cell.textLabel!.text = "\(stopNameArr[indexPath.row])"
        cell.detailTextLabel?.text = "\(stopDistance[indexPath.row])"
        return cell
    }
    
    
    /// This function runs when the user uses 3D touch and lightly presses (peek). This changes the currentStop and currentStopCode to the data of the cell the user pressed on.
    ///
    /// - Parameters:
    ///   - previewingContext: The viewController to display when peeking
    ///   - location: Point in the screen where the user is pressing down.
    /// - Returns: The ViewController to be displayed.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = stopTableView.indexPathForRow(at: location) else {
            return nil
        }
        currentStop = stopNameArr[indexPath.row] as! String
        currentStopCode = stopIDArr[indexPath.row] as! String
        print(currentStop)
        print(currentStopCode)
        
        return RoutesViewController(stop: currentStop, code: currentStopCode)
    }
    
    
    /// This function runs when the user uses the 3D touch and presses on it with full force. This pushes the selected view using the navigation controller.
    ///
    /// - Parameters:
    ///   - previewingContext: un-used var
    ///   - viewControllerToCommit: un-used var
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        stopBusView()
    }
    
}

extension ViewController {
    
    /// This function uses the navigationController to open up a new new controller: StopBusListViewController with the values of the currentStopCode and the currentStop in the constructor. It is also animated to look good.
    func stopBusView(){
        navigationController?.pushViewController(RoutesViewController(stop: currentStop, code: currentStopCode), animated: true)

    }
}





