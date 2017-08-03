//
//  OneActivityCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/16/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kOneActivityCellNibName = "OneActivityCell"
let kOneActivityCellIdentifier = "OneActivityCellIdentifier"
let kAnotherActivityCellOpenedOptions = "kAnotherActivityCellOpenedOptions"
let kChangeActivityCellSelectedStyleOn = "kChangeActivityCellSelectedStyleOn"
let kChangeActivityCellSelectedStyleOff = "kChangeActivityCellSelectedStyleOff"

enum kOptionsState {
	case open
	case closed
}

class OneActivityCell: UITableViewCell, UIAlertViewDelegate {
	
	@IBOutlet weak var activityTypeIcon:UIImageView!
	@IBOutlet weak var activityTextLabel:UILabel!
	var panStartPoint:CGPoint = CGPoint.zero
	@IBOutlet weak var contentTrailingConstraint:NSLayoutConstraint!
	@IBOutlet weak var optionsButtonsView:UIView!
	var optionsState:kOptionsState = .closed
	var theActivity:ActivityLog?
	weak var tableView:UITableView?
	weak var navigationController:UINavigationController?
	weak var parent:LogVC?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(OneActivityCell.panAction(_:)))
		panGesture.delegate = self
		self.addGestureRecognizer(panGesture)
		NotificationCenter.default.addObserver(self, selector: #selector(OneActivityCell.anotherCellOpenedOptions(_:)), name: NSNotification.Name(rawValue: kAnotherActivityCellOpenedOptions), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(OneActivityCell.changeSelectedStyleOn), name: NSNotification.Name(rawValue: kChangeActivityCellSelectedStyleOn), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(OneActivityCell.changeSelectedStyleOff), name: NSNotification.Name(rawValue: kChangeActivityCellSelectedStyleOff), object: nil)
	}
	
	func anotherCellOpenedOptions(_ notification:Notification) {
		let senderCell = notification.object as? OneActivityCell
		if (senderCell != nil) {
			if (self != senderCell!) {
				closeCellOptions()
			}
		}
	}
	
	func changeSelectedStyleOn() {
		selectionStyle = .gray
	}
	
	func changeSelectedStyleOff() {
		selectionStyle = .none
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		if (selected) {
			setSelected(false, animated: animated)
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		theActivity = nil
		activityTypeIcon.image = nil
		activityTextLabel.text = ""
		navigationController = nil
		tableView = nil
		closeCellOptions()
	}
	
	func loadActivity(_ activity:ActivityLog, navigationController:UINavigationController?, tableView:UITableView?) {
		theActivity = activity
		let imageName = activity.activity.iconName(big: true)
		activityTypeIcon.image = UIImage(named: imageName)
		activityTextLabel.text = activity.textForDisplay()
		if (activity.isRunning.boolValue) {
			activityTextLabel.textColor = orangeTargetColor
		} else {
			activityTextLabel.textColor = lilacColor
		}
		self.navigationController = navigationController
		self.tableView = tableView
		layoutIfNeeded()
	}
	
	@IBAction func deleteActivity(_ sender:UIButton) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_deleteactivitylog"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			parent?.navigationController?.present(alert, animated: true, completion: nil)
		} else {
			UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_activity_log"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
		}
	}
	
	@IBAction func editActivity(_ sender:UIButton) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_editactivitylog"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			parent?.navigationController?.present(alert, animated: true, completion: nil)
		} else {
			closeCellOptions()
			if (theActivity != nil) {
				if (theActivity!.isRunning.boolValue) {
					let vc = NewActivityVC(activity: theActivity!, atIndex:dataManager.runningActivities().index(of: theActivity!)!)
					navigationController?.pushViewController(vc, animated: true)
				} else {
					let vc = LogActivityVC(activity: theActivity!)
					navigationController?.pushViewController(vc, animated: true)
				}
			}
		}
	}
	
	//MARK: UIGestureRecognizer Delegate
	
	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		var shouldBegin = true
		let panGesture = gestureRecognizer as? UIPanGestureRecognizer
		if (panGesture != nil) {
			let horizontalVelocity = abs(panGesture!.velocity(in: self).x)
			let verticalVelocity = abs(panGesture!.velocity(in: self).y)
			if (verticalVelocity > horizontalVelocity) {
				shouldBegin = false
			}
		}
		return shouldBegin
	}
	
	func panAction(_ sender:UIPanGestureRecognizer) {
		switch (sender.state) {
		case .began:
			panStartPoint = sender.location(in: self)
			optionsButtonsView.alpha = 1.0
		case .ended:
			let velocity = sender.velocity(in: self).x
			if (velocity < 0) {
				openCellOptions()
			} else {
				closeCellOptions()
			}
		case .changed:
			let currentPoint = sender.location(in: self)
			var difference = panStartPoint.x - currentPoint.x
			if (optionsState == .open) {
				difference += kButtonsWidth
			}
			if (difference < 0.0) {
				difference = 0.0
			} else if (difference > kButtonsWidth) {
				difference = kButtonsWidth
			}
			contentTrailingConstraint.constant = difference
			layoutIfNeeded()
		default:break
		}
	}
	
	func openCellOptions() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kAnotherActivityCellOpenedOptions), object: self)
		optionsState = .open
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.contentTrailingConstraint.constant = kButtonsWidth
			self.layoutIfNeeded()
			}, completion: { (done) -> Void in
				NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeActivityCellSelectedStyleOff), object: nil)
				self.parent?.aCellIsOpen = true
		}) 
	}
	
	func closeCellOptions() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeActivityCellSelectedStyleOn), object: nil)
		parent?.aCellIsOpen = false
		optionsState = .closed
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.contentTrailingConstraint.constant = 0.0
			self.layoutIfNeeded()
			self.optionsButtonsView.alpha = 0.0
		}) 
	}
	
	//MARK: UIAlertView Delegate
	
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		closeCellOptions()
		if (buttonIndex == 1) {
			if (theActivity != nil) {
				if (theActivity!.isRunning.boolValue) {
					dataManager.deleteObject(theActivity!)
					parent?.refreshActivityLogs()
				} else {
					dataManager.deleteActivityLog(theActivity!) { (success, failureReason) -> Void in
						if (success) {
							dataManager.deleteObject(self.theActivity!)
							self.parent?.refreshActivityLogs()
						} else {
							AlertView.showAlert(false, message: failureReason, completion: nil)
						}
					}
				}
			}
		}
	}
}
