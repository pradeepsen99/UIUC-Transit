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

class ViewController: UIViewController {
    fileprivate var menuButton: IconButton!
    fileprivate var switchControl: Switch!
    fileprivate var moreButton1: IconButton!
    
    fileprivate var card: Card!
    fileprivate var toolbar: Toolbar!
    fileprivate var moreButton: IconButton!
    fileprivate var contentView: UILabel!
    fileprivate var bottomBar: Bar!
    fileprivate var dateFormatter: DateFormatter!
    fileprivate var dateLabel: UILabel!
    fileprivate var favoriteButton: IconButton!
    
    
    @IBOutlet weak var lblTest: UILabel!
    fileprivate var lat: Double = 0
    fileprivate var long: Double = 0
    fileprivate var counter: Int = 0
    fileprivate var API: String = ""
    
    
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.grey.lighten5
        
        prepareDateFormatter()
        prepareDateLabel()
        prepareFavoriteButton()
        prepareMoreButton()
        prepareToolbar(stopName: "FAR STOP")
        prepareContentView(content: "FAR")
        prepareBottomBar()
        prepareCard(shift: -500)
        
        prepareDateFormatter()
        prepareDateLabel()
        prepareFavoriteButton()
        prepareMoreButton()
        prepareToolbar(stopName: "PAR STOP")
        prepareContentView(content: "FAR")
        prepareBottomBar()
        prepareCard(shift: 200)
        
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
        //downloadData()
        //displayLatLong()
        
        
        
        
        
        
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
                    self.API = (mtdData.stops.last?.stop_name)!
                    
                }
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
    
    
}

extension ViewController {
    
    
    fileprivate func prepareDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    fileprivate func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.grey.base
        dateLabel.text = dateFormatter.string(from: Date.init())
    }
    
    fileprivate func prepareFavoriteButton() {
        favoriteButton = IconButton(image: Icon.favorite, tintColor: Color.red.base)
    }
    
    fileprivate func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreVertical, tintColor: Color.grey.base)
        
    }
    
    fileprivate func prepareToolbar(stopName: String) {
        toolbar = Toolbar(rightViews: [moreButton])
        
        toolbar.title = stopName
        toolbar.titleLabel.textAlignment = .center
        
        /**toolbar.detail = ""
        toolbar.detailLabel.textAlignment = .left
        toolbar.detailLabel.textColor = Color.grey.base*/
    }
    
    fileprivate func prepareContentView(content: String) {
        contentView = UILabel()
        contentView.numberOfLines = 0
        contentView.text = content
        contentView.font = RobotoFont.regular(with: 14)
    }
    
    fileprivate func prepareBottomBar() {
        bottomBar = Bar()
        
        bottomBar.leftViews = [favoriteButton]
        bottomBar.rightViews = [dateLabel]
    }
    
    fileprivate func prepareCard(shift: Float) {
        card = Card()
        
        card.toolbar = toolbar
        card.toolbarEdgeInsetsPreset = .square3
        card.toolbarEdgeInsets.bottom = 0
        card.toolbarEdgeInsets.right = 8
        
        card.contentView = contentView
        card.contentViewEdgeInsetsPreset = .wideRectangle3
        
        card.bottomBar = bottomBar
        card.bottomBarEdgeInsetsPreset = .wideRectangle2
        
        view.layout(card).horizontally(left: 5, right: 5).center()
        view.layout(card).vertically(top: CGFloat(shift)).center()
    }
}

extension ViewController {
    fileprivate func prepareMenuButton() {
        menuButton = IconButton(image: Icon.cm.menu)
        menuButton.addTarget(self, action: #selector(handleMenuButton), for: .touchUpInside)
    }
    
    fileprivate func prepareSwitch() {
        switchControl = Switch(state: .off, style: .light, size: .small)
    }
    
    fileprivate func prepareMoreButton1() {
        moreButton = IconButton(image: Icon.cm.moreVertical)
        moreButton.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
    }
    
    
    fileprivate func prepareToolbar() {
        toolbar.leftViews = [menuButton]
        toolbar.rightViews = [switchControl, moreButton]
    }
}

extension ViewController {
    @objc
    fileprivate func handleMenuButton() {
        navigationDrawerController?.toggleLeftView()
    }
    
    @objc
    fileprivate func handleMoreButton() {
        navigationDrawerController?.toggleRightView()
    }
}


