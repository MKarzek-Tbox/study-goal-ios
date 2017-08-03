//
//  LogActivityVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/15/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

/*
A log cannot last longer than 8 hours
*/

let maxHours = 8

class LogActivityVC: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIAlertViewDelegate, CustomPickerViewDelegate, UITextFieldDelegate {
	
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var contentScroll:UIScrollView!
	@IBOutlet weak var scrollBottomSpace:NSLayoutConstraint!
	@IBOutlet weak var chooseActivityLabel:UILabel!
	@IBOutlet weak var hoursPicker:UIPickerView!
	@IBOutlet weak var minutesPicker:UIPickerView!
	@IBOutlet weak var closeTimePickerButton:UIButton!
	@IBOutlet weak var timePickerBottomSpace:NSLayoutConstraint!
	@IBOutlet weak var hoursTextField:UITextField!
	@IBOutlet weak var minutesTextField:UITextField!
	@IBOutlet weak var toolbar:UIView!
	var selectedHours:Int = 0
	var selectedMinutes:Int = 0
	@IBOutlet weak var selectedDateLabel:UILabel!
	@IBOutlet weak var noteTextView:UITextView!
	@IBOutlet weak var closeDatePickerButton:UIButton!
	@IBOutlet weak var datePickerBottomSpace:NSLayoutConstraint!
	@IBOutlet weak var datePicker:UIDatePicker!
	var theActivity:ActivityLog?
	var isEditingLog:Bool = false
	@IBOutlet weak var addModuleView:UIView!
	@IBOutlet weak var addModuleTextField:UITextField!
	
	var initialSelectedModule = 0
	var initialSelectedActivityType = 0
	var initialSelectedActivity = 0
	var initialHours:Int = 0
	var initialMinutes:Int = 0
	var initialDate:Date = Date()
	var initialNote:String = ""
	
	var selectedModule:Int = 0
	var selectedActivityType:Int = 0
	var selectedActivity:Int = 0
	@IBOutlet weak var moduleButton:UIButton!
	@IBOutlet weak var activityTypeButton:UIButton!
	@IBOutlet weak var chooseActivityButton:UIButton!
	var moduleSelectorView:CustomPickerView = CustomPickerView()
	var activityTypeSelectorView:CustomPickerView = CustomPickerView()
	var activitySelectorView:CustomPickerView = CustomPickerView()
	
	var prefilled = false
	
	init(activity:ActivityLog) {
		theActivity = activity
		super.init(nibName: nil, bundle: nil)
	}
	
	init(module:Int, activityType:Int, activity:Int) {
		prefilled = true
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
//		if iPad {
//			hoursTextField.font = UIFont(name: "MyriadPro-Light", size: 44.0)
//			minutesTextField.font = UIFont(name: "MyriadPro-Light", size: 44.0)
//		} else {
//			hoursTextField.font = UIFont(name: "MyriadPro-Light", size: 52.0)
//			minutesTextField.font = UIFont(name: "MyriadPro-Light", size: 52.0)
//		}
		datePicker.maximumDate = Date()
		chooseActivityLabel.adjustsFontSizeToFitWidth = true
		selectedDateLabel.adjustsFontSizeToFitWidth = true
		if (theActivity != nil) {
			isEditingLog = true
			titleLabel.text = localized("edit_activity")
			if (theActivity!.module != nil) {
				selectedModule = dataManager.indexOfModuleWithID(theActivity!.module!.id)!
			}
			selectedActivityType = dataManager.indexOfActivityType(theActivity!.activityType)!
			selectedActivity = dataManager.indexOfActivityWithName(theActivity!.activity.englishName, type: theActivity!.activityType)!
			selectedHours = theActivity!.hoursSpent()
			hoursPicker.selectRow(selectedHours, inComponent: 0, animated: false)
			selectedMinutes = Int(theActivity!.timeSpent) % 60
			minutesPicker.selectRow(selectedMinutes, inComponent: 0, animated: false)
			selectedDateLabel.text = completeDateString(theActivity!.date as Date)
			datePicker.date = theActivity!.date as Date
			noteTextView.text = theActivity!.note
		} else if (!prefilled) {
			if (dataManager.modules().count > 0) {
				selectedModule = 0
			}
			if (dataManager.activityTypes().count > 0) {
				selectedActivityType = 0
			}
			if (dataManager.activityTypes()[0].activities.count > 0) {
				selectedActivity = 0
			}
			selectedDateLabel.text = completeDateString(Date())
		}
		var title = "\(selectedHours)"
		if (selectedHours < 10) {
			title = "0\(selectedHours)"
		}
		hoursTextField.text = title
		title = "\(selectedMinutes)"
		if (selectedMinutes < 10) {
			title = "0\(selectedMinutes)"
		}
		minutesTextField.text = title
		moduleButton.setTitle(dataManager.moduleNameAtIndex(selectedModule), for: UIControlState())
		activityTypeButton.setTitle(dataManager.activityTypeNameAtIndex(selectedActivityType), for: UIControlState())
		let activityType = dataManager.activityTypes()[selectedActivityType]
		chooseActivityButton.setTitle(dataManager.activityAtIndex(selectedActivity, type: activityType)?.name, for: UIControlState())
		
		initialSelectedModule = selectedModule
		initialSelectedActivityType = selectedActivityType
		initialSelectedActivity = selectedActivity
		initialHours = selectedHours
		initialMinutes = selectedMinutes
		initialDate = datePicker.date
		initialNote = noteTextView.text
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
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
	
	func completeDateString(_ date:Date) -> String {
		dateFormatter.dateFormat = "d"
		let day = Int(dateFormatter.string(from: date))
		var dayOrderString = "th"
		if (day == 1) {
			dayOrderString = "st"
		} else if (day == 2) {
			dayOrderString = "nd"
		} else if (day == 3) {
			dayOrderString = "rd"
		} else if (day == 21) {
			dayOrderString = "st"
		} else if (day == 22) {
			dayOrderString = "nd"
		} else if (day == 23) {
			dayOrderString = "rd"
		} else if (day == 31) {
			dayOrderString = "st"
		}
		dateFormatter.dateFormat = "EEEE d"
		let dateSoFar = dateFormatter.string(from: date)
		dateFormatter.dateFormat = "MMM yyyy"
		let completeDateString = "\(dateSoFar)\(dayOrderString) \(dateFormatter.string(from: date))"
		return completeDateString
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		if (changesWereMade()) {
			UIAlertView(title: localized("confirmation"), message: localized("would_you_like_to_save_the_changes_you_made"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
		} else {
			_ = navigationController?.popToRootViewController(animated: true)
		}
	}
	
	func changesWereMade() -> Bool {
		var changesWereMade:Bool = false
		if (initialSelectedModule != selectedModule) {
			changesWereMade = true
		} else if (initialSelectedActivityType != selectedActivityType) {
			changesWereMade = true
		} else if (initialSelectedActivity != selectedActivity) {
			changesWereMade = true
		} else if (initialHours != selectedHours) {
			changesWereMade = true
		} else if (initialMinutes != selectedMinutes) {
			changesWereMade = true
		} else if (!(initialDate.compare(datePicker.date) == ComparisonResult.orderedSame)) {
			changesWereMade = true
		} else if (initialNote != noteTextView.text) {
			changesWereMade = true
		}
		return changesWereMade
	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	func closeActiveTextEntries() {
		view.endEditing(true)
		hoursTextField.text = "0\(selectedHours)"
		if selectedMinutes < 10 {
			minutesTextField.text = "0\(selectedMinutes)"
		} else {
			minutesTextField.text = "\(selectedMinutes)"
		}
		closeTextView(UIBarButtonItem())
	}
	
	//MARK: Show/Close Selectors
	
	@IBAction func showModuleSelector(_ sender:UIButton) {
		if currentUserType() == .social {
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
			if (!isEditingLog) {
				closeActiveTextEntries()
				var array:[String] = [String]()
				for (_, item) in dataManager.modules().enumerated() {
					array.append(item.name)
				}
				moduleSelectorView = CustomPickerView.create(localized("choose_module"), delegate: self, contentArray: array, selectedItem: selectedModule)
				view.addSubview(moduleSelectorView)
			}
		}
	}
	
	@IBAction func showActivityTypeSelector(_ sender:UIButton) {
		if (!isEditingLog) {
			closeActiveTextEntries()
			var array:[String] = [String]()
			for (_, item) in dataManager.activityTypes().enumerated() {
				array.append(item.name)
			}
			activityTypeSelectorView = CustomPickerView.create(localized("choose_activity_type"), delegate: self, contentArray: array, selectedItem: selectedActivityType)
			view.addSubview(activityTypeSelectorView)
		}
	}
	
	@IBAction func showActivitySelector(_ sender:UIButton) {
		if (!isEditingLog) {
			closeActiveTextEntries()
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
	}
	
	//MARK: CustomPickerView Delegate
	
	func view(_ view: CustomPickerView, selectedRow: Int) {
		switch (view) {
		case moduleSelectorView:
			if currentUserType() == .social {
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
		if (theActivity != nil) {
			if (selectedModule < dataManager.modules().count) {
				theActivity!.module = dataManager.modules()[selectedModule]
			}
			theActivity!.activityType = dataManager.activityTypes()[selectedActivityType]
			theActivity!.activity = dataManager.activityAtIndex(selectedActivity, type: theActivity!.activityType)!
		}
	}
	
	//MARK: Change Date
	
	@IBAction func changeDate(_ sender:UIButton) {
		closeActiveTextEntries()
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.closeDatePickerButton.alpha = 1.0
			self.datePickerBottomSpace.constant = 0.0
			self.view.layoutIfNeeded()
		}) 
	}
	
	@IBAction func closeDatePicker(_ sender:UIButton) {
		animateDatePickerClosing()
	}
	
	@IBAction func closeDatePickerFromToolbar(_ sender:UIBarButtonItem) {
		animateDatePickerClosing()
	}
	
	func animateDatePickerClosing() {
		datePicker.setDate(datePicker.date, animated: false)
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.closeDatePickerButton.alpha = 0.0
			self.datePickerBottomSpace.constant = -260.0
			self.view.layoutIfNeeded()
		}) 
		selectedDateLabel.text = completeDateString(datePicker.date)
	}
	
	//MARK: Change Time
	
	@IBAction func changeTime(_ sender:UIButton) {
		closeActiveTextEntries()
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.closeTimePickerButton.alpha = 1.0
			self.timePickerBottomSpace.constant = 0.0
			self.view.layoutIfNeeded()
		}) 
	}
	
	@IBAction func closeTimePicker(_ sender:UIButton) {
		animateTimePickerClosing()
	}
	
	@IBAction func closeTimePickerFromToolbar(_ sender:UIBarButtonItem) {
		animateTimePickerClosing()
	}
	
	func animateTimePickerClosing() {
		hoursPicker.selectRow(selectedHours, inComponent: 0, animated: false)
		minutesPicker.selectRow(selectedMinutes, inComponent: 0, animated: false)
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.closeTimePickerButton.alpha = 0.0
			self.timePickerBottomSpace.constant = -260.0
			self.view.layoutIfNeeded()
		}) 
	}
	
	//MARK: Save
	
	@IBAction func save(_ sender:UIButton) {
		closeActiveTextEntries()
		if (selectedMinutes == 0 && selectedHours == 0) {
			UIAlertView(title: localized("error"), message: localized("please_enter_the_time_spent"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
		} else {
			if (theActivity != nil) {
				theActivity!.student = dataManager.currentStudent!
				if (selectedModule < dataManager.modules().count) {
					theActivity!.module = dataManager.modules()[selectedModule]
				}
				var moduleIsOk = true
				if social() {
					if let moduleID = theActivity?.module?.id {
						if moduleID == "add_module" {
							moduleIsOk = false
						}
					}
				}
				if moduleIsOk {
					theActivity!.activityType = dataManager.activityTypes()[selectedActivityType]
					theActivity!.activity = dataManager.activityAtIndex(selectedActivity, type: theActivity!.activityType)!
					theActivity!.date = datePicker.date
					theActivity!.timeSpent = ((selectedHours * 60) + selectedMinutes) as NSNumber
					theActivity!.note = noteTextView.text
					dataManager.editActivityLog(theActivity!, completion: { (success, failureReason) -> Void in
						if (success) {
							AlertView.showAlert(true, message: localized("saved_successfully"), completion: { (done) -> Void in
								_ = self.navigationController?.popToRootViewController(animated: true)
							})
						} else {
							managedContext.rollback()
							AlertView.showAlert(false, message: failureReason, completion: nil)
						}
					})
				} else {
					UIAlertView(title: localized("error"), message: localized("please_select_a_module"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
				}
			} else {
				var moduleIsOk = true
				if social() {
					if dataManager.modules()[selectedModule].id == "add_module" {
						moduleIsOk = false
					}
				}
				if moduleIsOk {
					let newActivity = ActivityLog.insertInManagedObjectContext(managedContext, dictionary: NSDictionary())
					newActivity.student = dataManager.currentStudent!
					if (selectedModule < dataManager.modules().count) {
						newActivity.module = dataManager.modules()[selectedModule]
					}
					newActivity.activityType = dataManager.activityTypes()[selectedActivityType]
					newActivity.activity = dataManager.activityAtIndex(selectedActivity, type: newActivity.activityType)!
					newActivity.date = datePicker.date
					newActivity.timeSpent = ((selectedHours * 60) + selectedMinutes) as NSNumber
					newActivity.note = noteTextView.text
					dataManager.addActivityLog(newActivity, completion: { (success, failureReason) -> Void in
						if (success) {
							AlertView.showAlert(true, message: localized("saved_successfully"), completion: { (done) -> Void in
								_ = self.navigationController?.popToRootViewController(animated: true)
                                //London Developer July 24,2017
                                let urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=logs-timed&contentName=logTimed&modid=\(String(describing: newActivity.module?.id))"
                                xAPIManager().checkMod(testUrl:urlString)
							})
						} else {
							AlertView.showAlert(false, message: failureReason, completion: nil)
						}
						dataManager.deleteObject(newActivity)
					})
				} else {
					UIAlertView(title: localized("error"), message: localized("please_select_a_module"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
				}
			}
		}
	}
	
	//MARK: UIAlertView Delegate
	
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		if (buttonIndex == 0) {
			managedContext.rollback()
			_ = navigationController?.popToRootViewController(animated: true)
		} else {
			save(UIButton())
		}
	}
	
	//MARK: UIPickerView Datasource
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		var nrRows = 0
		switch (pickerView) {
		case hoursPicker:
			nrRows = maxHours + 1
		case minutesPicker:
			nrRows = 60
		default:break
		}
		return nrRows
	}
	
	//MARK: UIPickerView Delegate
	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		var viewForRow:UIView
		var title = "\(row)"
		if (row < 10) {
			title = "0\(row)"
		}
		
		if (view != nil) {
			viewForRow = view!
			
			let label = viewForRow.viewWithTag(1) as? UILabel
			if (label != nil) {
				label!.text = title
			}
		} else {
			viewForRow = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 50.0))
			viewForRow.backgroundColor = UIColor.clear
			
			let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 50.0))
			label.backgroundColor = UIColor.clear
			label.text = title
			label.textAlignment = NSTextAlignment.center
			label.textColor = lilacColor
			label.font = myriadProLight(44)
			label.tag = 1
			viewForRow.addSubview(label)
		}
		return viewForRow
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		var title = "\(row)"
		if (row < 10) {
			title = "0\(row)"
		}
		switch (pickerView) {
		case hoursPicker:
			selectedHours = row
			hoursTextField.text = title
			if (selectedHours == maxHours && selectedMinutes > 0) {
				selectedMinutes = 0
				minutesTextField.text = "00"
				minutesPicker.selectRow(0, inComponent: 0, animated: true)
				AlertView.showAlert(false, message: localizedWith1Parameter("time_spent_max", parameter: "\(maxHours)"), completion: nil)
			}
		case minutesPicker:
			if (selectedHours == maxHours && row > 0) {
				selectedMinutes = 0
				minutesTextField.text = "00"
				minutesPicker.selectRow(0, inComponent: 0, animated: true)
				AlertView.showAlert(false, message: localizedWith1Parameter("time_spent_max", parameter: "\(maxHours)"), completion: nil)
			} else {
				selectedMinutes = row
				minutesTextField.text = title
			}
		default:break
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 50.0
	}
	
	//MARK: UITextView Delegate
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.scrollBottomSpace.constant = keyboardHeight - 5.0
			self.contentScroll.contentOffset = CGPoint(x: 0.0, y: self.contentScroll.contentSize.height - self.scrollBottomSpace.constant)
			self.view.layoutIfNeeded()
		}) 
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.scrollBottomSpace.constant = 0.0
			self.view.layoutIfNeeded()
		}) 
	}
	
	@IBAction func closeTextView(_ sender:UIBarButtonItem) {
		noteTextView.resignFirstResponder()
	}
	
	//MARK: - UITextField Delegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == addModuleTextField {
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
		}
		return true
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		toolbar.alpha = 0.0
		var shouldBegin = true
		if selectedHours == maxHours && textField == minutesTextField {
			shouldBegin = false
			AlertView.showAlert(false, message: localizedWith1Parameter("time_spent_max", parameter: "\(maxHours)"), completion: nil)
		} else {
			textField.text = ""
		}
		return shouldBegin
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.scrollBottomSpace.constant = keyboardHeight - 44.0
			self.view.layoutIfNeeded()
		})
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		if selectedHours == maxHours && textField == hoursTextField {
			minutesTextField.text = "00"
			selectedMinutes = 0
		}
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.scrollBottomSpace.constant = 0.0
			self.view.layoutIfNeeded()
		})
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		toolbar.alpha = 1.0
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		var shouldChange = false
		if string.isEmpty || textField == addModuleTextField {
			shouldChange = true
		} else {
			if "0123456789".contains(string) {
				shouldChange = true
				switch textField {
				case hoursTextField:
					if string == "9" {
						shouldChange = false
					} else {
						textField.text = "0\(string)"
						selectedHours = (string as NSString).integerValue
						textField.resignFirstResponder()
					}
					break
				case minutesTextField:
					if let text = textField.text {
						if text.isEmpty {
							if !"012345".contains(string) {
								shouldChange = false
							}
						} else {
							if let text = textField.text {
								textField.text = (text as NSString).replacingCharacters(in: range, with: string)
								selectedMinutes = ((text as NSString).replacingCharacters(in: range, with: string) as NSString).integerValue
								textField.resignFirstResponder()
							}
						}
					}
					break
				default:
					break
				}
			}
		}
		return shouldChange
	}
}
