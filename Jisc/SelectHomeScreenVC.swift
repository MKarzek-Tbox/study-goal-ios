//
//  SelectHomeScreenVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/22/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

class SelectHomeScreenVC: BaseViewController {
	
	@IBOutlet weak var feedCheckmark:UIImageView!
	@IBOutlet weak var statsCheckmark:UIImageView!
	@IBOutlet weak var logCheckmark:UIImageView!
	@IBOutlet weak var targetCheckmark:UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		highlightSelectedItem()
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	func highlightSelectedItem() {
		feedCheckmark.alpha = 0.0
		statsCheckmark.alpha = 0.0
		logCheckmark.alpha = 0.0
		targetCheckmark.alpha = 0.0
		
		let selectedScreen = getHomeScreenTab()
		
		switch (selectedScreen) {
		case .feed:
			feedCheckmark.alpha = 1.0
		case .stats:
			statsCheckmark.alpha = 1.0
		case .log:
			logCheckmark.alpha = 1.0
		case .target:
			targetCheckmark.alpha = 1.0
		}
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func selectScreen(_ sender:UIButton) {
		if isDemo {
			let alert = UIAlertController(title: "", message: localized("demo_mode_changeappsettings"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
			var selectedScreen = kHomeScreenTab(rawValue: sender.tag)
			if (dataManager.currentStudent != nil) {
				if (!dataManager.currentStudent!.institution.isLearningAnalytics.boolValue) {
					if (selectedScreen == .stats) {
						return
					}
				}
			}
			setHomeScreenTab(selectedScreen)
			if (selectedScreen == nil) {
				selectedScreen = .feed
			}
			switch (selectedScreen!) {
			case .feed:
				DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "home_screen", settingValue: "feed", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					self.highlightSelectedItem()
				})
				break
			case .stats:
				DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "home_screen", settingValue: "stats", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					self.highlightSelectedItem()
				})
				break
			case .log:
				DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "home_screen", settingValue: "log", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					self.highlightSelectedItem()
				})
				break
			case .target:
				DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "home_screen", settingValue: "target", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					self.highlightSelectedItem()
				})
				break
			}
		}
	}
}
