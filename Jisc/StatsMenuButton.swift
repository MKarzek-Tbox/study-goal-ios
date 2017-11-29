//
//  StatsMenuButton.swift
//  Jisc
//
//  Created by Marjana Karzek on 20/10/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class StatsMenuButton: MenuButton,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var arrow:UIImageView!
    @IBOutlet weak var buttonsHeight:NSLayoutConstraint!
    
    @IBOutlet weak var attendanceButton: UIButton!
    @IBOutlet weak var eventsAttendedButton: UIButton!
    @IBOutlet weak var leaderboardsButton: UIButton!
    @IBOutlet weak var attainmentButton: UIButton!
    @IBOutlet weak var appUsageButton: UIButton!
    
    @IBOutlet weak var statsMenuButtonsTable: UITableView!
    
    var expanded = false
    var menuItemsArray = [localized("activity_points"),localized("attainment"),localized("attendence"),localized("vle_activity")]
    
    override func buttonAction(_ sender: UIButton?) {
        if expanded {
            retract()
        } else {
            expand()
        }
    }
    
    /**
     Expands the stats menu section.
     */
    func expand() {
        expanded = true
        self.statsMenuButtonsTable.delegate = self
        self.statsMenuButtonsTable.dataSource = self
        self.statsMenuButtonsTable.separatorStyle = UITableViewCellSeparatorStyle.none
        self.statsMenuButtonsTable.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        UIView.animate(withDuration: 0.25) {
            self.arrow.transform = CGAffineTransform(rotationAngle: .pi / 2.0)
            //This constant multiplication multiplies the height by the number of buttons shown, for example 40 * 4(buttons) or 40 * 6(buttons) Adjust it as necesary.
            self.buttonsHeight.constant = 40 * 4
            self.parent?.layoutIfNeeded()
        }
        var result = ""
        
        if !demo(){
            let defaults = UserDefaults.standard
            result = defaults.object(forKey: "SettingsReturnAttendance") as! String
        }
        
        if !demo(){
            // Show events attended and events summary menu items when response contains true.
            if (result.range(of: "true") == nil){
                attendanceButton.alpha = 1.0
                eventsAttendedButton.alpha = 1.0
                //leaderboardsButton.alpha = 1.0
            } else {
                attendanceButton.alpha = 1.0
                eventsAttendedButton.alpha = 1.0
                //leaderboardsButton.alpha = 0.0
            }
        }
    }
    
    /**
     Collapses the stats menu section.
     */
    func retract() {
        expanded = false
        UIView.animate(withDuration: 0.25) {
            self.arrow.transform = CGAffineTransform.identity
            self.buttonsHeight.constant = 0.0
            self.parent?.layoutIfNeeded()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! UITableViewCell
        cell.textLabel?.text = menuItemsArray[indexPath.row]
        cell.textLabel?.textColor = UIColor.gray
        cell.textLabel?.font = UIFont(name: "Myriad Pro", size: 14.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! UITableViewCell
        cell.textLabel?.text = menuItemsArray[indexPath.row]
        cell.textLabel?.textColor = UIColor.gray
        cell.textLabel?.font = UIFont(name: "Myriad Pro", size: 14.0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NotificationCenter.default.addObserver(self, selector: #selector(unselectTableCells), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        return menuItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.contentView.backgroundColor = UIColor.white
        cell.textLabel?.textColor = UIColor.init(red: 59.0/255.0, green: 104.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        if indexPath.row == 0 {
            parent?.close(nil)
            parent?.statsActivityPoints()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsActivityPointsViewController
            }
            /* used for future implementation of app usage
             increase indexPath.rom check for the following buttons of app usage
             
             } else if indexPath.row == 1 {
             parent?.close(nil)
             parent?.appUsage()
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
             self.parent?.appUsageViewController
             }*/
        } else if indexPath.row == 1 {
            parent?.close(nil)
            parent?.statsAttainment()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsAttainmentViewController
            }
        } else if indexPath.row == 2 {
            parent?.close(nil)
            parent?.statsAttendance()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsAttendanceViewController
            }
        } else if indexPath.row == 3 {
            parent?.close(nil)
            parent?.statsVLEActivity()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsVLEActivityViewController
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.textLabel?.textColor = UIColor.init(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)
    }
    
    /**
     Removes highlight of table view cells.
     */
    func unselectTableCells(){
        statsMenuButtonsTable.reloadData()
    }
}
