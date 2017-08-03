//
//  EngagementGraphVC.swift
//  Jisc
//
//  Created by Therapy Box on 11/2/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

class EngagementGraphVC: BaseViewController, CustomPickerViewDelegate, UIScrollViewDelegate {
	
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var blueDot:UIImageView!
	@IBOutlet weak var comparisonStudentName:UILabel!
	var selectedModule:Int = 0
	var selectedPeriod:Int = 1 // 30 days
	var selectedStudent:Int = 0
	@IBOutlet weak var graphView:UIView!
	@IBOutlet weak var graphContainer:UIView!
	@IBOutlet weak var graphContainerWidth:NSLayoutConstraint!
	@IBOutlet weak var viewWithVerticalLabels:UIView!
	@IBOutlet weak var viewWithHorizontalLabels:UIView!
	var theGraphView:UIView?
	@IBOutlet weak var noDataLabel:UILabel!
	var weekDays = [localized("monday"), localized("tuesday"), localized("wednesday"), localized("thursday"), localized("friday"), localized("saturday"), localized("sunday")]
	
	@IBOutlet weak var moduleButton:UIButton!
	@IBOutlet weak var periodButton:UIButton!
	@IBOutlet weak var compareToButton:UIButton!
	var moduleSelectorView:CustomPickerView = CustomPickerView()
	var periodSelectorView:CustomPickerView = CustomPickerView()
	var compareToSelectorView:CustomPickerView = CustomPickerView()
	var initialGraphWidth:CGFloat = 0.0
	
	@IBOutlet weak var graphScroll:UIScrollView!
	@IBOutlet weak var scrollIndicator:UIView!
	@IBOutlet weak var indicatorLeading:NSLayoutConstraint!
	
	var friendsInModule = [Friend]()
	var graphValues:(me:[Double]?, myMax:Double, otherStudent:[Double]?, otherStudentMax:Double, columnNames:[String]?)? = nil
	var graphType = GraphType.Bar
	@IBOutlet weak var graphToggleButton:UIButton!
	@IBOutlet weak var compareToView:UIView!
	@IBOutlet weak var graphWebView:UIWebView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		scrollIndicator.alpha = 0.0
		graphType = GraphType.Bar
		graphToggleButton.isSelected = true
		compareToView.alpha = 0.5
		compareToView.isUserInteractionEnabled = false
		let today = todayNumber()
		var components = DateComponents()
		components.day = -(today - 1)
		let calendar = Calendar.current
		let firstDayOfTheWeek = (calendar as NSCalendar).date(byAdding: components, to: Date(), options: NSCalendar.Options.matchStrictly)!
		dateFormatter.dateFormat = "EEEE"
		let string = dateFormatter.string(from: firstDayOfTheWeek)
		
		if (localized("sunday").lowercased().contains(string.lowercased())) {
			weekDays = [localized("sunday"), localized("monday"), localized("tuesday"), localized("wednesday"), localized("thursday"), localized("friday"), localized("saturday")]
		}
		
		dateFormatter.dateFormat = "EEEE"
		let todayString = dateFormatter.string(from: Date())
		let todayIndex = weekDays.index(of: todayString)
		var tempDays = [String]()
		if (todayIndex != nil) {
			for  i in ((todayIndex! + 1)..<weekDays.count) {
				tempDays.append(weekDays[i])
			}
			for i in (0..<todayIndex! + 1) {
				tempDays.append(weekDays[i])
			}
		}
		weekDays = tempDays
		
		titleLabel.text = "\(localized("last_30_days")) \(localized("engagement"))"
		moduleButton.setTitle(localized("all_activity"), for: UIControlState())
		periodButton.setTitle(localized("last_30_days"), for: UIControlState())
		compareToButton.setTitle(localized("no_one"), for: UIControlState())
		
		blueDot.alpha = 0.0
		comparisonStudentName.alpha = 0.0
		
		initialGraphWidth = graphContainerWidth.constant
		
		getEngagementData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
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
	
	@IBAction func toggleGraphType(_ sender:UIButton) {
		sender.isSelected = !sender.isSelected
		if sender.isSelected {
			graphType = .Bar
		} else {
			graphType = .Line
		}
		representValues(graphValues)
	}
	
	func getEngagementData() {
		//		let myID = dataManager.currentStudent!.id
		let period = periods[selectedPeriod]
		var moduleID:String? = nil
		var courseID:String? = nil
		var studentID:String? = nil
		
		if (selectedModule > 0) {
			var theIndex = selectedModule - 1
			if (theIndex < dataManager.courses().count) {
				courseID = dataManager.courses()[theIndex].id
			} else {
				theIndex -= dataManager.courses().count
				if (theIndex < dataManager.modules().count) {
					moduleID = dataManager.modules()[theIndex].id
				}
			}
		}
		
		let friends = friendsInTheSameCourse()
		var getTopTenPercent = false
		var getAverage = false
		if (selectedStudent > 0) {
			let studentIndex = selectedStudent - 1
			if (studentIndex >= 0 && studentIndex < friends.count) {
				studentID = friends[studentIndex].jisc_id
//			} else if (selectedStudent == friends.count + 1) {
//				getTopTenPercent = true
//				studentID = "top_ten"
			} else if (selectedStudent == friends.count + 1) {
				getAverage = true
				studentID = "average"
			}
		}
		noDataLabel.alpha = 0.0
		graphContainer.alpha = 0.0
		setVerticalValues([""])
		setHorizontalValues([""])
		
		let completion:downloadCompletionBlock = {(success, result, results, error) in
			self.graphValues = nil
			if (success) {
				self.graphValues = self.xAPIEngagementDataValues(period, moduleID: moduleID, studentID: studentID, result: result, results: results)
				if let status = result?["status"] as? String {
					if status == "error" {
						self.graphValues = nil
					}
				}
			}
			self.representValues(self.graphValues)
			self.indicatorLeading.constant = 0.0
			self.view.layoutIfNeeded()
			if (self.graphScroll.contentSize.width > self.graphScroll.frame.size.width) {
				self.scrollIndicator.alpha = 1.0
			} else {
				self.scrollIndicator.alpha = 0.0
			}
		}
		
		var requestOptions = EngagementGraphOptions(scope: nil, filterType: nil, filterValue: nil, compareType: nil, compareValue: nil)
		if period != .Overall {
			requestOptions.scope = period
		}
		if let moduleID = moduleID {
			requestOptions.filterType = .Module
			requestOptions.filterValue = moduleID
		} else if let courseID = courseID {
			requestOptions.filterType = .Course
			requestOptions.filterValue = courseID
		}
		if getTopTenPercent {
			requestOptions.compareType = .Top
			requestOptions.compareValue = "10"
		} else if getAverage {
			requestOptions.compareType = .Average
		} else if let studentID = studentID {
			requestOptions.compareType = .Friend
			requestOptions.compareValue = studentID
		}
		if staff() {
			completion(true, nil, nil, nil)
		} else {
			xAPIManager().getEngagementData(requestOptions, completion: completion)
		}
	}
	
	func representValues(_ sender:(me:[Double]?, myMax:Double, otherStudent:[Double]?, otherStudentMax:Double, columnNames:[String]?)?) {
		var htmlString = ""
		if let sender = sender {
			let otherName = comparisonStudentName.text
			let graphWidth = graphWebView.frame.size.width * 0.93984962// * UIScreen.main.scale
			let graphHeight = graphWebView.frame.size.height * 0.91// * UIScreen.main.scale
			if let columnNames = sender.columnNames {
				if let otherValues = sender.otherStudent {
					if let myValues = sender.me {
						if graphType == .Bar {
							htmlString = ChartHTMLManager.barChartWithMyValues(myValues, otherName: otherName, otherValues: otherValues, columnNames: columnNames, graphWidth: graphWidth, graphHeight: graphHeight)
						} else if graphType == .Line {
							htmlString = ChartHTMLManager.lineChartWithMyValues(myValues, otherName: otherName, otherValues: otherValues, columnNames: columnNames, graphWidth: graphWidth, graphHeight: graphHeight)
						}
					}
				} else if let myValues = sender.me {
					if graphType == .Bar {
						htmlString = ChartHTMLManager.barChartWithMyValues(myValues, otherName: nil, otherValues: nil, columnNames: columnNames, graphWidth: graphWidth, graphHeight: graphHeight)
					} else if graphType == .Line {
						htmlString = ChartHTMLManager.lineChartWithMyValues(myValues, otherName: nil, otherValues: nil, columnNames: columnNames, graphWidth: graphWidth, graphHeight: graphHeight)
					}
				}
			}
		}
		graphWebView.loadHTMLString(htmlString, baseURL: nil)
		graphWebView.scrollView.isScrollEnabled = false
//		if (sender != nil) {
//			if (sender!.columnNames != nil) {
//				if (sender!.columnNames!.count > 7) {
//					graphContainerWidth.constant = min(60.0 * (CGFloat)(sender!.columnNames!.count), 8000.0)
//				} else {
//					graphContainerWidth.constant = initialGraphWidth
//				}
//				view.layoutIfNeeded()
//			} else {
//				graphContainerWidth.constant = initialGraphWidth
//				view.layoutIfNeeded()
//			}
//		} else {
//			graphContainerWidth.constant = initialGraphWidth
//			view.layoutIfNeeded()
//		}
//		
//		theGraphView?.removeFromSuperview()
//		graphScroll.setContentOffset(CGPoint.zero, animated: false)
//		if var values = sender {
//			graphContainer.alpha = 1.0
//			var maximum = Double(0.0)
//			if (values.me != nil) {
//				for (_, item) in values.me!.enumerated() {
//					maximum = max(maximum, item)
//				}
//			}
//			if (values.otherStudent != nil) {
//				for (_, item) in values.otherStudent!.enumerated() {
//					maximum = max(maximum, item)
//				}
//			}
//			if (maximum > 3) {
//				self.setVerticalValues(["0", "\(Int(maximum * 0.25))", "\(Int(maximum * 0.5))", "\(Int(maximum * 0.75))", "\(Int(maximum))"])
//			} else if (maximum >= 2) {
//				self.setVerticalValues(["0", "1", "\(Int(maximum))"])
//			} else {
//				self.setVerticalValues(["0", "1"])
//			}
//			if (values.columnNames != nil) {
//				self.setHorizontalValues(values.columnNames!)
//			}
//			let frame = graphContainer.bounds
//			var myV:[Double]?
//			var hisV:[Double]?
//			if (values.me != nil) {
//				if (values.me!.count < 3) {
//					values.me!.insert(0.0, at: 0)
//					values.me!.append(0.0)
//				}
//				myV = values.me
//			}
//			if (values.otherStudent != nil) {
//				if (values.otherStudent!.count < 3) {
//					values.otherStudent!.insert(0.0, at: 0)
//					values.otherStudent!.append(0.0)
//				}
//				hisV = values.otherStudent
//			}
//			
//			if (maximum == 0.0) {
//				noDataLabel.alpha = 1.0
//				graphContainer.alpha = 0.0
//				setVerticalValues([])
//				setHorizontalValues([])
//			} else {
//				if (myV != nil) {
//					if (hisV != nil) {
//						switch graphType {
//						case .Line:
//							theGraphView = GraphGenerator.drawLineGraphInView(graphContainer, frame: frame, values: [myV!, hisV!], colors: [myColor, otherStudentColor], animationDuration: 0.0)
//							break
//						case .Bar:
//							theGraphView = GraphGenerator.drawBarChartInView(graphContainer, frame: frame, values: [myV!, hisV!], colors: [myColor, otherStudentColor])
//							break
//						}
//					} else {
//						switch graphType {
//						case .Line:
//							theGraphView = GraphGenerator.drawLineGraphInView(graphContainer, frame: frame, values: [myV!], colors: [myColor], animationDuration: 0.0)
//							break
//						case .Bar:
//							theGraphView = GraphGenerator.drawBarChartInView(graphContainer, frame: frame, values: [myV!], colors: [myColor])
//							break
//						}
//					}
//				} else if (hisV != nil) {
//					switch graphType {
//					case .Line:
//						theGraphView = GraphGenerator.drawLineGraphInView(graphContainer, frame: frame, values: [hisV!], colors: [otherStudentColor], animationDuration: 0.0)
//						break
//					case .Bar:
//						theGraphView = GraphGenerator.drawBarChartInView(graphContainer, frame: frame, values: [hisV!], colors: [otherStudentColor])
//						break
//					}
//				}
//			}
//		} else {
//			noDataLabel.alpha = 1.0
//		}
	}
	
	//MARK: xAPI
	
	func xAPIEngagementDataValues(_ period:kXAPIEngagementScope, moduleID:String?, studentID:String?, result:NSDictionary?, results:NSArray?) -> (me:[Double]?, myMax:Double, otherStudent:[Double]?, otherStudentMax:Double, columnNames:[String]?)? {
		var values:([Double]?, Double, [Double]?, Double, [String]?)? = nil
		var myValues:[Double]? = nil
		var myMax:Double = 0.0
		var otherStudentValues:[Double]? = nil
		var otherStudentMax:Double = 0.0
		var columnNames:[String]? = nil
		if staff() {
			switch (period) {
			case .Overall:
				dateFormatter.dateFormat = "yyyy"
				let thisYear = dateFormatter.string(from: Date())
				dateFormatter.dateFormat = "dd-MM-yyyy"
				if var firstDay = dateFormatter.date(from: "01-01-\(thisYear)") {
					columnNames = [String]()
					myValues = [Double]()
					if studentID != nil {
						otherStudentValues = [Double]()
					}
					var dates = [Date]()
					while firstDay.compare(Date()) == .orderedAscending {
						dates.append(firstDay)
						var sw = arc4random() % 4
						if sw == 0 {
							myValues?.append(0.0)
						} else {
							myValues?.append(Double(arc4random() % 100))
						}
						if studentID != nil {
							sw = arc4random() % 4
							if sw == 0 {
								otherStudentValues?.append(0.0)
							} else {
								otherStudentValues?.append(Double(arc4random() % 100))
							}
						}
						let daysToAdd = Double((arc4random() % 5) + 1)
						firstDay = firstDay.addingTimeInterval(daysToAdd * 86400.0)
					}
					for (_, item) in dates.enumerated() {
						dateFormatter.dateFormat = "dd MMM"
						let month = dateFormatter.string(from: item)
						dateFormatter.dateFormat = "yy"
						let year = dateFormatter.string(from: item)
						columnNames?.append("\(month) '\(year)")
					}
				} else {
					columnNames = columnNamesXAPI30Days()
					myValues = [Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1)]
					if studentID != nil {
						otherStudentValues = [Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1)]
					}
				}
				break
			case .SevenDays:
				columnNames = [String]()
				for _ in 0..<7 {
					columnNames?.append("")
				}
				let today = Date()
				for index in 0..<7 {
					let timeDifference = (Double)(index - 6) * 86400.0
					let dateToPut = Date(timeInterval: timeDifference, since: today)
					dateFormatter.dateFormat = "dd/MM"
					columnNames![index] = dateFormatter.string(from: dateToPut)
				}
				
				myValues = [Double]()
				if studentID != nil {
					otherStudentValues = [Double]()
				}
				for (_, _) in columnNames!.enumerated() {
					myValues!.append(Double((arc4random() % 100) + 1))
					if studentID != nil {
						otherStudentValues!.append(Double((arc4random() % 100) + 1))
					}
				}
				break
			case .ThirtyDays:
				columnNames = columnNamesXAPI30Days()
				myValues = [Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1)]
				if studentID != nil {
					otherStudentValues = [Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1), Double((arc4random() % 100) + 1)]
				}
				break
			}
			
			if (myValues != nil) {
				for (_, item) in myValues!.enumerated() {
					if (myMax < item) {
						myMax = item
					}
				}
			}
			
			if (otherStudentValues != nil) {
				for (_, item) in otherStudentValues!.enumerated() {
					if (otherStudentMax < item) {
						otherStudentMax = item
					}
				}
			}
		} else {
			switch (period) {
			case .Overall:
				if (result != nil) {
					if let pointsArray = result!["result"] as? NSArray {
						let info = infoFromXAPIOverall(pointsArray)
						let dates = info.dates
						myValues = info.myValues
						otherStudentValues = info.otherValues
						columnNames = [String]()
						for (_, item) in dates.enumerated() {
							dateFormatter.dateFormat = "dd MMM"
							let month = dateFormatter.string(from: item)
							dateFormatter.dateFormat = "yy"
							let year = dateFormatter.string(from: item)
							columnNames?.append("\(month) '\(year)")
						}
					}
				}
				break
			case .SevenDays:
				columnNames = [String]()
				for _ in 0..<7 {
					columnNames?.append("")
				}
				let today = Date()
				for index in 0..<7 {
					let timeDifference = (Double)(index - 6) * 86400.0
					let dateToPut = Date(timeInterval: timeDifference, since: today)
					dateFormatter.dateFormat = "dd/MM"
					columnNames![index] = dateFormatter.string(from: dateToPut)
				}
				
				myValues = [Double]()
				for (_, _) in columnNames!.enumerated() {
					myValues!.append(0.0)
				}
				
				if (result != nil) {
					if var keys = result!.allKeys as? [String] {
						keys.sort(by: { (obj1:String, obj2:String) -> Bool in
							let value1 = (obj1 as NSString).integerValue
							let value2 = (obj2 as NSString).integerValue
							var sorted = true
							if value1 > value2 {
								sorted = false
							}
							return sorted
						})
						for (index, item) in keys.enumerated() {
							myValues![index] = doubleFromDictionary(result!, key: item)
						}
					}
				} else if let results = results as? [NSDictionary] {
					otherStudentValues = [Double]()
					for (_, _) in columnNames!.enumerated() {
						otherStudentValues!.append(0.0)
					}
					for (_, dictionary) in results.enumerated() {
						if let values = dictionary["VALUES"] as? NSDictionary {
							if var keys = values.allKeys as? [String] {
								keys.sort(by: { (obj1:String, obj2:String) -> Bool in
									let value1 = (obj1 as NSString).integerValue
									let value2 = (obj2 as NSString).integerValue
									var sorted = true
									if value1 > value2 {
										sorted = false
									}
									return sorted
								})
								let studentID = stringFromDictionary(dictionary, key: "STUDENT_ID")
								if demo() {
									if studentID.lowercased() == "demouser" {
										for (index, item) in keys.enumerated() {
											myValues![index] = doubleFromDictionary(values, key: item)
										}
									} else {
										for (index, item) in keys.enumerated() {
											otherStudentValues![index] = doubleFromDictionary(values, key: item)
										}
									}
								} else {
									if studentID.contains(dataManager.currentStudent!.jisc_id) {
										for (index, item) in keys.enumerated() {
											myValues![index] = doubleFromDictionary(values, key: item)
										}
									} else {
										for (index, item) in keys.enumerated() {
											otherStudentValues![index] = doubleFromDictionary(values, key: item)
										}
									}
								}
							}
						}
					}
				}
				
				break
			case .ThirtyDays:
				columnNames = columnNamesXAPI30Days()
				myValues = [0.0, 0.0, 0.0, 0.0]
				if (result != nil) {
					if let keys = result!.allKeys as? [String] {
						for (_, item) in keys.enumerated() {
							let absValue = abs((item as NSString).integerValue)
							if (absValue < 7) {
								myValues![3] = myValues![3] + doubleFromDictionary(result!, key: item)
							} else if (absValue < 14) {
								myValues![2] = myValues![2] + doubleFromDictionary(result!, key: item)
							} else if (absValue < 21) {
								myValues![1] = myValues![1] + doubleFromDictionary(result!, key: item)
							} else {
								myValues![0] = myValues![0] + doubleFromDictionary(result!, key: item)
							}
						}
					}
				} else if let results = results as? [NSDictionary] {
					otherStudentValues = [0.0, 0.0, 0.0, 0.0]
					for (_, dictionary) in results.enumerated() {
						if let values = dictionary["VALUES"] as? NSDictionary {
							let studentID = stringFromDictionary(dictionary, key: "STUDENT_ID")
							if demo() {
								if studentID.lowercased() == "demouser" {
									if let keys = values.allKeys as? [String] {
										for (_, item) in keys.enumerated() {
											let absValue = abs((item as NSString).integerValue)
											if (absValue < 7) {
												myValues![3] = myValues![3] + doubleFromDictionary(values, key: item)
											} else if (absValue < 14) {
												myValues![2] = myValues![2] + doubleFromDictionary(values, key: item)
											} else if (absValue < 21) {
												myValues![1] = myValues![1] + doubleFromDictionary(values, key: item)
											} else {
												myValues![0] = myValues![0] + doubleFromDictionary(values, key: item)
											}
										}
									}
								} else {
									if let keys = values.allKeys as? [String] {
										for (_, item) in keys.enumerated() {
											let absValue = abs((item as NSString).integerValue)
											if (absValue < 7) {
												otherStudentValues![3] = otherStudentValues![3] + doubleFromDictionary(values, key: item)
											} else if (absValue < 14) {
												otherStudentValues![2] = otherStudentValues![2] + doubleFromDictionary(values, key: item)
											} else if (absValue < 21) {
												otherStudentValues![1] = otherStudentValues![1] + doubleFromDictionary(values, key: item)
											} else {
												otherStudentValues![0] = otherStudentValues![0] + doubleFromDictionary(values, key: item)
											}
										}
									}
								}
							} else {
								if studentID.contains(dataManager.currentStudent!.jisc_id) {
									if let keys = values.allKeys as? [String] {
										for (_, item) in keys.enumerated() {
											let absValue = abs((item as NSString).integerValue)
											if (absValue < 7) {
												myValues![3] = myValues![3] + doubleFromDictionary(values, key: item)
											} else if (absValue < 14) {
												myValues![2] = myValues![2] + doubleFromDictionary(values, key: item)
											} else if (absValue < 21) {
												myValues![1] = myValues![1] + doubleFromDictionary(values, key: item)
											} else {
												myValues![0] = myValues![0] + doubleFromDictionary(values, key: item)
											}
										}
									}
								} else {
									if let keys = values.allKeys as? [String] {
										for (_, item) in keys.enumerated() {
											let absValue = abs((item as NSString).integerValue)
											if (absValue < 7) {
												otherStudentValues![3] = otherStudentValues![3] + doubleFromDictionary(values, key: item)
											} else if (absValue < 14) {
												otherStudentValues![2] = otherStudentValues![2] + doubleFromDictionary(values, key: item)
											} else if (absValue < 21) {
												otherStudentValues![1] = otherStudentValues![1] + doubleFromDictionary(values, key: item)
											} else {
												otherStudentValues![0] = otherStudentValues![0] + doubleFromDictionary(values, key: item)
											}
										}
									}
								}
							}
						}
					}
				}
				break
			}
			
			if (myValues != nil) {
				for (_, item) in myValues!.enumerated() {
					if (myMax < item) {
						myMax = item
					}
				}
			}
			
			if (otherStudentValues != nil) {
				for (_, item) in otherStudentValues!.enumerated() {
					if (otherStudentMax < item) {
						otherStudentMax = item
					}
				}
			}
		}
		values = (myValues, myMax, otherStudentValues, otherStudentMax, columnNames)
		
		return values
	}
	
	func infoFromXAPIOverall(_ array:NSArray) -> (dates:[Date], myValues:[Double], otherValues:[Double]?) {
		var dates = [Date]()
		var myValues = [Double]()
		var otherValues:[Double]? = [Double]()
		var weHaveOtherValues = false
		dateFormatter.dateFormat = "yyyy-MM-dd"
		for (index, item) in array.enumerated() {
			if let dictionary = item as? NSDictionary {
				let dateString = stringFromDictionary(dictionary, key: "_id")
				if let date = dateFormatter.date(from: dateString) {
					dates.append(date)
				}
				myValues.append(0.0)
				otherValues?.append(0.0)
				if let data = dictionary["data"] as? NSArray {
					if (data.count > 0) {
						if let dictionary = data[0] as? NSDictionary {
							let id = stringFromDictionary(dictionary, key: "record")
							if id == dataManager.currentStudent!.jisc_id {
								myValues[index] = doubleFromDictionary(dictionary, key: "totalPoints")
							} else {
								otherValues?[index] = doubleFromDictionary(dictionary, key: "totalPoints")
								weHaveOtherValues = true
							}
						}
					}
				}
			}
		}
		if !weHaveOtherValues {
			otherValues = nil
		}
		return (dates, myValues, otherValues)
	}
	
	func datesFromXAPIOverallWithModule(_ array:NSArray) -> [Date] {
		var dates = [Date]()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		for (_, item) in array.enumerated() {
			if let dateString = item as? String {
				if let date = dateFormatter.date(from: dateString) {
					dates.append(date)
				}
			}
		}
		return dates
	}
	
	func myValuesForXAPIOverall(_ array:NSArray) -> [Double] {
		var values = [Double]()
		for (_, item) in array.enumerated() {
			if let dictionary = item as? NSDictionary {
				if let data = dictionary["data"] as? NSArray {
					if (data.count > 0) {
						if let dictionary = data[0] as? NSDictionary {
							let id = stringFromDictionary(dictionary, key: "record")
							if id == dataManager.currentStudent!.jisc_id {
								values.append(doubleFromDictionary(dictionary, key: "totalPoints"))
							}
						}
					}
				}
			}
		}
		return values
	}
	
	func otherValuesForXAPIOverall(_ array:NSArray) -> [Double] {
		var values = [Double]()
		for (_, item) in array.enumerated() {
			if let dictionary = item as? NSDictionary {
				if let data = dictionary["data"] as? NSArray {
					if (data.count > 0) {
						if let dictionary = data[0] as? NSDictionary {
							let id = stringFromDictionary(dictionary, key: "record")
							if id != dataManager.currentStudent!.jisc_id {
								values.append(doubleFromDictionary(dictionary, key: "totalPoints"))
							}
						}
					}
				}
			}
		}
		return values
	}
	
	func myValuesForXAPIOverallWithModule(_ array:NSArray) -> [Double] {
		var values = [Double]()
		for (_, item) in array.enumerated() {
			if let dictionary = item as? NSDictionary {
				if let data = dictionary["data"] as? NSArray {
					if (data.count > 0) {
						if let dictionary = data[0] as? NSDictionary {
							values.append(doubleFromDictionary(dictionary, key: "totalPoints"))
						}
					}
				}
			}
		}
		return values
	}
	
	func otherForXAPIOverallWithModule(_ array:NSArray) -> [Double] {
		var values = [Double]()
		for (_, item) in array.enumerated() {
			if let dictionary = item as? NSDictionary {
				values.append(doubleFromDictionary(dictionary, key: "group"))
			}
		}
		return values
	}
	
	func otherForXAPIOverallTenPercent(_ array:NSArray) -> [Double] {
		var values = [Double]()
		for (_, item) in array.enumerated() {
			if let dictionary = item as? NSDictionary {
				values.append(doubleFromDictionary(dictionary, key: "top10"))
			}
		}
		return values
	}
	
	func columnNamesXAPI30Days() -> [String] {
		var names:[String] = [String]()
		dateFormatter.dateFormat = "yyyy/M"
		let calendar = Calendar.current
		var dayComponent = DateComponents()
		dayComponent.day = 6
		
		var dates = [Date]()
		dates.append(Date().addingTimeInterval(-(86400.0 * 6)))
		dates.append(Date().addingTimeInterval(-(86400.0 * 13)))
		dates.append(Date().addingTimeInterval(-(86400.0 * 20)))
		dates.append(Date().addingTimeInterval(-(86400.0 * 27)))
		
		for (_, item) in dates.enumerated() {
//			dateFormatter.dateFormat = "d"
//			let firstDay = NSString(format: "%@", dateFormatter.string(from: item)).integerValue
			let lastDayDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: item, options: .matchStrictly)
//			var lastDay = firstDay + 6
//			var lastDayMonth = ""
//			if (lastDayDate != nil) {
//				lastDay = NSString(format: "%@", dateFormatter.string(from: lastDayDate!)).integerValue
//				dateFormatter.dateFormat = "MM"
//				lastDayMonth = dateFormatter.string(from: lastDayDate!)
//			}
//			dateFormatter.dateFormat = "MM"
//			let month = dateFormatter.string(from: item)
//			if (lastDayMonth.isEmpty || lastDayMonth == month) {
//				names.append("\(month)/\(firstDay)-\(lastDay)")
//			} else {
//				names.append("\(month)/\(firstDay)-\(lastDayMonth)/\(lastDay)")
//			}
			dateFormatter.dateFormat = "dd/MM/yyyy"
			if let date = lastDayDate {
				names.append(dateFormatter.string(from: date))
			}
		}
		return names.reversed()
	}
	
	//MARK: Graph Values
	
	func setVerticalValues(_ values:[String]) {
		cleanSubviews(viewWithVerticalLabels)
		var lastLabel:UILabel?
		var lastSeparator:UIView?
		for (_, item) in values.enumerated() {
			let label = createLegendLabel()
			label.text = item
			addSubview(label, firstAttribute: .leading, secondAttribute: .trailing, superview: viewWithVerticalLabels)
			let separator = UIView()
			separator.translatesAutoresizingMaskIntoConstraints = false
			addSubview(separator, firstAttribute: .leading, secondAttribute: .trailing, superview: viewWithVerticalLabels)
			let topConstraint = makeConstraint(label, attribute1: .top, relation: .equal, item2: separator, attribute2: .bottom, multiplier: 1.0, constant: 0.0)
			viewWithVerticalLabels.addConstraint(topConstraint)
			if (lastLabel == nil) {
				let bottomConstraint = makeConstraint(viewWithVerticalLabels, attribute1: .bottom, relation: .equal, item2: label, attribute2: .bottom, multiplier: 1.0, constant: 0.0)
				viewWithVerticalLabels.addConstraint(bottomConstraint)
			} else if (lastSeparator != nil) {
				let bottomConstraint = makeConstraint(lastSeparator!, attribute1: .top, relation: .equal, item2: label, attribute2: .bottom, multiplier: 1.0, constant: 0.0)
				viewWithVerticalLabels.addConstraint(bottomConstraint)
				let heightConstraint = makeConstraint(lastSeparator!, attribute1: .height, relation: .equal, item2: separator, attribute2: .height, multiplier: 1.0, constant: 0.0)
				viewWithVerticalLabels.addConstraint(heightConstraint)
			}
			lastLabel = label
			lastSeparator = separator
		}
		lastSeparator?.removeFromSuperview()
		if (lastLabel != nil) {
			let topConstraint = makeConstraint(lastLabel!, attribute1: .top, relation: .equal, item2: viewWithVerticalLabels, attribute2: .top, multiplier: 1.0, constant: 0.0)
			viewWithVerticalLabels.addConstraint(topConstraint)
		}
	}
	
	func setHorizontalValues(_ values:[String]) {
		cleanSubviews(viewWithHorizontalLabels)
		var lastView:UIView?
		for (_, item) in values.enumerated() {
			let label = createLegendLabel()
			label.text = item
			viewWithHorizontalLabels.addSubview(label)
			let topConstraint = makeConstraint(viewWithHorizontalLabels, attribute1: .top, relation: .equal, item2: label, attribute2: .top, multiplier: 1.0, constant: 0.0)
			let bottomConstraint = makeConstraint(viewWithHorizontalLabels, attribute1: .bottom, relation: .equal, item2: label, attribute2: .bottom, multiplier: 1.0, constant: 0.0)
			var leftConstraint:NSLayoutConstraint
			if (lastView != nil) {
				leftConstraint = makeConstraint(lastView!, attribute1: .trailing, relation: .equal, item2: label, attribute2: .leading, multiplier: 1.0, constant: 0.0)
				let widthConstraint = makeConstraint(lastView!, attribute1: .width, relation: .equal, item2: label, attribute2: .width, multiplier: 1.0, constant: 0.0)
				viewWithHorizontalLabels.addConstraint(widthConstraint)
			} else {
				leftConstraint = makeConstraint(viewWithHorizontalLabels, attribute1: .leading, relation: .equal, item2: label, attribute2: .leading, multiplier: 1.0, constant: 0.0)
			}
			viewWithHorizontalLabels.addConstraints([topConstraint, bottomConstraint, leftConstraint])
			lastView = label
		}
		if (lastView != nil) {
			let rightConstraint = makeConstraint(lastView!, attribute1: .trailing, relation: .equal, item2: viewWithHorizontalLabels, attribute2: .trailing, multiplier: 1.0, constant: 0.0)
			viewWithHorizontalLabels.addConstraint(rightConstraint)
		}
	}
	
	func cleanSubviews(_ view:UIView) {
		while (view.subviews.count > 0) {
			view.subviews.first?.removeFromSuperview()
		}
	}
	
	func createLegendLabel() -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.textColor = UIColor.darkGray
		label.font = myriadProLight(12)
		label.backgroundColor = UIColor.clear
		label.adjustsFontSizeToFitWidth = true
		return label
	}
	
	func addSubview(_ view:UIView, firstAttribute:NSLayoutAttribute, secondAttribute:NSLayoutAttribute, superview:UIView) {
		superview.addSubview(view)
		let firstConstraint = makeConstraint(superview, attribute1: firstAttribute, relation: .equal, item2: view, attribute2: firstAttribute, multiplier: 1.0, constant: 0.0)
		let secondConstraint = makeConstraint(superview, attribute1: secondAttribute, relation: .equal, item2: view, attribute2: secondAttribute, multiplier: 1.0, constant: 0.0)
		superview.addConstraints([firstConstraint, secondConstraint])
	}
	
	//MARK: Show/Close Selectors
	
	@IBAction func showModuleSelector(_ sender:UIButton) {
		graphScroll.setContentOffset(graphScroll.contentOffset, animated: false)
		var array:[String] = [String]()
		array.append(localized("all_activity"))
		var centeredIndexes = [Int]()
		for (_, item) in dataManager.courses().enumerated() {
			centeredIndexes.append(array.count)
			array.append(item.name)
		}
		for (_, item) in dataManager.modules().enumerated() {
			array.append(" - \(item.name)")
		}
		moduleSelectorView = CustomPickerView.create(localized("filter"), delegate: self, contentArray: array, selectedItem: selectedModule)
		moduleSelectorView.centerIndexes = centeredIndexes
		view.addSubview(moduleSelectorView)
	}
	
	@IBAction func showPeriodSelector(_ sender:UIButton) {
		graphScroll.setContentOffset(graphScroll.contentOffset, animated: false)
		var array:[String] = [String]()
		//array.append(localized("overall"))
		array.append(localized("last_7_days"))
		array.append(localized("last_30_days"))
		periodSelectorView = CustomPickerView.create(localized("choose_period"), delegate: self, contentArray: array, selectedItem: selectedPeriod)
		view.addSubview(periodSelectorView)
	}
	
	@IBAction func showCompareToSelector(_ sender:UIButton) {
		graphScroll.setContentOffset(graphScroll.contentOffset, animated: false)
		if (selectedModule == 0) {
			var array:[String] = [String]()
			array.append(localized("no_one"))
			let colleagues = friendsInTheSameCourse()
			for (_, item) in colleagues.enumerated() {
				array.append("\(item.firstName) \(item.lastName)")
			}
			if array.count > 1 {
				compareToSelectorView = CustomPickerView.create(localized("choose_student"), delegate: self, contentArray: array, selectedItem: selectedStudent)
				view.addSubview(compareToSelectorView)
			}
		} else {
			var array:[String] = [String]()
			array.append(localized("no_one"))
			let colleagues = friendsInTheSameCourse()
			for (_, item) in colleagues.enumerated() {
				array.append("\(item.firstName) \(item.lastName)")
			}
			//			array.append(localized("top_10_percent"))
			array.append(localized("average"))
			compareToSelectorView = CustomPickerView.create(localized("choose_student"), delegate: self, contentArray: array, selectedItem: selectedStudent)
			view.addSubview(compareToSelectorView)
		}
	}
	
	func friendsInTheSameCourse() -> [Friend] {
		var array:[Friend] = [Friend]()
		
		//		for (_, colleague) in dataManager.studentsInTheSameCourse().enumerate() {
		//			var colleagueIsFriend = false
		//			for (_, friend) in dataManager.friends().enumerate() {
		//				if (colleague.id == friend.id) {
		//					colleagueIsFriend = true
		//					break
		//				}
		//			}
		//			if (colleagueIsFriend) {
		//				array.append(colleague)
		//			}
		//		}
		
		for (_, friend) in dataManager.friends().enumerated() {
			if (!friend.jisc_id.isEmpty) {
				array.append(friend)
			}
		}
		
		return array
	}
	
	//MARK: CustomPickerView Delegate
	
	func view(_ view: CustomPickerView, selectedRow: Int) {
		
		switch (view) {
		case moduleSelectorView:
			if (selectedModule != selectedRow) {
				compareToView.alpha = 1.0
				compareToView.isUserInteractionEnabled = true
				if (selectedModule == 0) {
					if (selectedStudent != 0) {
						compareToButton.setTitle(localized("no_one"), for: UIControlState())
						compareToView.alpha = 0.5
						compareToView.isUserInteractionEnabled = false
						selectedStudent = 0
					}
				}
				selectedModule = selectedRow
				moduleButton.setTitle(view.contentArray[selectedRow], for: UIControlState())
				let moduleIndex = selectedModule - (1 + dataManager.courses().count)
				if (moduleIndex >= 0 && moduleIndex < dataManager.modules().count) {
					moduleButton.setTitle(dataManager.modules()[moduleIndex].name, for: UIControlState())
				}
				if (selectedModule == 0) {
					friendsInModule.removeAll()
					selectedStudent = 0
					compareToButton.setTitle(localized("no_one"), for: UIControlState())
					compareToView.alpha = 0.5
					compareToView.isUserInteractionEnabled = false
					UIView.animate(withDuration: 0.25, animations: { () -> Void in
						self.blueDot.alpha = 0.0
						self.comparisonStudentName.alpha = 0.0
					})
				} else if (moduleIndex >= 0 && moduleIndex < dataManager.modules().count) {
					DownloadManager().getFriendsByModule(dataManager.currentStudent!.id, module: dataManager.modules()[moduleIndex].id, alertAboutInternet: false, completion: { (success, result, results, error) in
						if let array = results {
							print("ARRAY: \(array)")
						}
					})
				}
				getEngagementData()
			}
			break
		case periodSelectorView:
			if (selectedPeriod != selectedRow) {
				selectedPeriod = selectedRow
				if (selectedPeriod != 0) {
					if (selectedModule == 0) {
						compareToButton.setTitle(localized("no_one"), for: UIControlState())
						selectedStudent = 0
					}
				}
				periodButton.setTitle(view.contentArray[selectedRow], for: UIControlState())
				titleLabel.text = "\(view.contentArray[selectedRow]) \(localized("engagement"))"
				getEngagementData()
			}
			break
		case compareToSelectorView:
			if (selectedStudent != selectedRow) {
				selectedStudent = selectedRow
				if (selectedStudent == 0) {
					compareToButton.setTitle(localized("no_one"), for: UIControlState())
					UIView.animate(withDuration: 0.25, animations: { () -> Void in
						self.blueDot.alpha = 0.0
						self.comparisonStudentName.alpha = 0.0
					})
				} else if ((selectedStudent - 1) < friendsInTheSameCourse().count) {
					let student = friendsInTheSameCourse()[selectedStudent - 1]
					compareToButton.setTitle("\(student.firstName) \(student.lastName)", for: UIControlState())
					comparisonStudentName.text = "\(student.firstName) \(student.lastName)"
					UIView.animate(withDuration: 0.25, animations: { () -> Void in
						self.blueDot.alpha = 1.0
						self.comparisonStudentName.alpha = 1.0
					})
					//				} else if (selectedStudent == friendsInTheSameCourse().count + 1) {
					//					compareToButton.setTitle(localized("top_10_percent"), for: UIControlState())
					//					comparisonStudentName.text = localized("top_10_percent")
					//					UIView.animate(withDuration: 0.25, animations: { () -> Void in
					//						self.blueDot.alpha = 1.0
					//						self.comparisonStudentName.alpha = 1.0
					//					})
					//				} else if (selectedStudent == friendsInTheSameCourse().count + 2) {
				} else if (selectedStudent == friendsInTheSameCourse().count + 1) {
					compareToButton.setTitle(localized("average"), for: UIControlState())
					comparisonStudentName.text = localized("average")
					UIView.animate(withDuration: 0.25, animations: { () -> Void in
						self.blueDot.alpha = 1.0
						self.comparisonStudentName.alpha = 1.0
					})
				}
				getEngagementData()
			}
			break
		default:break
		}
	}
	
	//MARK: UIScrollView Delegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let maximumIndicatorPosition = scrollView.frame.size.width - scrollIndicator.frame.size.width
		let maximumOffset = scrollView.contentSize.width - scrollView.frame.size.width
		if (maximumOffset != 0.0) {
			let offsetPercentage = scrollView.contentOffset.x / maximumOffset
			let currentIndicatorPosition = maximumIndicatorPosition * offsetPercentage
			indicatorLeading.constant = currentIndicatorPosition + scrollView.contentOffset.x
			view.layoutIfNeeded()
		}
	}
}
