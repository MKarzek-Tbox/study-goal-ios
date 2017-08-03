//
//  TargetPieChart.swift
//  Jisc
//
//  Created by Therapy Box on 1/28/16.
//  Copyright © 2016 Therapy Box. All rights reserved.
//

import UIKit

class TargetPieChart: UIView {
	
	@IBOutlet weak var chartWebview:UIWebView!
	@IBOutlet weak var progressLabel:UILabel!
	@IBOutlet weak var starContainerView:UIView!
	@IBOutlet weak var completeLabel:UILabel!
	
	var theTarget:Target?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		translatesAutoresizingMaskIntoConstraints = false
//		chartWebview.scrollView.isScrollEnabled = false
	}
	
	override func willMove(toSuperview newSuperview: UIView?) {
		chartWebview.loadHTMLString("", baseURL: nil)
	}
	
	func loadTarget(_ target:Target?) {
		let graphWidth = chartWebview.frame.size.width
		let graphHeight = chartWebview.frame.size.height
		theTarget = target
		if let theTarget = theTarget {
			let progress = theTarget.calculateProgress(false)
			var hasStretch = false
			if (progress.completionPercentage >= 1.0) {
				let stretchTarget = dataManager.getStretchTargetForTarget(theTarget)
				if (stretchTarget != nil) {
					hasStretch = true
					let fillValue = stretchTarget!.calculateProgress()
					let htmlString = ChartHTMLManager.stretchTargetChartWithPercentage(fillValue, graphWidth: graphWidth, graphHeight: graphHeight)
					chartWebview.loadHTMLString(htmlString, baseURL: nil)
				}
			}
			if !hasStretch {
				let htmlString = ChartHTMLManager.simpleTargetChartWithPercentage(progress.completionPercentage, graphWidth: graphWidth, graphHeight: graphHeight)
				chartWebview.loadHTMLString(htmlString, baseURL: nil)
			}
			progressLabel.text = theTarget.progressText(progress)
			completeLabel.text = theTarget.progressText(progress)
		}
	}
	
	func setTargetIsComplete(_ complete:Bool) {
		if (complete) {
			starContainerView.alpha = 1.0
			progressLabel.alpha = 0.0
		} else {
			starContainerView.alpha = 0.0
			progressLabel.alpha = 1.0
		}
	}
}
