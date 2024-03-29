//
//  SettingsViewController.swift
//  mtd-bus-app-iOS
//
//  Created by Pradeep Kumar on 7/8/18.
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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate var settingsArr: NSArray = []
    fileprivate var settingsTableView: UITableView!

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "MyCell")
        cell.textLabel!.text = "\(settingsArr[indexPath.row])"
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = indexPath.row // for detect which row switch Changed
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        //let image : UIImage = UIImage(named: "advertising")!
        //cell.imageView?.image = image
        
        return cell
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        
        let defaults = UserDefaults.standard
        let notificationsCheck = defaults.bool(forKey: "notificationsCheck")
        
        if(notificationsCheck){
            defaults.set(false, forKey: "notificationsCheck")
        }else{
            defaults.set(true, forKey: "notificationsCheck")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Settings"
        
        //This function contains the options to choose from
        addingValsArray()
        
        displayTable()
    }
    
    
    func addingValsArray(){
        //Adds the options to select from
        settingsArr = settingsArr.adding("Notifications") as NSArray
        settingsArr = settingsArr.adding("Night Mode") as NSArray
        //settingsArr = settingsArr.adding("")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    func displayTable(){
        
        let barHeight: CGFloat = 0
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height

        self.settingsTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight))
        self.settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.settingsTableView.dataSource = self
        self.settingsTableView.delegate = self
        self.settingsTableView.separatorStyle = .singleLine
        self.settingsTableView.rowHeight = UITableView.automaticDimension
        
        self.settingsTableView.alwaysBounceVertical = false
        self.settingsTableView.allowsSelection = false

        view.addSubview(self.settingsTableView)
    }

}
