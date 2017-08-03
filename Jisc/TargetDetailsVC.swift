//
//  TargetDetailsVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/29/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

class TargetDetailsVC: BaseViewController, UIScrollViewDelegate {
	
	@IBOutlet weak var contentScrollView:UIScrollView!
	var previousTargetView:SingleTargetDetailsView
	var currentTargetView:SingleTargetDetailsView
	var nextTargetView:SingleTargetDetailsView
	@IBOutlet weak var slideMessageView:UIView!
	@IBOutlet weak var slideMessageBottomSpace:NSLayoutConstraint!
	@IBOutlet weak var pageControl:UIPageControl!
	
	var theTarget:Target
	var targetIndex:Int
	
	required init(target:Target, index:Int) {
		theTarget = target
		targetIndex = index
		
		previousTargetView = SingleTargetDetailsView()
		currentTargetView = SingleTargetDetailsView()
		nextTargetView = SingleTargetDetailsView()
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.automaticallyAdjustsScrollViewInsets = false
		pageControl.numberOfPages = dataManager.targets().count
		pageControl.currentPage = targetIndex
		
		previousTargetView = SingleTargetDetailsView.create(.left, superview: contentScrollView)
		currentTargetView = SingleTargetDetailsView.create(.middle, superview: contentScrollView)
		nextTargetView = SingleTargetDetailsView.create(.right, superview: contentScrollView)
		
		let horizontalLeft = makeConstraint(previousTargetView, attribute1: .trailing, relation: .equal, item2: currentTargetView, attribute2: .leading, multiplier: 1.0, constant: 0.0)
		let horizontalRight = makeConstraint(currentTargetView, attribute1: .trailing, relation: .equal, item2: nextTargetView, attribute2: .leading, multiplier: 1.0, constant: 0.0)
		
		view.addConstraints([horizontalLeft, horizontalRight])
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadTargetsInViews()
		previousTargetView.navigationController = navigationController
		currentTargetView.navigationController = navigationController
		nextTargetView.navigationController = navigationController
		view.layoutIfNeeded()
		if (previousTargetView.theTarget != nil) {
			contentScrollView.setContentOffset(CGPoint(x: screenWidth.rawValue, y: 0), animated: false)
		} else {
			contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		view.layoutIfNeeded()
		contentScrollView.setContentOffset(CGPoint(x: previousTargetView.width.constant, y: 0), animated: true)
		slideMessageBottomSpace.constant = -slideMessageView.frame.size.height
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.slideMessageBottomSpace.constant = 0.0
			self.view.layoutIfNeeded()
			}, completion: { (done) -> Void in
				UIView.animate(withDuration: 0.5, delay: 3, options: .allowUserInteraction, animations: { () -> Void in
					self.slideMessageBottomSpace.constant = -self.slideMessageView.frame.size.height
					self.view.layoutIfNeeded()
					}, completion: nil)
		})
        //London Developer July 24,2017
        let urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-specific&contentName=TargetsDonutCharts"
        xAPIManager().checkMod(testUrl:urlString)
	}
	
	func loadTargetsInViews() {
		if (dataManager.targets().count == 1) {
			contentScrollView.isScrollEnabled = false
		} else {
			contentScrollView.isScrollEnabled = true
		}
		previousTargetView.pieChartSwitch(false)
		currentTargetView.pieChartSwitch(false)
		nextTargetView.pieChartSwitch(false)
		
		currentTargetView.loadTarget(theTarget)
		
		var previousIndex:Int
		if (targetIndex > 0) {
			previousIndex = targetIndex - 1
		} else {
			previousIndex = dataManager.targets().count - 1
		}
		previousTargetView.loadTarget(dataManager.targets()[previousIndex])
		
		var nextIndex:Int
		if (targetIndex < dataManager.targets().count - 1) {
			nextIndex = targetIndex + 1
		} else {
			nextIndex = 0
		}
		nextTargetView.loadTarget(dataManager.targets()[nextIndex])
		pageControl.currentPage = targetIndex
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
	
	func checkScrollViewPosition() {
		let offset = Int(contentScrollView.contentOffset.x / screenWidth.rawValue)
		let nextTargetOffset = Int((previousTargetView.width.constant + currentTargetView.width.constant) / screenWidth.rawValue)
		if (offset == 0 && targetIndex > 0) {
			targetIndex -= 1
			theTarget = dataManager.targets()[targetIndex]
			loadTargetsInViews()
		} else if (offset == nextTargetOffset && targetIndex < dataManager.targets().count - 1) {
			targetIndex += 1
			theTarget = dataManager.targets()[targetIndex]
			loadTargetsInViews()
		} else if (offset == 0 && targetIndex == 0) {
			targetIndex = dataManager.targets().count - 1
			theTarget = dataManager.targets()[targetIndex]
			loadTargetsInViews()
		} else if (offset == nextTargetOffset && targetIndex == dataManager.targets().count - 1) {
			targetIndex = 0
			theTarget = dataManager.targets()[targetIndex]
			loadTargetsInViews()
		}
		contentScrollView.setContentOffset(CGPoint(x: previousTargetView.width.constant, y: contentScrollView.contentOffset.y), animated: false)
	}
	
	//MARK: UIScrollView Delegate
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		checkScrollViewPosition()
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if (!decelerate) {
			checkScrollViewPosition()
		}
	}
}
