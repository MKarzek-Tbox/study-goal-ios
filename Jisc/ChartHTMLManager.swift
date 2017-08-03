//
//  ChartHTMLManager.swift
//  Jisc
//
//  Created by Paul on 4/7/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import Foundation

let kGraphWidthKey = "_graph_width_"
let kGraphHeightKey = "_graph_height_"
let kMyNameKey = "_my_name_"
let kMyValuesKey = "_my_values_"
let kOtherNameKey = "_other_name_"
let kOtherValuesKey = "_other_values_"
let kColumnNamesKey = "_column_names_"
let kYValueKey = "_y_value_"

class ChartHTMLManager {
	
	class func barChartWithMyValues(_ myValues:[Double], otherName:String?, otherValues:[Double]?, columnNames:[String], graphWidth:CGFloat, graphHeight:CGFloat) -> String {
		var barChartHTMLString = ""
		var simple = true
		if let otherName = otherName {
			if let otherValues = otherValues {
				simple = false
				if let path = Bundle.main.path(forResource: "BarChartHTMLCompare", ofType: "") {
					do {
						try barChartHTMLString = String(contentsOfFile: path)
						barChartHTMLString = barChartHTMLString.replacingOccurrences(of: kOtherNameKey, with: otherName)
						barChartHTMLString = barChartHTMLString.replacingOccurrences(of: kOtherValuesKey, with: "\(otherValues)")
					} catch {}
				}
			}
		}
		if simple {
			if let path = Bundle.main.path(forResource: "BarChartHTMLSimple", ofType: "") {
				do {
					try barChartHTMLString = String(contentsOfFile: path)
				} catch {}
			}
		}
		barChartHTMLString = barChartHTMLString.replacingOccurrences(of: kMyNameKey, with: "Me")
		barChartHTMLString = barChartHTMLString.replacingOccurrences(of: kMyValuesKey, with: "\(myValues)")
		var columnNameStrings = [String]()
		for (_, column) in columnNames.enumerated() {
			columnNameStrings.append("'\(column)'")
		}
		barChartHTMLString = barChartHTMLString.replacingOccurrences(of: kColumnNamesKey, with: columnNameStrings.joined(separator: ", "))
		barChartHTMLString = barChartHTMLString.replacingOccurrences(of: kGraphWidthKey, with: "\(graphWidth)")
		barChartHTMLString = barChartHTMLString.replacingOccurrences(of: kGraphHeightKey, with: "\(graphHeight)")
		return barChartHTMLString
	}
	
	class func lineChartWithMyValues(_ myValues:[Double], otherName:String?, otherValues:[Double]?, columnNames:[String], graphWidth:CGFloat, graphHeight:CGFloat) -> String {
		var lineChartHTMLString = ""
		var simple = true
		if let otherName = otherName {
			if let otherValues = otherValues {
				simple = false
				if let path = Bundle.main.path(forResource: "LineChartHTMLCompare", ofType: "") {
					do {
						try lineChartHTMLString = String(contentsOfFile: path)
						lineChartHTMLString = lineChartHTMLString.replacingOccurrences(of: kOtherNameKey, with: otherName)
						lineChartHTMLString = lineChartHTMLString.replacingOccurrences(of: kOtherValuesKey, with: "\(otherValues)")
					} catch {}
				}
			}
		}
		if simple {
			if let path = Bundle.main.path(forResource: "LineChartHTMLSimple", ofType: "") {
				do {
					try lineChartHTMLString = String(contentsOfFile: path)
				} catch {}
			}
		}
		lineChartHTMLString = lineChartHTMLString.replacingOccurrences(of: kMyNameKey, with: "Me")
		lineChartHTMLString = lineChartHTMLString.replacingOccurrences(of: kMyValuesKey, with: "\(myValues)")
		var columnNameStrings = [String]()
		for (_, column) in columnNames.enumerated() {
			columnNameStrings.append("'\(column)'")
		}
		lineChartHTMLString = lineChartHTMLString.replacingOccurrences(of: kColumnNamesKey, with: columnNameStrings.joined(separator: ", "))
		lineChartHTMLString = lineChartHTMLString.replacingOccurrences(of: kGraphWidthKey, with: "\(graphWidth)")
		lineChartHTMLString = lineChartHTMLString.replacingOccurrences(of: kGraphHeightKey, with: "\(graphHeight)")
		return lineChartHTMLString
	}
	
	class func simpleTargetChartWithPercentage(_ percentage:Double, graphWidth:CGFloat, graphHeight:CGFloat) -> String {
		var targetChartHTMLString = ""
		if let path = Bundle.main.path(forResource: "TargetGraphSimple", ofType: "") {
			do {
				try targetChartHTMLString = String(contentsOfFile: path)
			} catch {}
		}
		targetChartHTMLString = targetChartHTMLString.replacingOccurrences(of: kYValueKey, with: "\(percentage)")
		targetChartHTMLString = targetChartHTMLString.replacingOccurrences(of: kGraphWidthKey, with: "\(graphWidth)")
		targetChartHTMLString = targetChartHTMLString.replacingOccurrences(of: kGraphHeightKey, with: "\(graphHeight)")
		return targetChartHTMLString
	}
	
	class func stretchTargetChartWithPercentage(_ percentage:Double, graphWidth:CGFloat, graphHeight:CGFloat) -> String {
		var targetChartHTMLString = ""
		if let path = Bundle.main.path(forResource: "TargetGraphStretch", ofType: "") {
			do {
				try targetChartHTMLString = String(contentsOfFile: path)
			} catch {}
		}
		targetChartHTMLString = targetChartHTMLString.replacingOccurrences(of: kYValueKey, with: "\(percentage)")
		targetChartHTMLString = targetChartHTMLString.replacingOccurrences(of: kGraphWidthKey, with: "\(graphWidth)")
		targetChartHTMLString = targetChartHTMLString.replacingOccurrences(of: kGraphHeightKey, with: "\(graphHeight)")
		return targetChartHTMLString
	}
}
