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
        //London Developer July 24,2017
        let urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=logs-main&contentName=MainLogsPage"
        xAPIManager().checkMod(testUrl:urlString)
	}
	
	@IBAction func openMenu(_ sender:UIButton?) {
		DELEGATE.menuView?.open()
	}
	
	func refreshActivityLogs() {
		if (dataManager.runningActivities().count > 0) {
			activityActionButton.setImage(UIImage(named: "runningActivity"), for: UIControlState())
		} else {
			activityActionButton.setImage(UIImage(named: "addButton"), for: UIControlState())
		}
		activityLogsTable.reloadData()
	}
	
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
	
	func goToReportActivity(_ module:Int, activityType:Int, activity:Int) {
		if (dataManager.modules().count == 0) {
//			if (dataManager.currentStudent!.institution.isLearningAnalytics.boolValue) {
//				AlertView.showAlert(false, message: localized("you_have_no_modules"), completion: nil)
//			} else {
				if (dataManager.runningActivities().count > 0) {
					navigationController?.pushViewController(NewActivityVC(activity: dataManager.runningActivities()[0], atIndex: 0), animated: true)
				} else {
					navigationController?.pushViewController(NewActivityVC(module: module, activityType: activityType, activity: activity), animated: true)
				}
//			}
		} else {
			if (dataManager.runningActivities().count > 0) {
				navigationController?.pushViewController(NewActivityVC(activity: dataManager.runningActivities()[0], atIndex: 0), animated: true)
			} else {
				navigationController?.pushViewController(NewActivityVC(module: module, activityType: activityType, activity: activity), animated: true)
			}
		}
	}
	
	@IBAction func showNewActivitySelector(_ sender:UIButton) {
		if (dataManager.runningActivities().count > 0) {
			if (dataManager.modules().count == 0) {
				//				if (dataManager.currentStudent!.institution.isLearningAnalytics.boolValue) {
				//					AlertView.showAlert(false, message: localized("you_have_no_modules"), completion: nil)
				//				} else {
				navigationController?.pushViewController(NewActivityVC(activity: dataManager.runningActivities()[0], atIndex: 0), animated: true)
				//				}
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
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	//MARK: CustomPickerView Delegate
	
	func view(_ view: CustomPickerView, selectedRow: Int) {
		if (selectedRow == 0) {
			if (dataManager.modules().count == 0) {
//				if (dataManager.currentStudent!.institution.isLearningAnalytics.boolValue) {
//					AlertView.showAlert(false, message: localized("you_have_no_modules"), completion: nil)
//				} else {
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
//				if (dataManager.currentStudent!.institution.isLearningAnalytics.boolValue) {
//					AlertView.showAlert(false, message: localized("you_have_no_modules"), completion: nil)
//				} else {
					navigationController?.pushViewController(LogActivityVC(), animated: true)
//				}
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
        //print("Ahmed code YAY!")
        
        /*let url = URL(string: "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats&contentName=Stats%20Overview&modid=mod101")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
            print(response as Any)
            print("This is Ahmed again hopefully it worked!!!")
        }*/
        
        //task.resume()
		if (aCellIsOpen) {
			tableView.reloadData()
		} else {
			let activity = dataManager.activityLogsArray()[indexPath.row]
			let vc = ActivityDetailsVC(activity: activity)
			navigationController?.pushViewController(vc, animated: true)
		}
	}
}
