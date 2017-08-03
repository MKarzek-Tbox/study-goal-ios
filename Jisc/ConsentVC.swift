//
//  ConsentVC.swift
//  Jisc
//
//  Created by Therapy Box on 3/16/16.
//  Copyright © 2016 Therapy Box. All rights reserved.
//

import UIKit

class ConsentVC: BaseViewController {
	
	@IBOutlet weak var acceptAnalyticsButton:UIButton!
	@IBOutlet weak var acceptPrivacyButton:UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		DownloadManager().getConsentSettings(dataManager.currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
			if (result != nil) {
				let analytics = boolFromDictionary(result!, key: "is_consent")
				let privacy = boolFromDictionary(result!, key: "is_privacy")
				self.acceptAnalyticsButton.isSelected = analytics
				self.acceptPrivacyButton.isSelected = privacy
			}
		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	@IBAction func toggleAnalytics(_ sender:UIButton) {
		sender.isSelected = !sender.isSelected
		changeConsentSettings()
	}
	
	@IBAction func togglePrivacy(_ sender:UIButton) {
		sender.isSelected = !sender.isSelected
		changeConsentSettings()
	}
	
	func changeConsentSettings() {
		let myID = dataManager.currentStudent!.id
		let analytics = acceptAnalyticsButton.isSelected
		let privacy = acceptPrivacyButton.isSelected
		DownloadManager().setConsentSettings(myID, alertAboutInternet: true, analytics: analytics, privacy: privacy) { (success, result, results, error) -> Void in
			
		}
	}
}
