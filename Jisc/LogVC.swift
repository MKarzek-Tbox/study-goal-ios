//
//  LogVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let emptyLogPageMessage = localized("empty_log_page_message")

class LogVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, CustomPickerViewDelegate {
    
    @IBOutlet weak var activityLogsTable:UITableView!
    @IBOutlet weak var activityActionButton:UIButton!
    var aCellIsOpen:Bool = false
    @IBOutlet weak var emptyScreenMessage:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        activityLogsTable.register(UINib(nibName: kOneActivityCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kOneActivityCellIdentifier)
        activityLogsTable.contentInset = UIEdgeInsetsMake(20.0, 0, 20.0, 0)
        
        if (dataManager.runningActivities().count > 0) {
            activityActionButton.setImage(UIImage(named: "runningActivity"), for: UIControlState())
        } else {
            activityActionButton.setImage(UIImage(named: "addButton"), for: UIControlState())
        }
        NotificationCenter.default.addObserver(self, selector: #selector(LogVC.refreshActivityLogs), name: NSNotification.Name(rawValue: kRefreshActivitiesScreen), object: nil)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(LogVC.manuallyRefreshLogs(_:)), for: UIControlEvents.valueChanged)
        activityLogsTable.addSubview(refreshControl)
        
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=logs-main&contentName=MainLogsPage"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=logs-main&contentName=MainLogsPage"
        }
        xAPIManager().checkMod(testUrl:urlString)
    }
    
    /**
     Opens menu drawer.
     
     :sender: button that triggered the action
     */
    @IBAction func openMenu(_ sender:UIButton?) {
        DELEGATE.menuView?.open()
    }
    
    /**
     Refresh activity logs table view.
     */
    func refreshActivityLogs() {
        if (dataManager.runningActivities().count > 0) {
            activityActionButton.setImage(UIImage(named: "runningActivity"), for: UIControlState())
        } else {
            activityActionButton.setImage(UIImage(named: "addButton"), for: UIControlState())
        }
        activityLogsTable.reloadData()
    }
    
    /**
     Manually refresh activity logs by the user.
     
     :sender: button that triggered the action
     */
    func manuallyRefreshLogs(_ sender:UIRefreshControl) {
        dataManager.silentActivityLogsRefresh { (success, failureReason) -> Void in
            self.activityLogsTable.reloadData()
            sender.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (dataManager.runningActivities().count > 0) {
            activityActionButton.setImage(UIImage(named: "runningActivity"), for: UIControlState())
        } else {
            activityActionButton.setImage(UIImage(named: "addButton"), for: UIControlState())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityLogsTable.reloadData()
    }
    
    /**
     Navigates to report activity view.
     
     :module: module id
     :activityType: activity type id
     :activity: activity id
     */
    func goToReportActivity(_ module:Int, activityType:Int, activity:Int) {
        if (dataManager.runningActivities().count > 0) {
            navigationController?.pushViewController(NewActivityVC(activity: dataManager.runningActivities()[0], atIndex: 0), animated: true)
        } else {
            navigationController?.pushViewController(NewActivityVC(module: module, activityType: activityType, activity: activity), animated: true)
        }
    }
    
    /**
     Navigates to log new activity view.
     
     :sender: button that triggered the action
     */
    @IBAction func showNewActivitySelector(_ sender:UIButton) {
        if (dataManager.runningActivities().count > 0) {
            if (dataManager.modules().count == 0) {
                navigationController?.pushViewController(NewActivityVC(activity: dataManager.runningActivities()[0], atIndex: 0), animated: true)
            } else {
                navigationController?.pushViewController(NewActivityVC(activity: dataManager.runningActivities()[0], atIndex: 0), animated: true)
            }
        } else {
            var array:[String] = [String]()
            array.append(localized("report_activity"))
            array.append(localized("log_recent"))
            let logTypeSelectorView = CustomPickerView.create(localized("add"), delegate: self, contentArray: array, selectedItem: -1)
            view.addSubview(logTypeSelectorView)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    //MARK: CustomPickerView Delegate
    
    func view(_ view: CustomPickerView, selectedRow: Int) {
        if (selectedRow == 0) {
            if (dataManager.modules().count == 0) {
                if (dataManager.runningActivities().count > 0) {
                    navigationController?.pushViewController(NewActivityVC(activity: dataManager.runningActivities()[0], atIndex: 0), animated: true)
                } else {
                    navigationController?.pushViewController(NewActivityVC(), animated: true)
                }
                //				}
            } else {
                if (dataManager.runningActivities().count > 0) {
                    navigationController?.pushViewController(NewActivityVC(activity: dataManager.runningActivities()[0], atIndex: 0), animated: true)
                } else {
                    navigationController?.pushViewController(NewActivityVC(), animated: true)
                }
            }
            
        } else if (selectedRow == 1) {
            if (dataManager.modules().count == 0) {
                navigationController?.pushViewController(LogActivityVC(), animated: true)
            } else {
                navigationController?.pushViewController(LogActivityVC(), animated: true)
            }
            
        }
    }
    
    //MARK: UITableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let nrRows = dataManager.activityLogsArray().count
        if (nrRows == 0) {
            emptyScreenMessage.alpha = 1.0
        } else {
            emptyScreenMessage.alpha = 0.0
        }
        return nrRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var theCell = tableView.dequeueReusableCell(withIdentifier: kOneActivityCellIdentifier)
        if (theCell == nil) {
            theCell = UITableViewCell()
        }
        return theCell!
    }
    
    //MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theCell:OneActivityCell? = cell as? OneActivityCell
        let activity = dataManager.activityLogsArray()[indexPath.row]
        theCell?.loadActivity(activity, navigationController:navigationController, tableView:tableView)
        theCell?.parent = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (aCellIsOpen) {
            tableView.reloadData()
        } else {
            let activity = dataManager.activityLogsArray()[indexPath.row]
            let vc = ActivityDetailsVC(activity: activity)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
