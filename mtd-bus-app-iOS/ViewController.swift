//
//  ViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 6/19/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


/// The design of the JSON recieved from stopsNearMe
struct mtd_stop_loc: Codable{
    let stops: [STOP_INFO]
    
    struct STOP_INFO: Codable{
        let stop_id: String
        let stop_name: String
        let code: String
        let distance: Double
        let stop_points: [STOP_POINTS]
        struct STOP_POINTS: Codable{
            let code: String
            let stop_id: String
            let stop_lat: Double
            let stop_lon: Double
            let stop_name: String
        }
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gray
        
        // For use when the app is open
        locationManager.requestWhenInUseAuthorization()
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //Title of the Tab
        self.navigationController?.navigationBar.topItem?.title = "Nearby"
        
        checkCacheStopData()
        
    }
    
    /// This function checks the CoreData file to see if the stop info is already stored. If it is not stored then it will proceed to download the data through the downloadCurrentStopData() function.
    func checkCacheStopData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StopData")
        request.returnsObjectsAsFaults = false
        // Fetching data from CoreData
        do {
            let result = try context.fetch(request)
            if(result.count == 0){
                downloadCurrentStopData()
            }else{
                for data in result as! [NSManagedObject] {
                    let tempTest: mtd_stop_loc = data.value(forKey: "currentStopList") as! mtd_stop_loc
                    for i in 0..<tempTest.stops.count {
                        self.stopNameArr = self.stopNameArr.adding(tempTest.stops[i].stop_name) as NSArray
                        self.stopIDArr = self.stopIDArr.adding(tempTest.stops[i].stop_id) as NSArray
                        
                        let currentDistacne = ((tempTest.stops[i].distance)*self.feetToMileConv)
                        let roundedDownDistance = String(format: "%.2f", currentDistacne) + " mi"
                        self.stopDistance = self.stopDistance.adding(roundedDownDistance) as NSArray
                    }
                }
                self.displayTable()
            }
        } catch {
            print("Failed")
        }
    }
    
    
    /// Displays the table based on pre determined values. The table will fit in the middle of the screen, making sure to be under the tab bar and the navigation controller. Can change the values inside the function to make the table bigger or smaller, change color, etc.
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
    
    
    
    /// This function updates the current Lat and Long values. It also downloads the stop data based on the current lat+long values
    @IBAction func downloadCurrentStopData (){
        //Added this do catch statement because sometimes locationManager threw errors
        do{
            lat = (locationManager.location?.coordinate.latitude)!
            long = (locationManager.location?.coordinate.longitude)!
        }catch _{
            //Used recursive to ensure random locationManager errors would show up.
            downloadCurrentStopData()
            return
        }
        
        //had to add this because adding it directly to the url made swift throw an error.
        let countStopsAPI = "&count=" + numberOfStops.description
        
        guard let apiURL = URL(string: "https://developer.cumtd.com/api/v2.2/JSON/getstopsbylatlon?key=f298fa4670de47f68a5630304e66227d&lat="+lat.description + "&lon=" + long.description + countStopsAPI) else { return }
        
        URLSession.shared.dataTask(with: apiURL) { (data, response
            , error) in
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let mtdData = try decoder.decode(mtd_stop_loc.self, from: data)
                self.currentStopData = mtdData
                DispatchQueue.main.async {
                    print(mtdData.stops[1].distance.description)
                    for i in 0..<mtdData.stops.count {
                        self.stopNameArr = self.stopNameArr.adding(mtdData.stops[i].stop_name) as NSArray
                        self.stopIDArr = self.stopIDArr.adding(mtdData.stops[i].stop_id) as NSArray
                        
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
                    
                    self.displayTable()
                }
            } catch let err {
                print("Error Downloading data", err)
            }
            }.resume()
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
    
    /// A simple getter for currentStop
    ///
    /// - Returns: currentStop
    func getCurrentStop()->String{
        return currentStop
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
    
}

extension ViewController {
    
    /// This function uses the navigationController to open up a new new controller: StopBusListViewController with the values of the currentStopCode and the currentStop in the constructor. It is also animated to look good.
    func stopBusView(){
        navigationController?.pushViewController(StopBusListViewController(stop: currentStop, code: currentStopCode), animated: true)
        
    }
}





