//
//  OneFriendCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/22/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kOneFriendCellNibName = "OneFriendCell"
let kOneFriendCellIdentifier = "OneFriendCellIdentifier"

class OneFriendCell: LocalizableCell, UIAlertViewDelegate {
	
	@IBOutlet weak var friendNameLabel:UILabel!
	@IBOutlet weak var hideFriendButton:UIButton!
	var theFriend:Friend?
	weak var tableView:UITableView?
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	func loadFriend(_ friend:Friend) {
		theFriend = friend
		friendNameLabel.text = "\(friend.firstName) \(friend.lastName)"
		hideFriendButton.isSelected = friend.hidden.boolValue
	}
	
	@IBAction func hideFriend(_ sender:UIButton) {
		if (theFriend != nil) {
			if (sender.isSelected) {
				DownloadManager().unhideFriend(dataManager.currentStudent!.id, friendToUnhideID: theFriend!.id, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					sender.isSelected = !sender.isSelected
					dataManager.getStudentFriendsData { (success, failureReason) -> Void in
						self.tableView?.reloadData()
					}
					if (success) {
						if (result != nil) {
							let message = result!["message"] as? String
							if (message != nil) {
								AlertView.showAlert(true, message: message!, completion: nil)
							}
						}
					}
				})
			} else {
				DownloadManager().hideFriend(dataManager.currentStudent!.id, friendToHideID: theFriend!.id, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					sender.isSelected = !sender.isSelected
					dataManager.getStudentFriendsData { (success, failureReason) -> Void in
						self.tableView?.reloadData()
					}
					if (success) {
						if (result != nil) {
							let message = result!["message"] as? String
							if (message != nil) {
								AlertView.showAlert(true, message: message!, completion: nil)
							}
						}
					}
				})
			}
		}
	}
	
	@IBAction func deleteFriend(_ sender:UIButton) {
		UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_friend"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
	}
	
	//MARK: UIAlertView Delegate
	
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		if (buttonIndex == 1) {
			if (theFriend != nil) {
				DownloadManager().deleteFriend(dataManager.currentStudent!.id, friendToDeleteID: theFriend!.id, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
					dataManager.getStudentFriendsData { (success, failureReason) -> Void in
						self.tableView?.reloadData()
						AlertView.showAlert(true, message: localized("friend_deleted_successfully"), completion: nil)
					}
				})
			}
		}
	}
}
