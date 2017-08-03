//
//  SingleTargetDetailsView.swift
//  Jisc
//
//  Created by Therapy Box on 11/11/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

enum kVisibleOptions {
	case targetReachedOnly
	case setStretchTarget
	case stretchTargetRunning
	case share
	case none
}

enum kDetailsPosition {
	case left
	case middle
	case right
}

let bottomSectionOpenHeight:CGFloat = 128.0

class SingleTargetDetailsView: LocalizableView, UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CustomPickerViewDelegate {
	
	@IBOutlet weak var width:NSLayoutConstraint!
	@IBOutlet weak var height:NSLayoutConstraint!
	@IBOutlet weak var contentScroll:UIScrollView!
	@IBOutlet weak var titleView:UIView!
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var targetTypeIcon:UIImageView!
	@IBOutlet weak var completionColorView:UIView!
	@IBOutlet weak var optionsButtonsWidth:NSLayoutConstraint!
	@IBOutlet weak var optionsButtonsView:UIView!
	@IBOutlet weak var topSection:UIView!
	@IBOutlet weak var topSectionHeight:NSLayoutConstraint!
	@IBOutlet weak var middleSection:UIView!
	@IBOutlet weak var middleSectionHeight:NSLayoutConstraint!
	@IBOutlet weak var bottomSection:UIView!
	@IBOutlet weak var bottomSectionHeight:NSLayoutConstraint!
	@IBOutlet var targetReachedView:UIView!
	@IBOutlet var shareTargetView:UIView!
	@IBOutlet var setStretchTargetButtonView:UIView!
	@IBOutlet var setStretchView:UIView!
	@IBOutlet weak var stretchTargetHoursPicker:UIPickerView!
	@IBOutlet weak var stretchTargetMinutesPicker:UIPickerView!
	@IBOutlet var currentStretchTargetView:UIView!
	@IBOutlet weak var currentStretchTargetText:UILabel!
	@IBOutlet weak var startNewActivityButton:UIButton!
	@IBOutlet var pieChart:TargetPieChart!
	@IBOutlet var graphChart:TargetGraphChart!
	@IBOutlet var viewsWithShadow:[UIView] = []
	
	var optionsState:kOptionsState = .closed
	var panStartPoint:CGPoint = CGPoint.zero
	var navigationController:UINavigationController?
	var selectedHours:Int = 0
	var selectedMinutes:Int = 0
	var theTarget:Target?
	var currentVisibleOptions:kVisibleOptions = .none
	var visibleOptionsBeforeShare:kVisibleOptions = .none
	
	class func create(_ position:kDetailsPosition, superview:UIView) -> SingleTargetDetailsView {
		let view:SingleTargetDetailsView = Bundle.main.loadNibNamed("SingleTargetDetailsView", owner: nil, options: nil)!.first as! SingleTargetDetailsView
		view.height.constant = superview.frame.size.height
		view.width.constant = screenWidth.rawValue
		view.translatesAutoresizingMaskIntoConstraints = false
		view.targetReachedView.translatesAutoresizingMaskIntoConstraints = false
		view.shareTargetView.translatesAutoresizingMaskIntoConstraints = false
		view.setStretchTargetButtonView.translatesAutoresizingMaskIntoConstraints = false
		view.setStretchView.translatesAutoresizingMaskIntoConstraints = false
		view.currentStretchTargetView.translatesAutoresizingMaskIntoConstraints = false
		superview.translatesAutoresizingMaskIntoConstraints = false
		superview.addSubview(view)
		let top = makeConstraint(superview, attribute1: .top, relation: .equal, item2: view, attribute2: .top, multiplier: 1.0, constant: 0.0)
		let equalHeight = makeConstraint(superview, attribute1: .height, relation: .equal, item2: view, attribute2: .height, multiplier: 1.0, constant: 0.0)
		switch position {
		case .left:
			let left = makeConstraint(superview, attribute1: .leading, relation: .equal, item2: view, attribute2: .leading, multiplier: 1.0, constant: 0.0)
			superview.addConstraints([top, left, equalHeight])
			break
		case .middle:
			superview.addConstraints([top, equalHeight])
			break
		case .right:
			let right = makeConstraint(superview, attribute1: .trailing, relation: .equal, item2: view, attribute2: .trailing, multiplier: 1.0, constant: 0.0)
			superview.addConstraints([top, right, equalHeight])
			break
		}
		if (view.viewsWithShadow.count > 0) {
			for (_, item) in view.viewsWithShadow.enumerated() {
				view.setShadow(item)
			}
		}
		return view
	}
	
	func setShadow(_ view:UIView) {
		view.layer.shadowColor = UIColor.gray.cgColor
		view.layer.shadowOpacity = 0.5
		view.layer.shadowRadius = 1.5
		view.layer.shadowOffset = CGSize(width: 0, height: 0)
		view.layer.rasterizationScale = UIScreen.main.scale
		view.layer.shouldRasterize = true
	}
	
	func loadTarget(_ target:Target?) {
		contentScroll.contentOffset = CGPoint.zero
		theTarget = target
		if (theTarget != nil) {
			width.constant = screenWidth.rawValue
			self.alpha = 1.0
			let progress = theTarget!.calculateProgress(false)
			titleLabel.text = theTarget!.textForDisplay()
			let imageName = theTarget!.activity.iconName(big: true)
			targetTypeIcon.image = UIImage(named: imageName)
			
			if (progress.completionPercentage >= 1.0) {
				completionColorView.backgroundColor = greenTargetColor
			} else if (progress.completionPercentage >= 0.8) {
				completionColorView.backgroundColor = orangeTargetColor
			} else {
				completionColorView.backgroundColor = redTargetColor
			}
			
			if (theTarget!.activityLogs().count > 0) {
				startNewActivityButton.alpha = 0.0
				topSectionHeight.constant = 40.0
			} else {
				startNewActivityButton.alpha = 1.0
				topSectionHeight.constant = 88.0
			}
			
			if (progress.completionPercentage >= 1.0) {
				let stretchTarget = dataManager.getStretchTargetForTarget(theTarget!)
				if (stretchTarget != nil) {
					let stretchCompletion = stretchTarget!.calculateProgress()
					if (stretchCompletion >= 1) {
						setVisibleOptions(.targetReachedOnly)
					} else {
						currentStretchTargetText.text = stretchTarget!.displayText()
						setVisibleOptions(.stretchTargetRunning)
					}
				} else {
					if (theTarget!.eligibleForStretch()) {
						setVisibleOptions(.setStretchTarget)
					} else {
						setVisibleOptions(.targetReachedOnly)
					}
				}
			} else {
				setVisibleOptions(.none)
			}
		} else {
			width.constant = 0.0
			self.alpha = 0.0
		}
		showPieChart()
	}
	
	func showPieChart() {
		graphChart.removeFromSuperview()
		middleSection.addSubview(pieChart)
		pieChart.loadTarget(theTarget)
		let top = makeConstraint(middleSection, attribute1: .top, relation: .equal, item2: pieChart, attribute2: .top, multiplier: 1.0, constant: 0.0)
		let bottom = makeConstraint(middleSection, attribute1: .bottom, relation: .equal, item2: pieChart, attribute2: .bottom, multiplier: 1.0, constant: 0.0)
		let centerX = makeConstraint(middleSection, attribute1: .centerX, relation: .equal, item2: pieChart, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
		middleSection.addConstraints([top, bottom, centerX])
		middleSectionHeight.constant = pieChart.frame.size.height
		self.layoutIfNeeded()
	}
	
	func showGraphChart() {
		graphChart.removeFromSuperview()
		pieChart.removeFromSuperview()
		graphChart.loadTarget(theTarget)
		middleSection.addSubview(graphChart)
		let top = makeConstraint(middleSection, attribute1: .top, relation: .equal, item2: graphChart, attribute2: .top, multiplier: 1.0, constant: 0.0)
		let bottom = makeConstraint(middleSection, attribute1: .bottom, relation: .equal, item2: graphChart, attribute2: .bottom, multiplier: 1.0, constant: 0.0)
		let centerX = makeConstraint(middleSection, attribute1: .centerX, relation: .equal, item2: graphChart, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
		middleSection.addConstraints([top, bottom, centerX])
		middleSectionHeight.constant = graphChart.frame.size.height
		self.layoutIfNeeded()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(SingleTargetDetailsView.panAction(_:)))
		panGesture.delegate = self
		titleView.addGestureRecognizer(panGesture)
		contentScroll.contentInset = UIEdgeInsets.zero
		layoutIfNeeded()
	}
	
	func setVisibleOptions(_ options:kVisibleOptions) {
		currentVisibleOptions = options
		targetReachedView.removeFromSuperview()
		shareTargetView.removeFromSuperview()
		setStretchTargetButtonView.removeFromSuperview()
		currentStretchTargetView.removeFromSuperview()
		switch (currentVisibleOptions) {
		case .targetReachedOnly:
			bottomSectionHeight.constant = bottomSectionOpenHeight
			bottomSection.addSubview(targetReachedView)
			let centerX = makeConstraint(bottomSection, attribute1: .centerX, relation: .equal, item2: targetReachedView, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
			let centerY = makeConstraint(bottomSection, attribute1: .centerY, relation: .equal, item2: targetReachedView, attribute2: .centerY, multiplier: 1.0, constant: 0.0)
			bottomSection.addConstraints([centerX, centerY])
			bottomSection.layoutIfNeeded()
			pieChart.setTargetIsComplete(true)
			break
		case .setStretchTarget:
			bottomSectionHeight.constant = bottomSectionOpenHeight
			bottomSection.addSubview(targetReachedView)
			bottomSection.addSubview(setStretchTargetButtonView)
			var centerX = makeConstraint(bottomSection, attribute1: .centerX, relation: .equal, item2: targetReachedView, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
			let top = makeConstraint(bottomSection, attribute1: .top, relation: .equal, item2: targetReachedView, attribute2: .top, multiplier: 1.0, constant: 0.0)
			bottomSection.addConstraints([centerX, top])
			centerX = makeConstraint(bottomSection, attribute1: .centerX, relation: .equal, item2: setStretchTargetButtonView, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
			bottomSection.addConstraint(centerX)
			let vertical = makeConstraint(targetReachedView, attribute1: .bottom, relation: .equal, item2: setStretchTargetButtonView, attribute2: .top, multiplier: 1.0, constant: 0.0)
			bottomSection.addConstraint(vertical)
			bottomSection.layoutIfNeeded()
			pieChart.setTargetIsComplete(true)
			break
		case .stretchTargetRunning:
			bottomSectionHeight.constant = bottomSectionOpenHeight
			bottomSection.addSubview(currentStretchTargetView)
			let centerX = makeConstraint(bottomSection, attribute1: .centerX, relation: .equal, item2: currentStretchTargetView, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
			let centerY = makeConstraint(bottomSection, attribute1: .centerY, relation: .equal, item2: currentStretchTargetView, attribute2: .centerY, multiplier: 1.0, constant: 0.0)
			bottomSection.addConstraints([centerX, centerY])
			bottomSection.layoutIfNeeded()
			pieChart.setTargetIsComplete(true)
			break
		case .share:
			bottomSectionHeight.constant = bottomSectionOpenHeight
			bottomSection.addSubview(shareTargetView)
			let centerX = makeConstraint(bottomSection, attribute1: .centerX, relation: .equal, item2: shareTargetView, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
			let centerY = makeConstraint(bottomSection, attribute1: .centerY, relation: .equal, item2: shareTargetView, attribute2: .centerY, multiplier: 1.0, constant: 0.0)
			bottomSection.addConstraints([centerX, centerY])
			bottomSection.layoutIfNeeded()
			pieChart.setTargetIsComplete(true)
			break
		case .none:
			bottomSectionHeight.constant = 20.0
			bottomSection.layoutIfNeeded()
			pieChart.setTargetIsComplete(false)
			break
		}
	}
	
	@IBAction func startNewActivity(_ sender:UIButton) {
//		DELEGATE.mainController?.selectedIndex = kHomeScreenTab.Log.rawValue
//		var module:Int = 0
//		var activityType:Int = 0
//		var activity:Int = 0
//		if (theTarget != nil) {
//			if (theTarget!.module != nil) {
//				module = dataManager.indexOfModuleWithID(theTarget!.module!.id)!
//			}
//			activityType = dataManager.indexOfActivityType(theTarget!.activityType)!
//			activity = dataManager.indexOfActivityWithName(theTarget!.activity.englishName, type: theTarget!.activityType)!
//		}
//		DELEGATE.mainController?.logViewController.goToReportActivity(module, activityType: activityType, activity: activity)
		
		var array:[String] = [String]()
		array.append(localized("report_activity"))
		array.append(localized("log_recent"))
		let logTypeSelectorView = CustomPickerView.create(localized("add"), delegate: self, contentArray: array, selectedItem: -1)
		navigationController?.view.addSubview(logTypeSelectorView)
	}
	
	func view(_ view: CustomPickerView, selectedRow: Int) {
		DELEGATE.menuView?.log()
		
		var module:Int = 0
		var activityType:Int = 0
		var activity:Int = 0
		if (theTarget != nil) {
			if (theTarget!.module != nil) {
				module = dataManager.indexOfModuleWithID(theTarget!.module!.id)!
			}
			activityType = dataManager.indexOfActivityType(theTarget!.activityType)!
			activity = dataManager.indexOfActivityWithName(theTarget!.activity.englishName, type: theTarget!.activityType)!
		}
		
		if (selectedRow == 0) {
			DELEGATE.menuView?.logViewController.navigationController?.pushViewController(NewActivityVC(module:module, activityType: activityType, activity: activity), animated: true)
            //London Developer July 24,2017
            let urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=logs-timed&contentName=logTimed&modid=\(module)"
            xAPIManager().checkMod(testUrl:urlString)

		} else if (selectedRow == 1) {
			DELEGATE.menuView?.logViewController.navigationController?.pushViewController(LogActivityVC(module:module, activityType: activityType, activity: activity), animated: true)
                //London Developer July 24,2017
                let urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=logs-untimed&contentName=logReport&modid=\(module)"
                xAPIManager().checkMod(testUrl:urlString)
		}
	}
	
	@IBAction func switchToPieChart(_ sender:UIButton) {
		pieChartSwitch(true)
	}
	
	func pieChartSwitch(_ animated:Bool) {
		showPieChart()
	}
	
	@IBAction func switchToGraph(_ sender:UIButton) {
		graphSwitch(true)
	}
	
	func graphSwitch(_ animated:Bool) {
		showGraphChart()
	}
	
	@IBAction func editTarget(_ sender:UIButton) {
		closeCellOptions()
		if (theTarget != nil) {
			let vc = NewTargetVC(target: theTarget!)
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func deleteTarget(_ sender:UIButton) {
		closeCellOptions()
		if (theTarget != nil) {
			dataManager.deleteTarget(theTarget!) { (success, failureReason) -> Void in
				if success {
					_ = self.navigationController?.popViewController(animated: true)
					AlertView.showAlert(true, message: localized("target_deleted_successfully"), completion: nil)
					dataManager.deleteObject(self.theTarget!)
				}
			}
		}
	}
	
	//MARK: Share
	
	@IBAction func shareTarget(_ sender:UIButton) {
		visibleOptionsBeforeShare = currentVisibleOptions
		setVisibleOptions(.share)
	}
	
	func closeShareView() {
		setVisibleOptions(visibleOptionsBeforeShare)
	}
	
	@IBAction func shareOnFacebook(_ sender:UIButton) {
		closeShareView()
		let shareText = "\(localized("target_reached")): \(theTarget!.textForDisplay())"
		sharingManager.shareText(shareText, on: .facebook, nvc: navigationController, successText: nil)
	}
	
	@IBAction func shareOnTwitter(_ sender:UIButton) {
		closeShareView()
		let shareText = "\(localized("target_reached")): \(theTarget!.textForDisplay())"
		sharingManager.shareText(shareText, on: .twitter, nvc: navigationController, successText: nil)
	}
	
	@IBAction func shareOnMail(_ sender:UIButton) {
		closeShareView()
		let shareText = "\(localized("target_reached")): \(theTarget!.textForDisplay())"
		sharingManager.shareText(shareText, on: .mail, nvc: navigationController, successText: nil)
	}
	
	//MARK: Add Stretch Goal
	
	@IBAction func addStretchGoal(_ sender:UIButton) {
		if (superview != nil) {
			if (superview!.superview != nil) {
				superview!.superview!.addSubview(setStretchView)
				setStretchView.alpha = 0.0
				addMarginConstraintsWithView(setStretchView, toSuperView: superview!.superview!)
				UIView.animate(withDuration: 0.25, animations: { () -> Void in
					self.setStretchView.alpha = 1.0
				}) 
			}
		}
	}
	
	@IBAction func closeStretchTargetView(_ sender:UIButton) {
		stretchTargetHoursPicker.selectRow(selectedHours, inComponent: 0, animated: false)
		stretchTargetMinutesPicker.selectRow(selectedMinutes, inComponent: 0, animated: false)
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.setStretchView.alpha = 0.0
			}, completion: { (done) -> Void in
				self.setStretchView.removeFromSuperview()
		}) 
	}
	
	@IBAction func setStretchTarget(_ sender:UIButton) {
		if (selectedHours == 0 && selectedMinutes == 0) {
			UIAlertView(title: localized("error"), message: localized("please_set_a_time_for_your_stretch_target"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
		} else {
			if (theTarget != nil) {
				let minutes = selectedHours * 60 + selectedMinutes
				dataManager.addStretchTarget(theTarget!.id, minutes: minutes, completion: { (success, failureReason) -> Void in
					if (success) {
						AlertView.showAlert(true, message: localized("stretch_target_added"), completion: { (done) -> Void in
							self.loadTarget(self.theTarget)
						})
					} else {
						AlertView.showAlert(false, message:failureReason , completion: nil)
					}
				})
			}
			closeStretchTargetView(sender)
		}
	}
	
	//MARK: UIPickerView Datasource
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		var nrRows = 0
		switch (pickerView) {
		case stretchTargetHoursPicker:
			nrRows = 49
		case stretchTargetMinutesPicker:
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
		switch (pickerView) {
		case stretchTargetHoursPicker:
			selectedHours = row
		case stretchTargetMinutesPicker:
			selectedMinutes = row
		default:break
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 50.0
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
			optionsButtonsWidth.constant = difference
			optionsButtonsView.setNeedsLayout()
			layoutIfNeeded()
		default:break
		}
	}
	
	func openCellOptions() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: kAnotherTargetCellOpenedOptions), object: self)
		optionsState = .open
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.optionsButtonsWidth.constant = kButtonsWidth
			self.optionsButtonsView.setNeedsLayout()
			self.layoutIfNeeded()
		}) 
	}
	
	func closeCellOptions() {
		optionsState = .closed
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.optionsButtonsWidth.constant = 0.0
			self.optionsButtonsView.setNeedsLayout()
			self.layoutIfNeeded()
		}) 
	}
}
