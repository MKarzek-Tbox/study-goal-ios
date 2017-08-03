//
//  ActivityDetailsVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/20/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let minNotesHeight:CGFloat = 80.0
let saveNoteHeight:CGFloat = 33.0

class ActivityDetailsVC: BaseViewController, UIAlertViewDelegate, UITextViewDelegate {
	
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var contentScroll:UIScrollView!
	@IBOutlet weak var dateLabel:UILabel!
	@IBOutlet weak var moduleLabel:UILabel!
	@IBOutlet weak var activityTypeLabel:UILabel!
	@IBOutlet weak var activityLabel:UILabel!
	@IBOutlet weak var timeSpentLabel:UILabel!
	@IBOutlet weak var noteTextView:UITextView!
	@IBOutlet weak var noteTextViewHeight:NSLayoutConstraint!
	@IBOutlet weak var scrollViewBottomSpace:NSLayoutConstraint!
	@IBOutlet weak var saveNoteButtonHeight:NSLayoutConstraint!
	var theActivity:ActivityLog
	var initialNote:String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		refresh()
	}
	
	func refresh() {
		titleLabel.text = theActivity.textForDisplay()
		dateFormatter.dateFormat = "d-MM-yyyy"
		dateLabel.text = "\(localized("date").uppercased()): \(dateFormatter.string(from: theActivity.date))"
		noteTextView.text = theActivity.note
		initialNote = theActivity.note
		if (theActivity.module != nil) {
			moduleLabel.text = theActivity.module!.name
		}
		activityTypeLabel.text = theActivity.activityType.name
		activityLabel.text = theActivity.activity.name
		let hoursSpent = theActivity.timeSpent.intValue / 60
		let minutesSpent = (theActivity.timeSpent.intValue - (hoursSpent * 60))
		let secondsSpent = theActivity.timeSpent.intValue - (hoursSpent * 60) - minutesSpent
		var timeSpent = ""
		if (hoursSpent < 10) {
			if (minutesSpent < 10) {
				if (secondsSpent < 10) {
					timeSpent = "0\(hoursSpent):0\(minutesSpent):0\(secondsSpent)"
				} else {
					timeSpent = "0\(hoursSpent):0\(minutesSpent):\(secondsSpent)"
				}
			} else {
				if (secondsSpent < 10) {
					timeSpent = "0\(hoursSpent):\(minutesSpent):0\(secondsSpent)"
				} else {
					timeSpent = "0\(hoursSpent):\(minutesSpent):\(secondsSpent)"
				}
			}
		} else {
			if (minutesSpent < 10) {
				if (secondsSpent < 10) {
					timeSpent = "\(hoursSpent):0\(minutesSpent):0\(secondsSpent)"
				} else {
					timeSpent = "\(hoursSpent):0\(minutesSpent):\(secondsSpent)"
				}
			} else {
				if (secondsSpent < 10) {
					timeSpent = "\(hoursSpent):\(minutesSpent):0\(secondsSpent)"
				} else {
					timeSpent = "\(hoursSpent):\(minutesSpent):\(secondsSpent)"
				}
			}
		}
		timeSpentLabel.text = timeSpent
	}
	
	required init(activity:ActivityLog) {
		theActivity = activity
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func editLog(_ sender:UIButton!) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_editactivitylog"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
			if (theActivity.isRunning.boolValue) {
				let vc = NewActivityVC(activity: theActivity, atIndex:dataManager.runningActivities().index(of: theActivity)!)
				navigationController?.pushViewController(vc, animated: true)
			} else {
				let vc = LogActivityVC(activity: theActivity)
				navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
	
	@IBAction func deleteLog(_ sender:UIButton!) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_deleteactivitylog"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
			UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_activity_log"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
		}
	}
	
	@IBAction func saveNote(_ sender:UIButton) {
		noteTextView.resignFirstResponder()
		theActivity.note = noteTextView.text
		dataManager.editActivityLog(theActivity, completion: { (success, failureReason) -> Void in
			if (success) {
				AlertView.showAlert(true, message: localized("saved_successfully"), completion: { (done) -> Void in
					self.initialNote = self.noteTextView.text
					UIView.animate(withDuration: 0.25, animations: { () -> Void in
						self.saveNoteButtonHeight.constant = 0.0
						self.view.layoutIfNeeded()
					})
				})
			} else {
				AlertView.showAlert(false, message: failureReason, completion: nil)
			}
		})
	}
	
	//MARK: UIAlertView Delegate
	
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		if (buttonIndex == 1) {
			if (theActivity.isRunning.boolValue) {
				dataManager.deleteObject(theActivity)
				_ = self.navigationController?.popViewController(animated: true)
			} else {
				dataManager.deleteActivityLog(theActivity) { (success, failureReason) -> Void in
					if (success) {
						dataManager.deleteObject(self.theActivity)
						_ = self.navigationController?.popViewController(animated: true)
					} else {
						AlertView.showAlert(false, message: failureReason, completion: nil)
					}
				}
			}
		}
	}
	
	//MARK: Close TextView
	
	@IBAction func closeTextView(_ sender:UIBarButtonItem) {
		noteTextView.resignFirstResponder()
	}
	
	//MARK: UITextView Delegate
	
	func textViewDidChange(_ textView: UITextView) {
		if (textView.text != initialNote && saveNoteButtonHeight.constant == 0) {
			UIView.animate(withDuration: 0.25, animations: { () -> Void in
				self.saveNoteButtonHeight.constant = saveNoteHeight
				self.view.layoutIfNeeded()
			})
		} else if (textView.text == initialNote && saveNoteButtonHeight.constant != 0) {
			UIView.animate(withDuration: 0.25, animations: { () -> Void in
				self.saveNoteButtonHeight.constant = 0.0
				self.view.layoutIfNeeded()
			})
		}
		let fixedWidth = textView.frame.size.width
		textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
		let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
		noteTextViewHeight.constant = max(minNotesHeight, newSize.height)
		view.layoutIfNeeded()
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.scrollViewBottomSpace.constant = keyboardHeight - 5.0
			self.view.layoutIfNeeded()
			}, completion: { (done) -> Void in
				let newRect = self.noteTextView.convert(self.noteTextView.frame, to: self.contentScroll)
				self.contentScroll.setContentOffset(CGPoint(x: 0.0, y: newRect.origin.y - 60), animated: true)
		}) 
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.scrollViewBottomSpace.constant = 0.0
			self.view.layoutIfNeeded()
		}) 
	}
}
