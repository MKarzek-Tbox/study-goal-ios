//
//  MainTabBarController.swift
//  Jisc
//
//  Created by Therapy Box on 10/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import QuartzCore

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
	
	let feedViewController = FeedVC()
	let checkinViewController = CheckinVC()
	let statsViewController = StatsVC()
	let logViewController = LogVC()
	let targetViewController = TargetVC()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setViewControllers(createdViewControllers(), animated: false)
		
		selectedIndex = getHomeScreenTab().rawValue
		tabBar.frame = CGRect(x: tabBar.frame.origin.x, y: tabBar.frame.origin.y, width: tabBar.frame.size.width, height: 45)
		self.delegate = self

		
		if let user = dataManager.currentStudent {
			UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
			UIApplication.shared.registerForRemoteNotifications()
			DownloadManager().registerForRemoteNotifications(studentId: user.id, isActive: 1, alertAboutInternet: false, completion: { (success, dictionary, array, error) in
				
			})
		}
	}
	
	func createdViewControllers() -> [UIViewController]? {
		feedViewController.tabBarItem = tabBarItem("Feed")
		checkinViewController.tabBarItem = tabBarItem("Check-in")

		statsViewController.tabBarItem = tabBarItem("Stats")
		logViewController.tabBarItem = tabBarItem("Log")
		targetViewController.tabBarItem = tabBarItem("Target")
		
//		if (dataManager.currentStudent != nil) {
//			if (!dataManager.currentStudent!.institution.isLearningAnalytics.boolValue) {
//				statsViewController.tabBarItem.isEnabled = false
//			}
//		}
		
		tabBar.backgroundImage = UIImage(named: "darkGray")
		tabBar.layer.masksToBounds = true
		
		if (iPad) {
			tabBar.itemPositioning = .centered
		}
		
		let navigationController1 = UINavigationController(rootViewController: feedViewController)
		navigationController1.isNavigationBarHidden = true

		let navigationController2 = UINavigationController(rootViewController: checkinViewController)
		navigationController2.isNavigationBarHidden = true
		let navigationController3 = UINavigationController(rootViewController: statsViewController)
		navigationController3.isNavigationBarHidden = true
		let navigationController4 = UINavigationController(rootViewController: logViewController)
		navigationController4.isNavigationBarHidden = true
		let navigationController5 = UINavigationController(rootViewController: targetViewController)
		navigationController5.isNavigationBarHidden = true
		
		var viewControllers = [navigationController1, navigationController2, navigationController3, navigationController4, navigationController5]
//		var viewControllers = [navigationController1, navigationController3, navigationController4, navigationController5]
		
		if currentUserType() == .social {
			let navigationController1 = UINavigationController(rootViewController: feedViewController)
			navigationController1.isNavigationBarHidden = true
			let navigationController2 = UINavigationController(rootViewController: logViewController)
			navigationController2.isNavigationBarHidden = true
			let navigationController3 = UINavigationController(rootViewController: targetViewController)
			navigationController3.isNavigationBarHidden = true
			
			viewControllers = [navigationController1, navigationController2, navigationController3]
		}
		
		return viewControllers
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if (iPad && tabBar.itemSpacing != 1.0) {
			tabBar.itemSpacing = 1.0
		}
	}
	
	func tabBarItem(_ name:String) -> UITabBarItem { 
		let image = UIImage(named: "\(name)VCTabIcon")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		let selectedImage = UIImage(named: "\(name)VCTabIconSelected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		let item = UITabBarItem(title: localized(name.lowercased()), image: image, selectedImage: selectedImage)
		
		let normalColor = UIColor.white
		let normalFont = UIFont(name: "Myriad Pro", size: 12)!
		let normalAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:normalColor, NSFontAttributeName:normalFont]
		
		let selectedColor = UIColor(red: 253.0/255.0, green: 179.0/255.0, blue: 73.0/255.0, alpha: 1.0)
		let selectedFont = UIFont(name: "Myriad Pro", size: 12)!
		let selectedAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:selectedColor, NSFontAttributeName:selectedFont]
		
		item.setTitleTextAttributes(normalAttributes, for: UIControlState.normal)
		item.setTitleTextAttributes(selectedAttributes, for: UIControlState.selected)
		return item
	}
	
	//MARK: UITabBarController Delegate
	
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		
		// selectedIndex represents the viewController that was visible before the button press
		
		if (selectedIndex == 0) {
			let nvc = feedViewController.navigationController
			if (nvc != nil) {
				let visible = nvc!.visibleViewController
				if (visible != nil) {
					if (visible!.isKind(of: SearchVC.self)) {
						nvc!.popToRootViewController(animated: false)
					}
				}
			}
		}
		
		if (viewControllers != nil) {
			if (viewControllers!.count > selectedIndex) {
				let nvc = viewControllers![selectedIndex] as? UINavigationController
				if (nvc != nil) {
					let visible = nvc!.visibleViewController
					if (visible != nil) {
						if (visible!.isKind(of: SettingsVC.self)) {
							nvc!.popToRootViewController(animated: false)
						}
					}
				}
			}
		}
	}
	
	//MARK: Orientation
	
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		if (iPad) {
			return UIInterfaceOrientationMask.landscape
		} else {
			return UIInterfaceOrientationMask.portrait
		}
	}
}
