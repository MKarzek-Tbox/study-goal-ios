//
//  SearchVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/26/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

let defaultPrivacyTitleFontSize:CGFloat = 19.0

enum kCurrentAction {
	case sendFriendRequest
	case changeFriendSettings
	case acceptFriendRequest
	case deleteFriendRequest
	case hideFriend
	case unhideFriend
	case deleteFriend
}

class SearchVC: BaseViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate {
	
	@IBOutlet weak var searchButton:UIButton!
	@IBOutlet weak var newRequestsButton:UIButton!
	@IBOutlet weak var myFriendsButton:UIButton!
	@IBOutlet weak var searchView:UIView!
	@IBOutlet weak var searchStudentsResultsTable:UITableView!
	@IBOutlet weak var searchStudentsInputTextField:UITextField!
	@IBOutlet weak var searchFriendsInputTextField:UITextField!
	@IBOutlet var privacyView:UIView!
	@IBOutlet weak var privacyTextLabel:UILabel!
	@IBOutlet weak var privacyTitleLabel:UILabel!
	@IBOutlet weak var everythingSwitch:UISwitch!
	@IBOutlet weak var myResultSwitch:UISwitch!
	@IBOutlet weak var courseEngagementSwitch:UISwitch!
	@IBOutlet weak var activityLogSwitch:UISwitch!
	@IBOutlet weak var privacyActionButton:UIButton!
	@IBOutlet weak var newRequestsView:UIView!
	@IBOutlet weak var newRequestsTable:UITableView!
	@IBOutlet weak var myFriendsView:UIView!
	@IBOutlet weak var myFriendsTable:UITableView!
	var filteredStudents:[Colleague] = [Colleague]()
	var colleagueToTakeActionWith:Colleague?
	var friendRequestToTakeActionWith:FriendRequest?
	var filteredFriends:[Friend] = [Friend]()
	var friendToTakeActionWith:Friend?
	var currentAction:kCurrentAction = .sendFriendRequest
	var studentToInviteEmail = ""
	@IBOutlet weak var noRequestsMessage:UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		searchStudentsResultsTable.register(UINib(nibName: kFoundStudentCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kFoundStudentCellIdentifier)
		newRequestsTable.register(UINib(nibName: kNewRequestCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kNewRequestCellIdentifier)
		myFriendsTable.register(UINib(nibName: kMyFriendCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kMyFriendCellIdentifier)
		refreshData()
		searchStudentsInputTextField.placeholder = localized("search_by_email")
	}
	
	func refreshData() {
		searchStudentsInputTextField.text = ""
		searchStudentsInputTextField.resignFirstResponder()
		searchFriendsInputTextField.text = ""
		searchFriendsInputTextField.resignFirstResponder()
		dataManager.getStudentFriendsData { (success, failureReason) -> Void in
			self.filterStudents("")
			self.refreshRequests()
			self.filterFriends("")
		}
	}
	
	func refreshRequests() {
		if dataManager.friendRequests().count == 0 {
			noRequestsMessage.alpha = 1.0
			newRequestsTable.alpha = 0.0
		} else {
			noRequestsMessage.alpha = 0.0
			newRequestsTable.alpha = 1.0
		}
		newRequestsTable.reloadData()
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		//_ = navigationController?.popViewController(animated: true)
        DELEGATE.menuView?.open()

	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func search(_ sender:UIButton) {
		view.endEditing(true)
		searchButton.isSelected = true
		newRequestsButton.isSelected = false
		myFriendsButton.isSelected = false
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.searchView.alpha = 1.0
			self.newRequestsView.alpha = 0.0
			self.myFriendsView.alpha = 0.0
		}) 
	}
	
	@IBAction func newRequests(_ sender:UIButton) {
		view.endEditing(true)
		searchButton.isSelected = false
		newRequestsButton.isSelected = true
		myFriendsButton.isSelected = false
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.searchView.alpha = 0.0
			self.newRequestsView.alpha = 1.0
			self.myFriendsView.alpha = 0.0
		}) 
	}
	
	@IBAction func myFriends(_ sender:UIButton) {
		view.endEditing(true)
		searchButton.isSelected = false
		newRequestsButton.isSelected = false
		myFriendsButton.isSelected = true
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.searchView.alpha = 0.0
			self.newRequestsView.alpha = 0.0
			self.myFriendsView.alpha = 1.0
		}) 
	}
	
	func filterStudents(_ string:String) {
		let fetchRequest:NSFetchRequest<Colleague> = NSFetchRequest(entityName: colleagueEntityName)
		fetchRequest.predicate = NSPredicate(format: "inTheSameCourseWith.id == %@ AND (firstName contains[c] %@ OR lastName contains[c] %@)", dataManager.currentStudent!.id, string, string)
		if (string.isEmpty) {
			fetchRequest.predicate = NSPredicate(format: "inTheSameCourseWith.id == %@", dataManager.currentStudent!.id)
		}
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
		do {
			try filteredStudents = managedContext.fetch(fetchRequest)
		} catch let error as NSError {
			print("filter students failed. Error: \(error.localizedDescription)")
		}
		searchStudentsResultsTable.reloadData()
	}
	
	func filterFriends(_ string:String) {
		let fetchRequest:NSFetchRequest<Friend> = NSFetchRequest(entityName: friendEntityName)
		fetchRequest.predicate = NSPredicate(format: "friendOf.id == %@ AND (firstName contains[c] %@ OR lastName contains[c] %@)", dataManager.currentStudent!.id, string, string)
		if (string.isEmpty) {
			fetchRequest.predicate = NSPredicate(format: "friendOf.id == %@", dataManager.currentStudent!.id)
		}
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
		do {
			try filteredFriends = managedContext.fetch(fetchRequest)
		} catch let error as NSError {
			print("filter students failed. Error: \(error.localizedDescription)")
		}
		myFriendsTable.reloadData()
	}
	
	func sendFriendRequestToColleague(_ colleague:Colleague) {
		privacyView.alpha = 0.0
		privacyTitleLabel.text = localized("friend_request")
		searchView.addSubview(privacyView)
		privacyActionButton.setTitle(localized("send"), for: UIControlState())
		addMarginConstraintsWithView(privacyView, toSuperView: searchView)
		colleagueToTakeActionWith = colleague
		currentAction = .sendFriendRequest
		let fullName = "\(colleague.firstName) \(colleague.lastName)"
		if fullName == " " {
			privacyTextLabel.text = localized("what_would_you_like_your_friend_to_see")
		} else {
			privacyTextLabel.text = localizedWith1Parameter("what_would_you_like_student_to_see", parameter: fullName)
		}
		var height = heightForText(privacyTextLabel.text, font: privacyTextLabel.font, width: privacyTextLabel.frame.size.width, caresAboutWords: false)
		repeat {
			privacyTextLabel.font = privacyTextLabel.font.withSize(privacyTextLabel.font.pointSize - 1)
			height = heightForText(privacyTextLabel.text, font: privacyTextLabel.font, width: privacyTextLabel.frame.size.width, caresAboutWords: false)
		} while (height > privacyTextLabel.frame.size.height)
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.privacyView.alpha = 1.0
		}) 
	}
	
	func acceptThisFriendRequest(_ friendRequest:FriendRequest) {
		privacyView.alpha = 0.0
		privacyTitleLabel.text = localized("friend_request")
		newRequestsView.addSubview(privacyView)
		privacyActionButton.setTitle(localized("confirm"), for: UIControlState())
		addMarginConstraintsWithView(privacyView, toSuperView: newRequestsView)
		friendRequestToTakeActionWith = friendRequest
		currentAction = .acceptFriendRequest
		let fullName = "\(friendRequest.firstName) \(friendRequest.lastName)"
		if fullName == " " {
			privacyTextLabel.text = localized("what_would_you_like_your_friend_to_see")
		} else {
			privacyTextLabel.text = localizedWith1Parameter("what_would_you_like_student_to_see", parameter: fullName)
		}
		var height = heightForText(privacyTextLabel.text, font: privacyTextLabel.font, width: privacyTextLabel.frame.size.width, caresAboutWords: false)
		repeat {
			privacyTextLabel.font = privacyTextLabel.font.withSize(privacyTextLabel.font.pointSize - 1)
			height = heightForText(privacyTextLabel.text, font: privacyTextLabel.font, width: privacyTextLabel.frame.size.width, caresAboutWords: false)
		} while (height > privacyTextLabel.frame.size.height)
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.privacyView.alpha = 1.0
		}) 
	}
	
	func cancelPendingFriendRequestToColleague(_ colleague:Colleague) {
		colleagueToTakeActionWith = colleague
		let myID = dataManager.currentStudent!.id
		let studentID = colleagueToTakeActionWith!.id
		DownloadManager().cancelPendingFriendRequest(myID, friendID: studentID, alertAboutInternet: true) { (success, result, results, error) -> Void in
			self.refreshData()
		}
	}
	
	@IBAction func toggleSeeEverything(_ sender:UISwitch) {
		everythingSwitch.setOn(sender.isOn, animated: true)
		myResultSwitch.setOn(sender.isOn, animated: true)
		courseEngagementSwitch.setOn(sender.isOn, animated: true)
		activityLogSwitch.setOn(sender.isOn, animated: true)
	}
	
	@IBAction func toggleSeeMyResults(_ sender:UISwitch) {
		if (sender.isOn) {
			if (myResultSwitch.isOn && courseEngagementSwitch.isOn && activityLogSwitch.isOn) {
				everythingSwitch.setOn(true, animated: true)
			}
		} else {
			everythingSwitch.setOn(false, animated: true)
		}
	}
	
	@IBAction func toggleSeeCourseEngagement(_ sender:UISwitch) {
		if (sender.isOn) {
			if (myResultSwitch.isOn && courseEngagementSwitch.isOn && activityLogSwitch.isOn) {
				everythingSwitch.setOn(true, animated: true)
			}
		} else {
			everythingSwitch.setOn(false, animated: true)
		}
	}
	
	@IBAction func toggleSeeActivityLog(_ sender:UISwitch) {
		if (sender.isOn) {
			if (myResultSwitch.isOn && courseEngagementSwitch.isOn && activityLogSwitch.isOn) {
				everythingSwitch.setOn(true, animated: true)
			}
		} else {
			everythingSwitch.setOn(false, animated: true)
		}
	}
	
	@IBAction func sendOrAcceptRequest(_ sender:UIButton) {
		if (currentAction == .sendFriendRequest) {
			sendFriendRequest({ (success, result, results, error) -> Void in
				self.refreshData()
				AlertView.showAlert(true, message: localized("request_sent_successfully"), completion: nil)
			})
		} else if (currentAction == .acceptFriendRequest) {
			acceptFriendRequest({ (success, result, results, error) -> Void in
				self.refreshData()
			})
		} else if (currentAction == .changeFriendSettings) {
			changeFriendSettings({ (success, result, results, error) -> Void in
				self.refreshData()
			})
		}
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.privacyView.alpha = 0.0
		}, completion: { (done) -> Void in
			self.privacyTextLabel.font = self.privacyTextLabel.font.withSize(defaultPrivacyTitleFontSize)
		}) 
	}
	
	@IBAction func cancelFriendRequest(_ sender:UIButton) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.privacyView.alpha = 0.0
			}, completion: { (done) -> Void in
				self.privacyTextLabel.font = self.privacyTextLabel.font.withSize(defaultPrivacyTitleFontSize)
		}) 
	}
	
	//MARK: Actions With Other Students
	
	func sendFriendRequest(_ completion:@escaping downloadCompletionBlock) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_sendfriendrequest"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
			if (colleagueToTakeActionWith != nil) {
				let privacy = FriendRequestPrivacyOptions(results: myResultSwitch.isOn, engagement: courseEngagementSwitch.isOn, activity: activityLogSwitch.isOn)
				let myID = dataManager.currentStudent!.id
				let studentID = colleagueToTakeActionWith!.id
				DownloadManager().sendFriendRequest(myID, to: studentID, privacy: privacy, alertAboutInternet: true, completion: completion)
			}
		}
	}
	
	func acceptFriendRequest(_ completion:@escaping downloadCompletionBlock) {
		if (friendRequestToTakeActionWith != nil) {
			let privacy = FriendRequestPrivacyOptions(results: myResultSwitch.isOn, engagement: courseEngagementSwitch.isOn, activity: activityLogSwitch.isOn)
			let myID = dataManager.currentStudent!.id
			let studentID = friendRequestToTakeActionWith!.id
			DownloadManager().acceptFriendRequest(studentID, to: myID, privacy: privacy, alertAboutInternet: true, completion: completion)
		}
	}
	
	func changeFriendSettings(_ completion:@escaping downloadCompletionBlock) {
		if (friendToTakeActionWith != nil) {
			let privacy = FriendRequestPrivacyOptions(results: myResultSwitch.isOn, engagement: courseEngagementSwitch.isOn, activity: activityLogSwitch.isOn)
			let myID = dataManager.currentStudent!.id
			let studentID = friendToTakeActionWith!.id
			DownloadManager().changeFriendSettings(myID, friendID: studentID, privacy: privacy, alertAboutInternet: true, completion: completion)
		}
	}
	
	func deleteFriendRequest(_ completion:@escaping downloadCompletionBlock) {
		if (friendRequestToTakeActionWith != nil) {
			let myID = dataManager.currentStudent!.id
			let studentID = friendRequestToTakeActionWith!.id
			DownloadManager().deleteFriendRequest(studentID, to: myID, alertAboutInternet: true, completion: completion)
		}
	}
	
	func hideFriend(_ completion:@escaping downloadCompletionBlock) {
		if (friendToTakeActionWith != nil) {
			let myID = dataManager.currentStudent!.id
			let studentID = friendToTakeActionWith!.id
			DownloadManager().hideFriend(myID, friendToHideID: studentID, alertAboutInternet: true, completion: completion)
		}
	}
	
	func unhideFriend(_ completion:@escaping downloadCompletionBlock) {
		if (friendToTakeActionWith != nil) {
			let myID = dataManager.currentStudent!.id
			let studentID = friendToTakeActionWith!.id
			DownloadManager().unhideFriend(myID, friendToUnhideID: studentID, alertAboutInternet: true, completion: completion)
		}
	}
	
	func deleteFriend(_ completion:@escaping downloadCompletionBlock) {
		if (friendToTakeActionWith != nil) {
			let myID = dataManager.currentStudent!.id
			let studentID = friendToTakeActionWith!.id
			DownloadManager().deleteFriend(myID, friendToDeleteID: studentID, alertAboutInternet: true, completion: completion)
		}
	}
	
	//MARK: UIAlertView Delegate
	
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		if (buttonIndex == 1) {
			if (MFMailComposeViewController.canSendMail()) {
				let vc = MFMailComposeViewController()
				vc.mailComposeDelegate = self
				vc.setToRecipients([studentToInviteEmail])
				vc.setMessageBody("You have been invited to join the Jisc student app", isHTML: false)
				navigationController?.present(vc, animated: true, completion: nil)
			} else {
				let message = "Go to your device's settings and log in with an e-mail account to be able to use this functionality"
				UIAlertView(title: "Not available", message: message, delegate: nil, cancelButtonTitle: "Ok").show()
			}
		}
	}
	
	//MARK: MFMailComposeViewController Delegate
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		switch (result) {
		case MFMailComposeResult.cancelled:
			break
		case MFMailComposeResult.failed:
			break
		case MFMailComposeResult.saved:
			break
		case MFMailComposeResult.sent:
			break
		}
		controller.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func sendFriendRequestAnyway(_ sender:UIButton) {
		if let text = searchStudentsInputTextField.text {
			if (isValidEmail(text)) {
				if let student = filteredStudents.first {
					sendFriendRequestToColleague(student)
				} else {
					DownloadManager().sendFriendRequestToEmail(dataManager.currentStudent!.id, email: text, alertAboutInternet: false, completion: { (success, result, results, error) in
						UIAlertView(title: "", message: localized("friend_request_sent_successfully"), delegate: nil, cancelButtonTitle: localized("ok")).show()
					})
				}
			} else {
				UIAlertView(title: localized("error"), message: localized("please_search_for_friends_using_their_institution_email_address"), delegate: nil, cancelButtonTitle: localized("ok")).show()
			}
		}
	}
	
	//MARK: UITextField Delegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		if (textField.text != nil) {
			if (textField == searchStudentsInputTextField) {
				if (isValidEmail(textField.text!)) {
					DownloadManager().searchStudentByEmail(dataManager.currentStudent!.id, email: textField.text!, alertAboutInternet: false, completion: { (success, result, results, error) -> Void in
						self.filteredStudents.removeAll()
						if (success) {
							if (results != nil) {
								let dictionary = results!.firstObject as? NSDictionary
								if (dictionary != nil) {
									let object = Colleague.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
									self.filteredStudents = [object]
								} else {
									self.studentToInviteEmail = textField.text!
									let message = localized("no_user_with_this_email")
									UIAlertView(title: localized("not_found"), message: message, delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
								}
							} else {
								self.studentToInviteEmail = textField.text!
								let message = localized("no_user_with_this_email")
								UIAlertView(title: localized("not_found"), message: message, delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
							}
						} else {
							self.studentToInviteEmail = textField.text!
							let message = localized("no_user_with_this_email")
							UIAlertView(title: localized("not_found"), message: message, delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
						}
						self.searchStudentsResultsTable.reloadData()
					})
				} else {
					
				}
			}
		}
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if (textField == searchStudentsInputTextField) {
			if (textField.text != nil) {
				let textFieldText:NSString = NSString(string: textField.text!)
				let resultingText = textFieldText.replacingCharacters(in: range, with: string)
				let returnKeyType = textField.returnKeyType
				if (isValidEmail(resultingText)) {
					textField.returnKeyType = .search
				} else {
					textField.returnKeyType = .done
					filterStudents(resultingText)
				}
				if (returnKeyType != textField.returnKeyType) {
					textField.resignFirstResponder()
					textField.becomeFirstResponder()
				}
			}
		} else if (textField == searchFriendsInputTextField) {
			if (textField.text != nil) {
				let textFieldText:NSString = NSString(string: textField.text!)
				let resultingText = textFieldText.replacingCharacters(in: range, with: string)
				filterFriends(resultingText)
			}
		}
		return true
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var nrRows = 0
		switch (tableView) {
		case searchStudentsResultsTable:
			nrRows = filteredStudents.count
		case newRequestsTable:
			nrRows = dataManager.friendRequests().count
		case myFriendsTable:
			nrRows = filteredFriends.count
		default:break
		}
		return nrRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cellIdentifier = ""
		switch (tableView) {
		case searchStudentsResultsTable:
			cellIdentifier = kFoundStudentCellIdentifier
		case newRequestsTable:
			cellIdentifier = kNewRequestCellIdentifier
		case myFriendsTable:
			cellIdentifier = kMyFriendCellIdentifier
		default:break
		}
		var theCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var height:CGFloat = 82.0
		if (screenWidth == .small) {
			height = 102.0
		}
		return height
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch (tableView) {
		case searchStudentsResultsTable:
			let theCell:FoundStudentCell? = cell as? FoundStudentCell
			if (theCell != nil) {
				theCell!.parent = self
				var status:FriendshipStatus = .notFriends
				let colleague = filteredStudents[indexPath.row]
				let fetchRequest:NSFetchRequest<FriendRequest> = NSFetchRequest(entityName: friendRequestEntityName)
				fetchRequest.predicate = NSPredicate(format: "id == %@", colleague.id)
				do {
					let request = try managedContext.fetch(fetchRequest).first
					if (request != nil) {
						status = .receivedRequest
					}
				} catch let error as NSError {
					print("get friend request for colleagues table failed: \(error.localizedDescription)")
				}
				if (status == .notFriends) {
					let fetchRequest:NSFetchRequest<Friend> = NSFetchRequest(entityName: friendEntityName)
					fetchRequest.predicate = NSPredicate(format: "id == %@", colleague.id)
					do {
						let friend = try managedContext.fetch(fetchRequest).first
						if (friend != nil) {
							status = .friends
						}
					} catch let error as NSError {
						print("get friend for colleagues table failed: \(error.localizedDescription)")
					}
				}
				if (status == .notFriends) {
					let fetchRequest:NSFetchRequest<SentFriendRequest> = NSFetchRequest(entityName: sentFriendRequestEntityName)
					fetchRequest.predicate = NSPredicate(format: "id == %@", colleague.id)
					do {
						let request = try managedContext.fetch(fetchRequest).first
						if (request != nil) {
							status = .pendingRequest
						}
					} catch let error as NSError {
						print("get sent friend request for colleagues table failed: \(error.localizedDescription)")
					}
				}
				theCell!.loadColleague(colleague, status: status)
			}
		case newRequestsTable:
			let theCell:NewRequestCell? = cell as? NewRequestCell
			if (theCell != nil) {
				theCell!.parent = self
				theCell!.loadFriendRequest(dataManager.friendRequests()[indexPath.row])
			}
		case myFriendsTable:
			let theCell:MyFriendCell? = cell as? MyFriendCell
			if (theCell != nil) {
				theCell!.parent = self
				theCell!.loadFriend(filteredFriends[indexPath.row])
			}
		default:break
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch (tableView) {
		case myFriendsTable:
			myResultSwitch.isOn = true
			courseEngagementSwitch.isOn = true
			activityLogSwitch.isOn = true
			everythingSwitch.isOn = true
			privacyView.alpha = 0.0
			privacyTitleLabel.text = localized("friend_privacy_settings")
			myFriendsView.addSubview(privacyView)
			privacyActionButton.setTitle(localized("save"), for: UIControlState())
			addMarginConstraintsWithView(privacyView, toSuperView: myFriendsView)
			let friend = filteredFriends[indexPath.row]
			friendToTakeActionWith = friend
			currentAction = .changeFriendSettings
			let fullName = "\(friend.firstName) \(friend.lastName)"
			if fullName == " " {
				privacyTextLabel.text = localized("what_would_you_like_your_friend_to_see")
			} else {
				privacyTextLabel.text = localizedWith1Parameter("what_would_you_like_student_to_see", parameter: fullName)
			}
			var height = heightForText(privacyTextLabel.text, font: privacyTextLabel.font, width: privacyTextLabel.frame.size.width, caresAboutWords: false)
			repeat {
				privacyTextLabel.font = privacyTextLabel.font.withSize(privacyTextLabel.font.pointSize - 1)
				height = heightForText(privacyTextLabel.text, font: privacyTextLabel.font, width: privacyTextLabel.frame.size.width, caresAboutWords: false)
			} while (height > privacyTextLabel.frame.size.height)
			UIView.animate(withDuration: 0.25, animations: { () -> Void in
				self.privacyView.alpha = 1.0
			}) 
			break
		default:break
		}
	}
}
