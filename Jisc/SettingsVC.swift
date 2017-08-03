//
//  SettingsVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/21/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import MessageUI

let kSettingsWillAppearNotification = "kSettingsWillAppearNotification"
let maximumImageSizeInBytes:Int = 500000

class SettingsVC: BaseViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CustomPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
	
	@IBOutlet weak var profileImage:UIImageDownload!
	@IBOutlet weak var blurredProfileImage:UIImageView!
	@IBOutlet weak var nameLabel:UILabel!
	@IBOutlet weak var emailLabel:UILabel!
	@IBOutlet weak var studentIDLabel:UILabel!
	@IBOutlet weak var myFriendsLabel:UILabel!
	@IBOutlet weak var homeScreenLabel:UILabel!
	@IBOutlet weak var trophiesLabel:UILabel!
	@IBOutlet weak var languageLabel:UILabel!
	var sourcesSelectorView:CustomPickerView = CustomPickerView()
	@IBOutlet weak var pictureButton:UIButton!
	//iPad only
	var popover:UIPopoverController?
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var currentContentView:UIView!
	weak var currentView:UIView?
	@IBOutlet var profileView:UIView!
	@IBOutlet var friendsView:MyFriendsView!
//	@IBOutlet weak var friendsTableView:UITableView!
	@IBOutlet var homeScreenView:UIView!
	@IBOutlet weak var feedCheckmark:UIImageView!
	@IBOutlet weak var statsCheckmark:UIImageView!
	@IBOutlet weak var logCheckmark:UIImageView!
	@IBOutlet weak var targetCheckmark:UIImageView!
	@IBOutlet var trophiesView:UIView!
	@IBOutlet weak var trophiesWonButton:UIButton!
	@IBOutlet weak var trophiesAvailableButton:UIButton!
	@IBOutlet weak var wonTrophiesTable:UITableView!
	@IBOutlet weak var availableTrophiesTable:UITableView!
	weak var currentTrophyDetailsView:UIView?
	@IBOutlet var languageView:UIView!
	@IBOutlet weak var englishCheckmark:UIImageView!
	@IBOutlet weak var welshCheckmark:UIImageView!
	@IBOutlet var consentView:UIView!
	@IBOutlet weak var acceptAnalyticsButton:UIButton!
	@IBOutlet weak var acceptPrivacyButton:UIButton!
	var goingAway = false
    @IBOutlet var privacyView: UIView!
    @IBOutlet weak var privacyWebView: UIWebView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        //London Developer July 24,2017
        let urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/setting?setting=attendanceData"
        xAPIManager().checkMod(testUrl:urlString)

		myFriendsLabel.text = "\(dataManager.friends().count)"
		trophiesLabel.text = "\(dataManager.myTrophies().count)"
		nameLabel.text = "\(dataManager.currentStudent!.firstName) \(dataManager.currentStudent!.lastName)"
		emailLabel.text = dataManager.currentStudent!.email
        if (emailLabel.text=="not@known"){
            emailLabel.isHidden = true
        }
		studentIDLabel.text = "\(localized("student_id")) : \(dataManager.currentStudent!.jisc_id)"
		blurredProfileImage.alpha = 0.0
		NotificationCenter.default.addObserver(self, selector: #selector(SettingsVC.anotherSettingsViewWillAppear(_:)), name: NSNotification.Name(rawValue: kSettingsWillAppearNotification), object: nil)
		if (iPad) {
//			friendsTableView.registerNib(UINib(nibName: kOneFriendCellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: kOneFriendCellIdentifier)
			wonTrophiesTable.register(UINib(nibName: kTrophiesCelliPadNibName, bundle: Bundle.main), forCellReuseIdentifier: kTrophiesCelliPadIdentifier)
			availableTrophiesTable.register(UINib(nibName: kTrophiesCelliPadNibName, bundle: Bundle.main), forCellReuseIdentifier: kTrophiesCelliPadIdentifier)
			availableTrophiesTable.alpha = 0.0
			
			DownloadManager().getConsentSettings(dataManager.currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
				if (result != nil) {
					let analytics = boolFromDictionary(result!, key: "is_consent")
					let privacy = boolFromDictionary(result!, key: "is_privacy")
					self.acceptAnalyticsButton.isSelected = analytics
					self.acceptPrivacyButton.isSelected = privacy
				}
			}
		}
	}
	
	func anotherSettingsViewWillAppear(_ notification:Notification) {
		let viewController = (notification as NSNotification).userInfo?["viewController"] as? SettingsVC
		let navigationController = (notification as NSNotification).userInfo?["navigationController"] as? UINavigationController
		if (viewController != nil && navigationController != nil) {
			if (viewController! != self && navigationController != self.navigationController) {
				_ = self.navigationController?.popToRootViewController(animated: false)
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		supportedInterfaceOrientationsForIPad = UIInterfaceOrientationMask.allButUpsideDown
		if (navigationController != nil) {
			let userInfo = ["viewController":self, "navigationController": navigationController!]
			NotificationCenter.default.post(name: Notification.Name(rawValue: kSettingsWillAppearNotification), object: nil, userInfo: userInfo)
			NotificationCenter.default.post(name: Notification.Name(rawValue: kSettingsWillAppearNotification), object: self)
		}
		let tab = getHomeScreenTab()
		switch (tab) {
		case .feed:
			homeScreenLabel.text = localized("feed")
		case .stats:
			homeScreenLabel.text = localized("stats")
		case .log:
			homeScreenLabel.text = localized("log")
		case .target:
			homeScreenLabel.text = localized("target")
		}
		
		let language = getAppLanguage()
		switch (language) {
		case .english:
			languageLabel.text = localized("english")
		case .welsh:
			languageLabel.text = localized("welsh")
		}
		
		if (iPad) {
			profile(UIButton())
		}
		goingAway = false
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if (profileImage.image == nil) {
			profileImage.loadImageWithLink("\(hostPath)\(dataManager.currentStudent!.photo)", type: .profile) { () -> Void in
				self.blurredProfileImage.image = self.profileImage.image?.applyDarkEffect()
				UIView.animate(withDuration: 0.25, delay: 0.25, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
					self.blurredProfileImage.alpha = 1.0
					}, completion: nil)
			}
		}
		if (iPad) {
			friendsView.navigationController = navigationController
		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	func addCurrentView(_ view:UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		currentTrophyDetailsView?.removeFromSuperview()
		currentView?.removeFromSuperview()
		currentView = view
		currentContentView.addSubview(currentView!)
		addMarginConstraintsWithView(currentView!, toSuperView: currentContentView)
	}
	
	@IBAction func profile(_ sender:UIButton) {
		titleLabel.text = localized("profile")
		addCurrentView(profileView)
	}
	
	@IBAction func friends(_ sender:UIButton) {
		if (iPad) {
			titleLabel.text = localized("friends")
			addCurrentView(friendsView)
		} else if (!goingAway) {
			goingAway = true
//			let vc = MyFriendsVC()
			let vc = SearchVC()
			vc.myFriends(UIButton())
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func homeScreen(_ sender:UIButton) {
		if (iPad) {
			titleLabel.text = localized("startup_screen")
			addCurrentView(homeScreenView)
			highlightSelectedStartScreen()
		} else if (!goingAway) {
			goingAway = true
			let vc = SelectHomeScreenVC()
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func trophies(_ sender:UIButton) {
		if (iPad) {
			titleLabel.text = localized("trophies")
			addCurrentView(trophiesView)
		} else if (!goingAway) {
			goingAway = true
			let vc = TrophiesVC()
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func language(_ sender:UIButton) {
		if (iPad) {
			titleLabel.text = localized("language")
			addCurrentView(languageView)
			highlightSelectedLanguage()
		} else if (!goingAway) {
			goingAway = true
			let vc = SelectLanguageVC()
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func consent(_ sender:UIButton) {
		if (iPad) {
			titleLabel.text = localized("consent")
			addCurrentView(consentView)
		} else if (!goingAway) {
			goingAway = true
			let vc = ConsentVC()
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
    @IBAction func privacyStatement(_ sender: UIButton) {
        if (iPad) {
            titleLabel.text = localized("consent")
            addCurrentView(privacyView)
            let url = URL(string: "https://github.com/jiscdev/learning-analytics/wiki/Privacy-Statement")
            let requestObj = URLRequest(url: url!)
            privacyWebView.loadRequest(requestObj)
        } else if (!goingAway) {
            goingAway = true
            let vc = PrivacyWebViewVC()
            navigationController?.pushViewController(vc, animated: true)
        }
    
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
	
	func setProfileImageFile(_ image:UIImage?) {
		DownloadManager().editProfile(dataManager.currentStudent!.id, image: image, alertAboutInternet: true) { (success, result, results, error) -> Void in
//			DownloadManager().getStudentDetails(dataManager.currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) -> Void in
//				if (success) {
//					if (results != nil) {
//						let dictionary = results![0] as? NSDictionary
//						if (dictionary != nil) {
//							let newPhotoLink = dictionary!["photo"] as? String
//							if (newPhotoLink != nil) {
//								dataManager.currentStudent!.photo = newPhotoLink!
//								dataManager.safelySaveContext()
//							}
//							self.blurredProfileImage.alpha = 0.0
//							self.profileImage.loadImageWithLink("\(hostPath)\(dataManager.currentStudent!.photo)", type: .Profile) { () -> Void in
//								self.blurredProfileImage.image = self.profileImage.image?.applyDarkEffect()
//								UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
//									self.blurredProfileImage.alpha = 1.0
//									}, completion: nil)
//							}
//						}
//					}
//				}
//			})
			if let jwt = xAPIToken() {
				DownloadManager().loginWithXAPI(jwt, alertAboutInternet: true) { (success, result, results, error) in
					if (result != nil) {
						if let newPhotoLink = result!["profile_pic"] as? String {
							dataManager.currentStudent!.photo = newPhotoLink
							dataManager.safelySaveContext()
						}
						self.blurredProfileImage.alpha = 0.0
						self.profileImage.loadImageWithLink("\(hostPath)\(dataManager.currentStudent!.photo)", type: .profile) { () -> Void in
							self.blurredProfileImage.image = self.profileImage.image?.applyDarkEffect()
							UIView.animate(withDuration: 0.25, delay: 0.25, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
								self.blurredProfileImage.alpha = 1.0
								}, completion: nil)
						}

					}
				}
			}
		}
	}
	
	@IBAction func logout(_ sender:UIButton) {
		UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_log_out"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
	}
	
	func showDetailsForTrophy(_ trophy:Trophy?) {
		currentTrophyDetailsView?.removeFromSuperview()
		if (trophy != nil) {
			currentTrophyDetailsView = TrophyDetailsView.create(trophy)
			if (currentTrophyDetailsView != nil) {
				currentTrophyDetailsView!.alpha = 0.0
				currentContentView.addSubview(currentTrophyDetailsView!)
				addMarginConstraintsWithView(currentTrophyDetailsView!, toSuperView: currentContentView)
				UIView.animate(withDuration: 0.25, animations: { () -> Void in
					self.currentTrophyDetailsView!.alpha = 1.0
				}) 
			}
		}
	}
	
	func highlightSelectedStartScreen() {
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
	
	@IBAction func selectScreen(_ sender:UIButton) {
		if currentUserType() == .demo {
			let alert = UIAlertController(title: "", message: localized("demo_mode_change_app_settings"), preferredStyle: .alert)
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
					self.highlightSelectedStartScreen()
				})
				break
			case .stats:
				DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "home_screen", settingValue: "stats", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					self.highlightSelectedStartScreen()
				})
				break
			case .log:
				DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "home_screen", settingValue: "log", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					self.highlightSelectedStartScreen()
				})
				break
			case .target:
				DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "home_screen", settingValue: "target", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					self.highlightSelectedStartScreen()
				})
				break
			}
		}
	}
	
	@IBAction func trophiesWon(_ sender:UIButton) {
		trophiesWonButton.isSelected = true
		trophiesAvailableButton.isSelected = false
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.wonTrophiesTable.alpha = 1.0
			self.availableTrophiesTable.alpha = 0.0
		}) 
	}
	
	@IBAction func trophiesAvailable(_ sender:UIButton) {
		trophiesWonButton.isSelected = false
		trophiesAvailableButton.isSelected = true
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.wonTrophiesTable.alpha = 0.0
			self.availableTrophiesTable.alpha = 1.0
		}) 
	}
	
	func highlightSelectedLanguage() {
		englishCheckmark.alpha = 0.0
		welshCheckmark.alpha = 0.0
		
		let selectedLanguage = getAppLanguage()
		
		switch (selectedLanguage) {
		case .english:
			englishCheckmark.alpha = 1.0
		case .welsh:
			welshCheckmark.alpha = 1.0
		}
	}
	
	@IBAction func selectLanguage(_ sender:UIButton) {
		if currentUserType() == .demo {
			let alert = UIAlertController(title: "", message: localized("demo_mode_change_app_settings"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
			var selectedLanguage = kLanguage(rawValue: sender.tag)
			if (getAppLanguage() != selectedLanguage) {
				setAppLanguage(selectedLanguage)
				if (selectedLanguage == nil) {
					selectedLanguage = .english
				}
				runningActivititesTimer.invalidate()
				DELEGATE.menuView?.feedViewController.refreshTimer?.invalidate()
				dataManager.firstTrophyCheck = true
				switch (selectedLanguage!) {
				case .english:
					DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "language", settingValue: "english", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
						self.highlightSelectedLanguage()
						BundleLocalization.sharedInstance().language = kAppLanguage.English.rawValue
						DELEGATE.initializeApp()
					})
					break
				case .welsh:
					DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "language", settingValue: "welsh", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
						self.highlightSelectedLanguage()
						BundleLocalization.sharedInstance().language = kAppLanguage.Welsh.rawValue
						DELEGATE.initializeApp()
					})
					break
				}
			}
		}
	}
	
	@IBAction func reportABug(_ sender:UIButton) {
		if (MFMailComposeViewController.canSendMail()) {
			let vc = MFMailComposeViewController()
			vc.mailComposeDelegate = self
			vc.setToRecipients(["learning.analytics@jisc.ac.uk"])
			vc.setSubject(localized("bug_feature_idea"))
			vc.setMessageBody("+ \(localized("bug_or_feature"))\n+ \(localized("affected_parts"))\n+ \(localized("further_details"))\n", isHTML: false)
			navigationController?.present(vc, animated: true, completion: nil)
		} else {
			let message = "Go to your device's settings and log in with an e-mail account to be able to use this functionality"
			UIAlertView(title: "Not available", message: message, delegate: nil, cancelButtonTitle: "Ok").show()
		}
	}
	
	//MARK: MFMailComposeViewController Delegate
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	//MARK: Show Source Selector
	
	@IBAction func showSourceSelector(_ sender:UIButton) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_change_picture"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
			var array:[String] = [String]()
			array.append(localized("library"))
			if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
				array.append(localized("camera"))
			}
			sourcesSelectorView = CustomPickerView.create(localized("choose_source"), delegate: self, contentArray: array, selectedItem: -1)
			view.addSubview(sourcesSelectorView)
		}
	}
	
	//MARK: CustomPickerView Delegate
	
	func view(_ view: CustomPickerView, selectedRow: Int) {
		let imagePickerVC = UIImagePickerController()
		imagePickerVC.allowsEditing = true
		imagePickerVC.delegate = self
		if (selectedRow == 0) {
			imagePickerVC.sourceType = UIImagePickerControllerSourceType.photoLibrary
		} else if (selectedRow == 1) {
			imagePickerVC.sourceType = UIImagePickerControllerSourceType.camera
		}
		if (iPad) {
			popover = UIPopoverController(contentViewController: imagePickerVC)
			popover!.present(from: pictureButton.frame, in: pictureButton.superview!, permittedArrowDirections: .any, animated: true)
		} else {
			navigationController?.present(imagePickerVC, animated: true, completion: nil)
		}
	}
	
	//MARK: UIAlertView Delegate
	
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		if (buttonIndex == 1) {

			dataManager.logout()
		}
	}
	
	//MARK: UIImagePickerController Delegate
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerEditedImage] as? UIImage
		if (iPad) {
			popover?.dismiss(animated: true)
			self.setProfileImageFile(image)
		} else {
			picker.dismiss(animated: true) { () -> Void in
				self.setProfileImageFile(image)
			}
		}
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var nrRows:Int = 0
		switch (tableView) {
//		case friendsTableView:
//			nrRows = dataManager.friends().count
//			break
		case availableTrophiesTable:
			let trophiesCount = dataManager.availableTrophies().count
			nrRows = trophiesCount / 4
			if (trophiesCount % 4 > 0) {
				nrRows += 1
			}
			break
		case wonTrophiesTable:
			let trophiesCount = dataManager.myTrophies().count
			nrRows = trophiesCount / 4
			if (trophiesCount % 4 > 0) {
				nrRows += 1
			}
			break
		default:break
		}
		return nrRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var theCell:UITableViewCell?
		switch (tableView) {
//		case friendsTableView:
//			theCell = tableView.dequeueReusableCellWithIdentifier(kOneFriendCellIdentifier)
//			break
		case availableTrophiesTable:
			theCell = tableView.dequeueReusableCell(withIdentifier: kTrophiesCelliPadIdentifier)
			break
		case wonTrophiesTable:
			theCell = tableView.dequeueReusableCell(withIdentifier: kTrophiesCelliPadIdentifier)
			break
		default:break
		}
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var height:CGFloat = 0.0
		switch (tableView) {
//		case friendsTableView:
//			height = 60.0
//			break
		case availableTrophiesTable:
			height = 126.0
			break
		case wonTrophiesTable:
			height = 126.0
			break
		default:break
		}
		return height
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch (tableView) {
//		case friendsTableView:
//			let theCell:OneFriendCell? = cell as? OneFriendCell
//			if (theCell != nil) {
//				theCell!.tableView = tableView
//				theCell!.loadFriend(dataManager.friends()[indexPath.row])
//			}
//			break
		case availableTrophiesTable:
			let theCell:TrophiesCelliPad? = cell as? TrophiesCelliPad
			if (theCell != nil) {
				theCell?.parent = self
				let leftIndex = indexPath.row * 4
				let middleLeftIndex = leftIndex + 1
				let middleRightIndex = middleLeftIndex + 1
				let rightIndex = middleRightIndex + 1
				var leftTrophy:Trophy? = nil
				var middleLeftTrophy:Trophy? = nil
				var middleRightTrophy:Trophy? = nil
				var rightTrophy:Trophy? = nil
				var trophies:[Trophy] = [Trophy]()
				trophies = dataManager.availableTrophies()
				if (leftIndex < trophies.count) {
					leftTrophy = trophies[leftIndex]
				}
				if (middleLeftIndex < trophies.count) {
					middleLeftTrophy = trophies[middleLeftIndex]
				}
				if (middleRightIndex < trophies.count) {
					middleRightTrophy = trophies[middleRightIndex]
				}
				if (rightIndex < trophies.count) {
					rightTrophy = trophies[rightIndex]
				}
				theCell?.loadTrophies((trophy: leftTrophy, total: 0), middleLeft: (trophy: middleLeftTrophy, total: 0), middleRight: (trophy: middleRightTrophy, total: 0), right: (trophy: rightTrophy, total: 0))
			}
			break
		case wonTrophiesTable:
			let theCell:TrophiesCelliPad? = cell as? TrophiesCelliPad
			if (theCell != nil) {
				theCell?.parent = self
				let leftIndex = indexPath.row * 4
				var leftTotal:Int = 0
				let middleLeftIndex = leftIndex + 1
				var middleLeftTotal:Int = 0
				let middleRightIndex = middleLeftIndex + 1
				var middleRightTotal:Int = 0
				let rightIndex = middleRightIndex + 1
				var rightTotal:Int = 0
				var leftTrophy:Trophy? = nil
				var middleLeftTrophy:Trophy? = nil
				var middleRightTrophy:Trophy? = nil
				var rightTrophy:Trophy? = nil
				var trophies:[AnyObject] = [AnyObject]()
				trophies = dataManager.myTrophies()
				if (leftIndex < trophies.count) {
					let trophy = trophies[leftIndex] as? StudentTrophy
					if (trophy != nil) {
						leftTrophy = trophy!.trophy
						leftTotal = trophy!.total.intValue
					}
				}
				if (middleLeftIndex < trophies.count) {
					let trophy = trophies[middleLeftIndex] as? StudentTrophy
					if (trophy != nil) {
						middleLeftTrophy = trophy!.trophy
						middleLeftTotal = trophy!.total.intValue
					}
				}
				if (middleRightIndex < trophies.count) {
					let trophy = trophies[middleRightIndex] as? StudentTrophy
					if (trophy != nil) {
						middleRightTrophy = trophy!.trophy
						middleRightTotal = trophy!.total.intValue
					}
				}
				if (rightIndex < trophies.count) {
					let trophy = trophies[rightIndex] as? StudentTrophy
					if (trophy != nil) {
						rightTrophy = trophy!.trophy
						rightTotal = trophy!.total.intValue
					}
				}
				theCell?.loadTrophies((trophy: leftTrophy, total: leftTotal), middleLeft: (trophy: middleLeftTrophy, total: middleLeftTotal), middleRight: (trophy: middleRightTrophy, total: middleRightTotal), right: (trophy: rightTrophy, total: rightTotal))
			}
			break
		default:break
		}
	}
	
	//MARK: Deinit
	
	deinit {
		NotificationCenter.default.removeObserver(self)
		supportedInterfaceOrientationsForIPad = UIInterfaceOrientationMask.landscape
	}
}
