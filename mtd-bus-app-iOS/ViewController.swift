//
//  ViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 6/19/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import CoreLocation
import Material


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
    
    fileprivate var lat: Double = 0
    fileprivate var long: Double = 0
    fileprivate var counter: Int = 0
    fileprivate var API: String = ""
    
    fileprivate var stopNameArr: NSArray = []
    fileprivate var stopTableView: UITableView!


    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = Color.grey.lighten5
        
        prepareToolbar()
        
        

        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
        downloadData()
        displayLatLong()
        
        
        
        
        
        
    }
    
    @IBAction func downloadData (){
        lat = (locationManager.location?.coordinate.latitude)!
        long = (locationManager.location?.coordinate.longitude)!
        guard let gitUrl = URL(string: "https://developer.cumtd.com/api/v2.2/JSON/getstopsbylatlon?key=f298fa4670de47f68a5630304e66227d&lat="+lat.description + "&lon=" + long.description) else { return }

        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let mtdData = try decoder.decode(mtd_stop_loc.self, from: data)

                DispatchQueue.main.sync {

                    for i in 0..<mtdData.stops.count {
                        self.API += (mtdData.stops[i].stop_name) + "\n"
                        self.stopNameArr = self.stopNameArr.adding(mtdData.stops[i].stop_name) as NSArray
                    }
                    print(self.API)

                }
                
                let barHeight: CGFloat = 0
                let displayWidth: CGFloat = self.view.frame.width
                let displayHeight: CGFloat = self.view.frame.height
                
                self.stopTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
                self.stopTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
                self.stopTableView.dataSource = self
                self.stopTableView.delegate = self
                self.stopTableView.separatorStyle = .none
                
                self.view.addSubview(self.stopTableView)
            } catch let err {
                print("Err", err)
            }
            }.resume()
    }
    
    @IBAction func Tap(_ sender: AnyObject) {
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                self.displayLatLong()
            }
        }
    }
    
    
    func displayLatLong(){
        //lat = (locationManager.location?.coordinate.latitude)!
        //long = (locationManager.location?.coordinate.longitude)!
        counter = counter + 1
        //lblTest.text = lat.description + "\n" + long.description + "\n" + counter.description + "\n" + API
    }

    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(stopNameArr[indexPath.row])")
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

extension ViewController {

    
    fileprivate func prepareToolbar() {
        guard let tc = toolbarController else {
            return
        }
        
        tc.toolbar.title = "Stops Near Me"
        tc.toolbar.detail = ""
    }
}


