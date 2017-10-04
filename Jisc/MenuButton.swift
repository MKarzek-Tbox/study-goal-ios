//
//  MenuButton.swift
//  Jisc
//
//  Created by Paul on 6/6/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

enum MenuButtonType:String {
    case Feed = "Activity Feed"
    case Friends = "Friends"
	case Stats = "Stats"
	case Log = "Log"
    case Checkin = "Check-in"
	case Target = "Target"
	case Settings = "Settings"
	case Logout = "Logout"
}

let kButtonSelectionNotification = Notification.Name("kButtonSelectionNotification")

class MenuButton: UIView {
	
	@IBOutlet weak var button:UIButton!
	var type = MenuButtonType.Feed
	weak var parent:MenuView?
	
    
	class func insertSelfinView(_ view:UIView, buttonType: MenuButtonType, previousButton:MenuButton?, isLastButton:Bool, parent:MenuView) -> MenuButton {
		let button = Bundle.main.loadNibNamed("\(self.classForCoder())", owner: nil, options: nil)!.first as! MenuButton
		button.translatesAutoresizingMaskIntoConstraints = false
		button.type = buttonType
		button.parent = parent
		button.button.setTitle(buttonType.rawValue, for: .normal)
		button.button.setTitle(buttonType.rawValue, for: .selected)
		switch buttonType {
		case .Feed:
			button.button.setImage(UIImage(named: "FeedVCMenuIcon"), for: .normal)
			button.button.setImage(UIImage(named: "FeedVCMenuIconSelected"), for: .selected)
			break
        case .Friends:
            button.button.setImage(UIImage(named: "FriendsMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "FriendsMenuIconSelected"), for: .selected)

            break
		case .Stats:
			button.button.setImage(UIImage(named: "StatsVCMenuIcon"), for: .normal)
			button.button.setImage(UIImage(named: "StatsVCMenuIconSelected"), for: .selected)
			break
		case .Log:
			button.button.setImage(UIImage(named: "LogVCMenuIcon"), for: .normal)
			button.button.setImage(UIImage(named: "LogVCMenuIconSelected"), for: .selected)
			break
        case .Checkin:
            button.button.setImage(UIImage(named: "CheckinVCMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "CheckinVCMenuIconSelected"), for: .selected)
            break
		case .Target:
			button.button.setImage(UIImage(named: "TargetVCMenuIcon"), for: .normal)
			button.button.setImage(UIImage(named: "TargetVCMenuIconSelected"), for: .selected)
			break
		case .Settings:
			button.button.setImage(UIImage(named: "settingsMenuIcon"), for: .normal)
			button.button.setImage(UIImage(named: "settingsMenuIconSelected"), for: .selected)
			break
		case .Logout:
			button.button.setImage(UIImage(named: "logoutMenuIcon"), for: .normal)
			button.button.setImage(UIImage(named: "logoutMenuIcon"), for: .selected)
			break
		}
		view.addSubview(button)
		let leading = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
		let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: button, attribute: .trailing, multiplier: 1.0, constant: 0.0)
		view.addConstraints([leading, trailing])
		if let previousButton = previousButton {
			let top = NSLayoutConstraint(item: previousButton, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .top, multiplier: 1.0, constant: 0.0)
			view.addConstraint(top)
		} else {
			let top = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
			view.addConstraint(top)
		}
		if isLastButton {
			let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1.0, constant: 0.0)
			view.addConstraint(bottom)
		}
		NotificationCenter.default.addObserver(button, selector: #selector(selectedAButton(_:)), name: kButtonSelectionNotification, object: nil)
		return button
	}
	
	func selectedAButton(_ notification:Notification) {
		if let type = notification.object as? MenuButtonType {
			if self.type == type {
				button.isSelected = true
			} else {
				button.isSelected = false
				if let stats = self as? StatsMenuButton {
					stats.retract()
				}
			}
		}
	}
	
	@IBAction func buttonAction(_ sender:UIButton?) {
		switch type {
		case .Feed:
			parent?.feed()
            break
        case .Friends:
            parent?.friends()
            break
		case .Stats:
			parent?.stats()
			break
		case .Log:
			parent?.log()
			break
        case .Checkin:
            parent?.checkin()
            break
		case .Target:
			parent?.target()
			break
		case .Settings:
			parent?.settings()
			break
		case .Logout:
			parent?.logout()
			break
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}

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
    var menuItemsArray = [localized("activity_points"),localized("app_usage"),localized("attainment"),localized("attendence_summary"),localized("events_attended"),localized("vle_activity")]
	
	override func buttonAction(_ sender: UIButton?) {
		if expanded {
			retract()
		} else {
			expand()
		}
	}
	
	func expand() {
		expanded = true
        self.statsMenuButtonsTable.delegate = self
        self.statsMenuButtonsTable.dataSource = self
        self.statsMenuButtonsTable.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
		UIView.animate(withDuration: 0.25) {
			self.arrow.transform = CGAffineTransform(rotationAngle: .pi / 2.0)
			self.buttonsHeight.constant = 40 * 6 //This constant multiplication multiplies the height by the number of buttons shown, for example 40 * 4(buttons) or 40 *6(buttons) Adjust it as necesary.
			self.parent?.layoutIfNeeded()
		}
        var result = ""

        if !demo(){
            let defaults = UserDefaults.standard
            result = defaults.object(forKey: "SettingsReturnAttendance") as! String
        }

        //let attainmentResult = defaults.object(forKey: "SettingsReturnAttainment") as! String
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
            //        if (attainmentResult.range(of: "false") != nil){
            //            attainmentButton.alpha = 1.0
            //        } else {
            //            attainmentButton.alpha = 0.0
            //        }
        
        }

	}
	
	func retract() {
		expanded = false
		UIView.animate(withDuration: 0.25) {
			self.arrow.transform = CGAffineTransform.identity
			self.buttonsHeight.constant = 0.0
			self.parent?.layoutIfNeeded()
		}
	}
	
	@IBAction func graph(_ sender:UIButton?) {
		parent?.close(nil)
		parent?.stats()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.parent?.statsViewController.goToGraph()
		}
		retract()
	}
	
	@IBAction func attainment(_ sender:UIButton?) {
		parent?.close(nil)
		parent?.stats()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.parent?.statsViewController.goToAttainment()
		}
		retract()
	}
	
	@IBAction func points(_ sender:UIButton?) {
		parent?.close(nil)
		parent?.stats()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.parent?.statsViewController.goToPoints()
		}
		retract()
	}
    
//    @IBAction func leaderBoard(_ sender: UIButton) {
//        parent?.close(nil)
//        parent?.stats()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            self.parent?.statsViewController.goToLeaderBoard()
//        }
//        retract()
//    }
    
    @IBAction func eventsAttended(_ sender: UIButton) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToEventsAttended()
        }
        retract()
    }
    
    @IBAction func attendance(_ sender: UIButton) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToAttendance()
        }
        retract()
    }
	
    @IBAction func appUsageAction(_ sender: Any) {
        parent?.close(nil)
        parent?.appUsage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            //Put code here to go to the view controller
            self.parent?.appUsageViewController
        }
        retract()

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! UITableViewCell
        cell.textLabel?.text = menuItemsArray[indexPath.row]
        cell.textLabel?.textColor = UIColor.gray
        cell.textLabel?.font = UIFont(name: "System", size: 10.0)
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! UITableViewCell
        cell.textLabel?.text = menuItemsArray[indexPath.row]
        cell.textLabel?.textColor = UIColor.gray
        cell.textLabel?.font = UIFont(name: "System", size: 10.0)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemsArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32.5
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            parent?.close(nil)
            parent?.stats()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsViewController.goToPoints()
            }
            retract()
        } else if indexPath.row == 1 {
            parent?.close(nil)
            parent?.appUsage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                //Put code here to go to the view controller
                //self.parent?.appUsageViewController
            }
            retract()
        } else if indexPath.row == 2 {
            parent?.close(nil)
            parent?.stats()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsViewController.goToAttainment()
            }
            retract()
        } else if indexPath.row == 3 {
            parent?.close(nil)
            parent?.stats()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsViewController.goToAttendance()
            }
            retract()
        } else if indexPath.row == 4 {
            parent?.close(nil)
            parent?.stats()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsViewController.goToEventsAttended()
            }
            retract()
        } else if indexPath.row == 5 {
            parent?.close(nil)
            parent?.stats()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.parent?.statsViewController.goToGraph()
            }
            retract()
        }
    }
}
