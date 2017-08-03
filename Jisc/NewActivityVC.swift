//
//  NewActivityVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/15/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

class NewActivityVC: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, CustomPickerViewDelegate, UITextFieldDelegate {
	
	@IBOutlet weak var titleLabel:UILabel!
	var reminderMinutes:Int = 1
	var countDownValue:Int = 0
	@IBOutlet weak var chooseActivityLabel:UILabel!
	@IBOutlet weak var reminderTimeLabel:UILabel!
	@IBOutlet weak var reminderTimePicker:UIPickerView!
	@IBOutlet weak var closeReminderTimePickerButton:UIButton!
	@IBOutlet weak var reminderTimePickerBottomSpace:NSLayoutConstraint!
	var timeActivityTimer:Timer?
	@IBOutlet weak var startActivityButton:UIButton!
	@IBOutlet weak var stopActivityButton:UIButton!
	@IBOutlet weak var spentTimeLabel:UILabel!
	var theActivity:ActivityLog?
	var index:Int = 0
	var shouldSave:Bool = false
	var selectedModule:Int = 0
	var selectedActivityType:Int = 0
	var selectedActivity:Int = 0
	@IBOutlet weak var moduleButton:UIButton!
	@IBOutlet weak var activityTypeButton:UIButton!
	@IBOutlet weak var chooseActivityButton:UIButton!
	var moduleSelectorView:CustomPickerView = CustomPickerView()
	var activityTypeSelectorView:CustomPickerView = CustomPickerView()
	var activitySelectorView:CustomPickerView = CustomPickerView()
	@IBOutlet weak var parametersView:UIView!
	@IBOutlet weak var addModuleView:UIView!
	@IBOutlet weak var addModuleTextField:UITextField!
	
	init(activity:ActivityLog, atIndex:Int) {
		theActivity = activity
		super.init(nibName: nil, bundle: nil)
	}
	
	init(module:Int, activityType:Int, activity:Int) {
		selectedModule = module
		selectedActivityType = activityType
		selectedActivity = activity
		super.init(nibName: nil, bundle: nil)
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if (theActivity != nil) {
			titleLabel.text = localized("edit_activity")
			if (theActivity!.isRunning.boolValue) {
				parametersView.alpha = 0.5
				parametersView.isUserInteractionEnabled = false
				if (theActivity!.isPaused.boolValue) {
					let pauseInterval = Date().timeIntervalSince(theActivity!.pauseDate as Date)
					theActivity!.date = theActivity!.date.addingTimeInterval(pauseInterval)
					theActivity!.pauseDate = Date()
					startActivityButton.setTitle(localized("resume"), for: UIControlState())
					dataManager.safelySaveContext()
				} else {
					startActivityButton.setTitle(localized("pause"), for: UIControlState())
				}
				stopActivityButton.isEnabled = true
			}
			if (theActivity!.module != nil) {
				selectedModule = dataManager.indexOfModuleWithID(theActivity!.module!.id)!
			}
			selectedActivityType = dataManager.indexOfActivityType(theActivity!.activityType)!
			selectedActivity = dataManager.indexOfActivityWithName(theActivity!.activity.englishName, type: theActivity!.activityType)!
			
			let notificationTime = getLocalNotificationTime(theActivity!.id)
			if (notificationTime != nil) {
				reminderMinutes = Int(notificationTime! / 60.0)
				var title = "\(reminderMinutes):00"
				if (reminderMinutes < 10) {
					title = "0\(reminderMinutes):00"
				}
				reminderTimeLabel.text = title
				if (reminderMinutes > 0) {
					reminderTimePicker.selectRow(reminderMinutes - 1, inComponent: 0, animated: false)
				}
			}
		} else {
			theActivity = ActivityLog.insertInManagedObjectContext(managedContext, dictionary: NSDictionary())
			theActivity!.student = dataManager.currentStudent!
			if (selectedModule < dataManager.modules().count) {
				theActivity!.module = dataManager.modules()[selectedModule]
			}
			theActivity!.activityType = dataManager.activityTypes()[selectedActivityType]
			theActivity!.activity = dataManager.activityAtIndex(selectedActivity, type: theActivity!.activityType)!
			theActivity!.date = Date(timeIntervalSinceNow: 0)
			theActivity!.timeSpent = 0
			theActivity!.note = ""
			theActivity!.isRunning = false
			theActivity!.isPaused = false
			theActivity!.pauseDate = Date(timeIntervalSince1970: 0)
			theActivity!.id = uniqueID()
			dataManager.currentStudent!.addActivityLog(theActivity!)
		}
		moduleButton.setTitle(dataManager.moduleNameAtIndex(selectedModule), for: UIControlState())
		activityTypeButton.setTitle(dataManager.activityTypeNameAtIndex(selectedActivityType), for: UIControlState())
		chooseActivityButton.setTitle(dataManager.activityAtIndex(selectedActivity, type: theActivity!.activityType)?.name, for: UIControlState())
		chooseActivityLabel.adjustsFontSizeToFitWidth = true
		updateSpentTimeLabel()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		timeActivityTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(NewActivityVC.updateTimeLabel(_:)), userInfo: nil, repeats: true)
		RunLoop.current.add(timeActivityTimer!, forMode: RunLoopMode.commonModes)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		timeActivityTimer?.invalidate()
		if (DELEGATE.menuView?.selectedIndex != 2) {
			navigationController?.popViewController(animated: true)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if (!shouldSave) {
			managedContext.rollback()
			if (theActivity != nil && !theActivity!.isRunning.boolValue) {
				managedContext.delete(theActivity!)
				dataManager.safelySaveContext()
			}
		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		timeActivityTimer?.invalidate()
		navigationController?.popViewController(animated: true)
		
		
	}
	
	func addModule() {
		addModuleTextField.becomeFirstResponder()
		UIView.animate(withDuration: 0.25) {
			self.addModuleView.alpha = 1.0
		}
	}
	
	@IBAction func closeAddModule(_ sender:UIButton?) {
		addModuleTextField.text = ""
		addModuleTextField.resignFirstResponder()
		UIView.animate(withDuration: 0.25) {
			self.addModuleView.alpha = 0.0
		}
	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func changeReminderTime(_ sender:UIButton) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.closeReminderTimePickerButton.alpha = 1.0
			self.reminderTimePickerBottomSpace.constant = 0.0
			self.view.layoutIfNeeded()
		})
	}
	
	@IBAction func closeReminderTimePicker(_ sender:UIButton) {
		animateReminderTimePickerClosing()
	}
	
	@IBAction func closeDatePickerFromToolbar(_ sender:UIBarButtonItem) {
		animateReminderTimePickerClosing()
	}
	
	func animateReminderTimePickerClosing() {
		reminderTimePicker.selectRow(reminderMinutes - 1, inComponent: 0, animated: false)
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.closeReminderTimePickerButton.alpha = 0.0
			self.reminderTimePickerBottomSpace.constant = -260.0
			self.view.layoutIfNeeded()
		})
	}
	
	//MARK: Show/Close Selectors
	
	@IBAction func showModuleSelector(_ sender:UIButton) {
		if social() {
			if dataManager.modules().count == 1 {
				addModule()
			} else {
				var array:[String] = [String]()
				for (_, item) in dataManager.modules().enumerated() {
					array.append(item.name)
				}
				moduleSelectorView = CustomPickerView.create(localized("choose_module"), delegate: self, contentArray: array, selectedItem: selectedModule)
				view.addSubview(moduleSelectorView)
			}
		} else {
			if (!dataManager.currentStudent!.institution.isLearningAnalytics.boolValue) {
				return
			}
			var array:[String] = [String]()
			for (_, item) in dataManager.modules().enumerated() {
				array.append(item.name)
			}
			moduleSelectorView = CustomPickerView.create(localized("choose_module"), delegate: self, contentArray: array, selectedItem: selectedModule)
			view.addSubview(moduleSelectorView)
		}
	}
	
	@IBAction func showActivityTypeSelector(_ sender:UIButton) {
		var array:[String] = [String]()
		for (_, item) in dataManager.activityTypes().enumerated() {
			array.append(item.name)
		}
		activityTypeSelectorView = CustomPickerView.create(localized("choose_activity_type"), delegate: self, contentArray: array, selectedItem: selectedActivityType)
		view.addSubview(activityTypeSelectorView)
	}
	
	@IBAction func showActivitySelector(_ sender:UIButton) {
		var array:[String] = [String]()
		for (index, _) in dataManager.activityTypes()[selectedActivityType].activities.enumerated() {
			let activityType = dataManager.activityTypes()[selectedActivityType]
			let name = dataManager.activityAtIndex(index, type: activityType)?.name
			if (name != nil) {
				array.append(name!)
			}
		}
		activitySelectorView = CustomPickerView.create(localized("choose_activity"), delegate: self, contentArray: array, selectedItem: selectedActivity)
		view.addSubview(activitySelectorView)
	}
	
	//MARK: CustomPickerView Delegate
	
	func view(_ view: CustomPickerView, selectedRow: Int) {
		switch (view) {
		case moduleSelectorView:
			if social() {
				if selectedRow == dataManager.modules().count - 1 {
					addModule()
				} else {
					selectedModule = selectedRow
					moduleButton.setTitle(dataManager.moduleNameAtIndex(selectedModule), for: UIControlState())
				}
			} else {
				selectedModule = selectedRow
				moduleButton.setTitle(dataManager.moduleNameAtIndex(selectedModule), for: UIControlState())
			}
			break
		case activityTypeSelectorView:
			selectedActivityType = selectedRow
			activityTypeButton.setTitle(dataManager.activityTypeNameAtIndex(selectedActivityType), for: UIControlState())
			selectedActivity = 0
			chooseActivityButton.setTitle(dataManager.activityAtIndex(selectedActivity, type: dataManager.activityTypes()[selectedActivityType])?.name, for: UIControlState())
			break
		case activitySelectorView:
			selectedActivity = selectedRow
			let activityType = dataManager.activityTypes()[selectedActivityType]
			chooseActivityButton.setTitle(dataManager.activityAtIndex(selectedActivity, type: activityType)?.name, for: UIControlState())
			break
		default:break
		}
		if (selectedModule < dataManager.modules().count) {
			theActivity!.module = dataManager.modules()[selectedModule]
		}
		theActivity!.activityType = dataManager.activityTypes()[selectedActivityType]
		theActivity!.activity = dataManager.activityAtIndex(selectedActivity, type: theActivity!.activityType)!
	}
	
	//MARK: Start/Stop Activity
	
	@IBAction func startActivity(_ sender:UIButton) {
		var moduleIsOk = true
		if social() {
			if let moduleID = theActivity?.module?.id {
				if moduleID == "add_module" {
					moduleIsOk = false
				}
			}
		}
		if moduleIsOk {
			if (theActivity != nil) {
				parametersView.alpha = 0.5
				parametersView.isUserInteractionEnabled = false
				shouldSave = true
				if (theActivity!.isPaused.boolValue) {
					let pauseInterval = Date().timeIntervalSince(theActivity!.pauseDate as Date)
					theActivity!.date = theActivity!.date.addingTimeInterval(pauseInterval)
					theActivity!.pauseDate = Date()
					theActivity!.isPaused = false
					dataManager.safelySaveContext()
					let notificationTime = getLocalNotificationTime(theActivity!.id)
					if (notificationTime != nil) {
						reminderMinutes = Int(notificationTime! / 60.0)
						theActivity!.startBreatherNotificationAfter(reminderMinutes)
					}
					AlertView.showAlert(true, message: localized("activity_resumed"), completion: nil)
					startActivityButton.setTitle(localized("pause"), for: UIControlState())
				} else if (theActivity!.isRunning.boolValue) {
					theActivity!.isPaused = true
					theActivity!.pauseDate = Date()
					theActivity!.timeSpent = (Int(abs(theActivity!.date.timeIntervalSinceNow)) / 60) as NSNumber
					updateSpentTimeLabel()
					dataManager.safelySaveContext()
					AlertView.showAlert(true, message: localized("activity_paused"), completion: nil)
					deleteLocalNotification(theActivity!.id)
					startActivityButton.setTitle(localized("resume"), for: UIControlState())
				} else {
					theActivity!.isRunning = true
					theActivity!.date = Date()//.dateByAddingTimeInterval(-80 * 60 - 50)
					theActivity!.modifiedDate = Date()
					theActivity!.startBreatherNotificationAfter(reminderMinutes)
					stopActivityButton.isEnabled = true
					dataManager.safelySaveContext()
					AlertView.showAlert(true, message: localized("activity_started"), completion: nil)
					startActivityButton.setTitle(localized("pause"), for: UIControlState())
				}

			}
		} else {
			UIAlertView(title: localized("error"), message: localized("please_select_a_module"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
		}
	}
	
	func updateTimeLabel(_ sender:Timer) {
		if let activityPaused = theActivity?.isPaused.boolValue {
			if let activityDate = theActivity?.date {
				if !activityPaused {
					if (sender.isValid) {
						let timeInterval = abs(activityDate.timeIntervalSinceNow)
						if (timeInterval > 0) {
							theActivity?.timeSpent = (Int(timeInterval) / 60) as NSNumber
							updateSpentTimeLabel()
						}
					}
				}
			}
		}
	}
	
	func updateSpentTimeLabel() {
		if (theActivity != nil) {
			if (theActivity!.isRunning.boolValue) {
				if (theActivity!.isPaused.boolValue) {
					let pauseInterval = Date().timeIntervalSince(theActivity!.pauseDate as Date)
					theActivity!.date = theActivity!.date.addingTimeInterval(pauseInterval)
					theActivity!.pauseDate = Date()
					theActivity!.timeSpent = (Int(abs(theActivity!.date.timeIntervalSinceNow)) / 60) as NSNumber
					dataManager.safelySaveContext()
				}
				if (theActivity!.timeSpent.intValue >= maximumMinutesActivity) {
					stopActivity(UIButton())
				} else {
					var firstValue = theActivity!.hoursSpent()
					var secondValue = Int(theActivity!.timeSpent) % 60
					var thirdValue = -1
					if (firstValue == 0) {
						firstValue = Int(theActivity!.timeSpent)
						secondValue = Int(abs(theActivity!.date.timeIntervalSinceNow).truncatingRemainder(dividingBy: 60))
					} else {
						thirdValue = Int(abs(theActivity!.date.timeIntervalSinceNow).truncatingRemainder(dividingBy: 60))
					}
					
					var firstValueString = "\(firstValue)"
					if (firstValue < 10) {
						firstValueString = "0\(firstValue)"
					}
					
					var secondValueString = "\(secondValue)"
					if (secondValue < 10) {
						secondValueString = "0\(secondValue)"
					}
					
					var thirdValueString = "\(thirdValue)"
					if (thirdValue < 10) {
						thirdValueString = "0\(thirdValue)"
					}
					
					if (thirdValue < 0) {
						spentTimeLabel.text = "\(firstValueString):\(secondValueString)"
					} else {
						spentTimeLabel.text = "\(firstValueString):\(secondValueString):\(thirdValueString)"
					}
				}
			} else {
				spentTimeLabel.text = "00:00"
			}
		}
	}
	
	@IBAction func stopActivity(_ sender:UIButton) {
		if (theActivity != nil) {
			timeActivityTimer?.invalidate()
			dataManager.stopRunningActivity(theActivity!, completion: { (success, failureReason) -> Void in
				if (success) {
					AlertView.showAlert(true, message: localized("activity_stopped"), completion: { (done) -> Void in
						_ = self.navigationController?.popViewController(animated: true)
					})
                    //London Developer July 24,2017
                    let urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=logs-timed&contentName=logTimed&modid=\(String(describing: self.theActivity?.module?.id))"
                    xAPIManager().checkMod(testUrl:urlString)
				} else if (failureReason == "timeZero") {
					AlertView.showAlert(false, message: localized("activity_was_cancelled_due_to_short_time_spent"), completion: { (done) -> Void in
						_ = self.navigationController?.popViewController(animated: true)
					})
				} else {
					AlertView.showAlert(false, message: failureReason, completion: { (done) -> Void in
						_ = self.navigationController?.popViewController(animated: true)
					})
				}
			})
		} else {
			AlertView.showAlert(false, message: localized("something_went_wrong"), completion: nil)
		}
	}
	
	//MARK: UIPickerView Datasource
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 60
	}
	
	//MARK: UIPickerView Delegate
	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		var viewForRow:UIView
		var title = "\(row + 1):00"
		if (row < 9) {
			title = "0\(row + 1):00"
		}
		if (view != nil) {
			viewForRow = view!
			
			let label = viewForRow.viewWithTag(1) as? UILabel
			if (label != nil) {
				label!.text = title
			}
		} else {
			viewForRow = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 130.0, height: 80.0))
			viewForRow.backgroundColor = UIColor.clear
			
			let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 130.0, height: 80.0))
			label.backgroundColor = UIColor.clear
			label.text = title
			label.textAlignment = NSTextAlignment.center
			label.textColor = lilacColor
			label.font = myriadProLight(50)
			label.tag = 1
			viewForRow.addSubview(label)
		}
		return viewForRow
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		reminderMinutes = row + 1
		var title = "\(reminderMinutes):00"
		if (row < 9) {
			title = "0\(reminderMinutes):00"
		}
		reminderTimeLabel.text = title
		if (theActivity != nil) {
			if (theActivity!.isRunning.boolValue) {
				if (!theActivity!.isPaused.boolValue) {
					theActivity!.startBreatherNotificationAfter(reminderMinutes)
				}
			}
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 80.0
	}
	
	//MARK: - UITextField Delegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		if let text = textField.text {
			DownloadManager().addSocialModule(studentId: dataManager.currentStudent!.id, module: text, alertAboutInternet: true, completion: { (success, result, results, error) in
				DownloadManager().getSocialModules(studentId: dataManager.currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) in
					if (success) {
						if let modules = results as? [String] {
							for (_, item) in modules.enumerated() {
								let dictionary = NSMutableDictionary()
								dictionary[item] = item
								let object = Module.insertInManagedObjectContext(managedContext, dictionary: dictionary)
								dataManager.currentStudent!.addModule(object)
							}
						}
					}
					self.selectedModule = 0
					self.moduleButton.setTitle(dataManager.moduleNameAtIndex(self.selectedModule), for: UIControlState())
				})
			})
		}
		closeAddModule(nil)
		return true
	}
}
