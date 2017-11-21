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
		switch buttonType {
		case .Feed:
			button.button.setImage(UIImage(named: "FeedVCMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "FeedVCMenuIconSelected"), for: .selected)
            button.button.setTitle(localized("activity_feed"), for: .normal)
            button.button.setTitle(localized("activity_feed"), for: .selected)
			break
        case .Friends:
            button.button.setImage(UIImage(named: "FriendsMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "FriendsMenuIconSelected"), for: .selected)
            button.button.setTitle(localized("friends"), for: .normal)
            button.button.setTitle(localized("friends"), for: .selected)
            break
		case .Stats:
			button.button.setImage(UIImage(named: "StatsVCMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "StatsVCMenuIconSelected"), for: .selected)
            button.button.setTitle(localized("stats"), for: .normal)
            button.button.setTitle(localized("stats"), for: .selected)
			break
		case .Log:
			button.button.setImage(UIImage(named: "LogVCMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "LogVCMenuIconSelected"), for: .selected)
            button.button.setTitle(localized("log"), for: .normal)
            button.button.setTitle(localized("log"), for: .selected)
			break
        case .Checkin:
            button.button.setImage(UIImage(named: "CheckinVCMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "CheckinVCMenuIconSelected"), for: .selected)
            button.button.setTitle(localized("checkin"), for: .normal)
            button.button.setTitle(localized("checkin"), for: .selected)
            break
		case .Target:
			button.button.setImage(UIImage(named: "TargetVCMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "TargetVCMenuIconSelected"), for: .selected)
            button.button.setTitle(localized("target"), for: .normal)
            button.button.setTitle(localized("target"), for: .selected)
			break
		case .Settings:
			button.button.setImage(UIImage(named: "settingsMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "settingsMenuIconSelected"), for: .selected)
            button.button.setTitle(localized("settings"), for: .normal)
            button.button.setTitle(localized("settings"), for: .selected)
			break
		case .Logout:
			button.button.setImage(UIImage(named: "logoutMenuIcon"), for: .normal)
            button.button.setImage(UIImage(named: "logoutMenuIcon"), for: .selected)
            button.button.setTitle(localized("logout"), for: .normal)
            button.button.setTitle(localized("logout"), for: .selected)
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
                if let stats = self as? StatsMenuButton {

                }else {
                    print("notify here")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
                }
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
