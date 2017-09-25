//
//  MenuView.swift
//  Jisc
//
//  Created by Paul on 6/6/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class MenuView: UIView {
	
	let feedViewController = FeedVC()
    let friendsViewController = SearchVC()
	let checkinViewController = CheckinVC()
	let statsViewController = StatsVC()
	let logViewController = LogVC()
	let targetViewController = TargetVC()
    let appUsageViewController = AppUsageViewController()

	@IBOutlet weak var profileImage:UIImageDownload!
	@IBOutlet weak var nameLabel:UILabel!
	@IBOutlet weak var emailLabel:UILabel!
	@IBOutlet weak var studentIdLabel:UILabel!
	@IBOutlet weak var menuContent:UIView!
	@IBOutlet weak var closeButton:UIButton!
	@IBOutlet weak var menuLeading:NSLayoutConstraint!
	var selectedIndex = 0

	class func createView() -> MenuView {
		let view = Bundle.main.loadNibNamed("MenuView", owner: nil, options: nil)!.first as! MenuView
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.menuLeading.constant = -280.0
		view.closeButton.alpha = 0.0
		view.nameLabel.text = "\(dataManager.currentStudent!.firstName) \(dataManager.currentStudent!.lastName)"
		view.emailLabel.text = dataManager.currentStudent!.email
        if (view.emailLabel.text == "not@known"){
            view.emailLabel.isHidden = true
        }
		view.studentIdLabel.text = "\(localized("student_id")) : \(dataManager.currentStudent!.jisc_id)"
		view.profileImage.loadImageWithLink("\(hostPath)\(dataManager.currentStudent!.photo)", type: .profile) { () -> Void in
			
		}
        var result = ""
        if !demo(){
            let defaults = UserDefaults.standard
            result = defaults.object(forKey: "SettingsReturn") as! String
            print("defaults value \(defaults.object(forKey: "SettingsReturn")!)")
        }
		var lastButton:MenuButton?
		let index = getHomeScreenTab().rawValue
		if social() {
			lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Feed, previousButton: lastButton, isLastButton: false, parent: view)
			lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Log, previousButton: lastButton, isLastButton: false, parent: view)
			lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Target, previousButton: lastButton, isLastButton: false, parent: view)
			if index == 0 {
				view.feed()
			} else if index == 1 {
				view.log()
			} else if index == 2 {
				view.target()
			} else {
				view.feed()
			}
            print("issocial");

		} else {
            print("not social");
			lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Feed, previousButton: lastButton, isLastButton: false, parent: view)
            lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Friends, previousButton: lastButton, isLastButton: false, parent: view)
			if iPad {
				lastButton = StatsMenuButton.insertSelfinView(view.menuContent, buttonType: .Stats, previousButton: lastButton, isLastButton: false, parent: view)
			} else {
				lastButton = StatsMenuButton.insertSelfinView(view.menuContent, buttonType: .Stats, previousButton: lastButton, isLastButton: false, parent: view)
			}
            
			lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Log, previousButton: lastButton, isLastButton: false, parent: view)
            if !demo(){
                print("menu check \(result.range(of: "true"))")
                if (result.range(of: "true") != nil)
                {
                    //Show check-in when response is true.
                    lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Checkin, previousButton: lastButton, isLastButton: false, parent: view)
                }
            } else {
                    lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Checkin, previousButton: lastButton, isLastButton: false, parent: view)
            }

            lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Target, previousButton: lastButton, isLastButton: false, parent: view)
            
            /*switch (index){
            case 0:
                view.feed()
            case 1:
                view.friends()
            case 2:
                view.stats()
            case 3:
                view.checkin()
            case 4:
                view.log()
            case 5:
                view.target()
            case 6:
                view.settings()
            default:
                view.logout()
            }*/
            
			if index == 0 {
				view.feed()
            } else if index == 1 {
                view.friends()
            } else if index == 2 {
				view.stats()
            } else if index == 3 {
                view.checkin()
            } else if index == 4 {
                view.log()
            } else if index == 5 {
                if !demo(){
                    if (result.range(of: "false") == nil){
                        view.feed()
                    } else {
                        view.checkin()
                    }
                }

            } else if index == 6 {
				view.target()
			} else {
				view.feed()
			}
		}
		lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Settings, previousButton: lastButton, isLastButton: false, parent: view)
		lastButton = MenuButton.insertSelfinView(view.menuContent, buttonType: .Logout, previousButton: lastButton, isLastButton: true, parent: view)
        if let user = dataManager.currentStudent {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
            DownloadManager().registerForRemoteNotifications(studentId: user.id, isActive: 1, alertAboutInternet: false, completion: { (success, dictionary, array, error) in
                
            })
        }
		if let nvcView = DELEGATE.mainNavigationController?.view {
			nvcView.addSubview(view)
			let leading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: nvcView, attribute: .leading, multiplier: 1.0, constant: 0.0)
			let trailing = NSLayoutConstraint(item: nvcView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
			let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: nvcView, attribute: .top, multiplier: 1.0, constant: 0.0)
			let bottom = NSLayoutConstraint(item: nvcView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
			nvcView.addConstraints([leading, trailing, top, bottom])
		}
		return view
	}
	
	func open() {
        let view = Bundle.main.loadNibNamed("MenuView", owner: nil, options: nil)!.first as! MenuView
        view.profileImage.loadImageWithLink("\(hostPath)\(dataManager.currentStudent!.photo)", type: .profile) { () -> Void in
            print("Picture code from open function should have been called")
        }

		isUserInteractionEnabled = true
		superview?.bringSubview(toFront: self)
		UIView.animate(withDuration: 0.25) { 
			self.menuLeading.constant = 0.0
			self.layoutIfNeeded()
			self.closeButton.alpha = 1.0
		}
	}
    
    func goToRecurringVC(){
        
    }
	
	@IBAction func close(_ sender:UIButton?) {
		isUserInteractionEnabled = false
		UIView.animate(withDuration: 0.25) {
			self.menuLeading.constant = -280.0
			self.layoutIfNeeded()
			self.closeButton.alpha = 0.0
		}
	}
	
	func feed() {
		selectedIndex = 0
		NotificationCenter.default.post(name: kButtonSelectionNotification, object: MenuButtonType.Feed)
		DELEGATE.mainNavigationController?.setViewControllers([feedViewController], animated: false)
		close(nil)
	}
    
    func friends() {
        selectedIndex = 1
        NotificationCenter.default.post(name: kButtonSelectionNotification, object: MenuButtonType.Friends)
        DELEGATE.mainNavigationController?.setViewControllers([friendsViewController], animated: false)
        close(nil)
    }
	
	func stats() {
		selectedIndex = 2
		NotificationCenter.default.post(name: kButtonSelectionNotification, object: MenuButtonType.Stats)
		DELEGATE.mainNavigationController?.setViewControllers([statsViewController], animated: false)
		close(nil)
	}
    
    func appUsage() {
        selectedIndex = 2
        NotificationCenter.default.post(name: kButtonSelectionNotification, object: MenuButtonType.Stats)
        DELEGATE.mainNavigationController?.setViewControllers([appUsageViewController], animated: false)
        close(nil)
    }
    
    func checkin() {
        print("checking in")
        selectedIndex = 3
        NotificationCenter.default.post(name: kButtonSelectionNotification, object: MenuButtonType.Checkin)
        DELEGATE.mainNavigationController?.setViewControllers([checkinViewController], animated: false)
        close(nil)
    }
	
	func log() {
		selectedIndex = 4
		NotificationCenter.default.post(name: kButtonSelectionNotification, object: MenuButtonType.Log)
		DELEGATE.mainNavigationController?.setViewControllers([logViewController], animated: false)
		close(nil)
	}
	
	func target() {
		selectedIndex = 5
		NotificationCenter.default.post(name: kButtonSelectionNotification, object: MenuButtonType.Target)
		DELEGATE.mainNavigationController?.setViewControllers([targetViewController], animated: false)
		close(nil)
	}
	
	func settings() {
		let vc = SettingsVC()
		DELEGATE.mainNavigationController?.pushViewController(vc, animated: true)
		close(nil)
	}
	
	func logout() {
		let alert = UIAlertController(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_log_out"), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: localized("no"), style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: localized("yes"), style: .default, handler: { (action) in
			if let cookies = HTTPCookieStorage.shared.cookies {
				for cookie in cookies {
					HTTPCookieStorage.shared.deleteCookie(cookie)
				}
			}
			runningActivititesTimer.invalidate()
			DELEGATE.menuView?.feedViewController.refreshTimer?.invalidate()
			dataManager.currentStudent = nil
			dataManager.firstTrophyCheck = true
			deleteCurrentUser()
			clearXAPIToken()
			DELEGATE.mainNavigationController = UINavigationController(rootViewController: LoginVC())
			DELEGATE.mainNavigationController?.isNavigationBarHidden = true
			DELEGATE.window?.rootViewController = DELEGATE.mainNavigationController
		}))
		DELEGATE.mainNavigationController?.present(alert, animated: true, completion: nil)
		close(nil)
	}
}
