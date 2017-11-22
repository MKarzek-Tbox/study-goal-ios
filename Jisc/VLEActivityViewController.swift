//
//  VLEActivityViewController.swift
//  Jisc
//
//  Created by therapy box on 13/10/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class VLEActivityViewController: UIViewController, CustomPickerViewDelegate {

    @IBOutlet weak var segmentControl:UISegmentedControl!
    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var webViewLineiPad:UIWebView!
    @IBOutlet weak var webViewNullMessage:UILabel!

    @IBOutlet weak var startDateField:UITextField!
    @IBOutlet weak var endDateField:UITextField!
    
    @IBOutlet weak var moduleButton:UIButton!
    @IBOutlet weak var compareToButton:UIButton!
    
    @IBOutlet weak var sevenDaysSelectorButton:UIButton!
    @IBOutlet weak var twentyEightDaysSelectorButton:UIButton!
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "dd/MM/yyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    let databaseDateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    
    var moduleSelectorView:CustomPickerView = CustomPickerView()
    var selectedModule = 0
    var selectedPeriod = 0
    var selectedStudent = 0
    
    var compareToSelectorView:CustomPickerView = CustomPickerView()
    var friendsInModule = [Friend]()
    
    var graphType = GraphType.Bar
    var graphTypePath = "bargraph"
    var vleActivityOptions:(me:[Double]?, myMax:Double, otherStudent:[Double]?, otherStudentMax:Double, columnNames:[String]?)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!iPad){
            segmentControl.setTitle(localized("bar_graph"), forSegmentAt: 0)
            segmentControl.setTitle(localized("line_graph"), forSegmentAt: 1)
        }
        
        customizeLayout()
        setupDatePickers()
        
        getEngagementData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getEngagementData() {
        self.webViewNullMessage.isHidden = true
        
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
        let getTopTenPercent = false
        var getAverage = false
        if (selectedStudent > 0) {
            let studentIndex = selectedStudent - 1
            if (studentIndex >= 0 && studentIndex < friends.count) {
                studentID = friends[studentIndex].jisc_id
            } else if (selectedStudent == friends.count + 1) {
                getAverage = true
                studentID = localized("average_small")
            }
        }

        let completion:downloadCompletionBlock = {(success, result, results, error) in
            self.vleActivityOptions = nil
            if (success) {
                self.vleActivityOptions = self.xAPIEngagementDataValues(period, moduleID: moduleID, studentID: studentID, result: result, results: results)
                if let status = result?["status"] as? String {
                    if status == "error" {
                        self.vleActivityOptions = nil
                        self.webViewNullMessage.isHidden = false
                    }
                }
                self.loadVLEChart()
            }
            self.view.layoutIfNeeded()
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
                       // let info = infoFromXAPIOverall(pointsArray)
                        //let dates = info.dates
                        //myValues = info.myValues
                        //otherStudentValues = info.otherValues
                        columnNames = [String]()
                        /*for (_, item) in dates.enumerated() {
                            dateFormatter.dateFormat = "dd MMM"
                            let month = dateFormatter.string(from: item)
                            dateFormatter.dateFormat = "yy"
                            let year = dateFormatter.string(from: item)
                            columnNames?.append("\(month) '\(year)")
                        }*/
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
                //columnNames = columnNamesXAPI30Days()
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
    
    private func loadVLEChart(){
        do {
            guard let filePath = Bundle.main.path(forResource: self.graphTypePath, ofType: "html")
                else {
                    print ("File reading error")
                    return
            }
            
            webView.setNeedsLayout()
            webView.layoutIfNeeded()
            let w = webView.frame.size.width - 20
            let h = webView.frame.size.height - 20
            var contents = try String(contentsOfFile: filePath, encoding: .utf8)
            contents = contents.replacingOccurrences(of: "300px", with: "\(w)px")
            contents = contents.replacingOccurrences(of: "220px", with: "\(h)px")
            
            var dateDataFinal = ""
            var countDateFinal = ""
            var otherStudentFinal = ""
            var webData = ""
            
            if (self.vleActivityOptions?.columnNames != nil) {
                dateDataFinal = self.vleActivityOptions!.columnNames!.description
            } else {
                dateDataFinal = ""
            }
            
            if (self.vleActivityOptions?.me != nil) {
                countDateFinal = self.vleActivityOptions!.me!.description
            } else {
                countDateFinal = ""
            }
            
            if(compareToButton.titleLabel?.text == localized("no_one") || compareToButton.titleLabel?.text == localized("compare_to")) {
                webData = "series: [{name:'\(localized("me"))',data: \(countDateFinal)}], xAxis: { categories: \(dateDataFinal)}"
                webData = webData.replacingOccurrences(of: "\"", with: "'")
                
            } else {
                if(self.vleActivityOptions?.otherStudent != nil){
                    otherStudentFinal = self.vleActivityOptions!.otherStudent!.description
                } else {
                    otherStudentFinal = ""
                }
                
                webData = "series: [{name:'\(localized("me"))',data: \(countDateFinal)},"
                webData.append("{name:'\(localized(compareToButton.titleLabel!.text!))',data: \(otherStudentFinal)}], xAxis: { categories: \(dateDataFinal)")
                webData.append("}")
                webData = webData.replacingOccurrences(of: "\"", with: "'")
            }
            
            print("webData \(webData)")
            
            contents = contents.replacingOccurrences(of: "<<<REPLACE_DATA_HERE>>>", with: webData)
            let baseUrl = URL(fileURLWithPath: filePath)
            webView.loadHTMLString(contents as String, baseURL: baseUrl)
            
            /*if(iPad){
                guard let filePath = Bundle.main.path(forResource: "linegraph", ofType: "html")
                    else {
                        print ("File reading error")
                        return
                }
                
                webViewLineiPad.setNeedsLayout()
                webViewLineiPad.layoutIfNeeded()
                let w = webViewLineiPad.frame.size.width - 20
                let h = webViewLineiPad.frame.size.height - 20
                var contents = try String(contentsOfFile: filePath, encoding: .utf8)
                contents = contents.replacingOccurrences(of: "300px", with: "\(w)px")
                contents = contents.replacingOccurrences(of: "220px", with: "\(h)px")
                var dateDataFinal = ""
                var countDateFinal = ""
                if (self.vleActivityOptions?.columnNames != nil) {
                    dateDataFinal = self.vleActivityOptions!.columnNames!.description
                } else {
                    dateDataFinal = ""
                }
                if (self.vleActivityOptions?.me != nil) {
                    countDateFinal = self.vleActivityOptions!.me!.description
                } else {
                    countDateFinal = ""
                }
                
                contents = contents.replacingOccurrences(of: "COUNT", with: countDateFinal)
                contents = contents.replacingOccurrences(of: "DATES", with: dateDataFinal)
                
                let baseUrl = URL(fileURLWithPath: filePath)
                webViewLineiPad.loadHTMLString(contents as String, baseURL: baseUrl)
            }*/
        } catch {
            print ("File HTML error")
        }
    }
    
    func friendsInTheSameCourse() -> [Friend] {
        var array:[Friend] = [Friend]()
        
        for (_, friend) in dataManager.friends().enumerated() {
            if (!friend.jisc_id.isEmpty) {
                array.append(friend)
            }
        }
        
        return array
    }
    
    func customizeLayout(){
        startDateField.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        startDateField.layer.borderWidth = 1
        startDateField.layer.cornerRadius = 4
        startDateField.layer.masksToBounds = true
        
        endDateField.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        endDateField.layer.borderWidth = 1
        endDateField.layer.cornerRadius = 4
        endDateField.layer.masksToBounds = true
    }
    
    func setupDatePickers(){
        startDatePicker.datePickerMode = UIDatePickerMode.date
        startDatePicker.maximumDate = Date()
        let startToolbar = UIToolbar()
        startToolbar.sizeToFit()
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(startDatePickerDone))
        startToolbar.setItems([startDoneButton], animated: true)
        startDateField.inputAccessoryView = startToolbar
        startDateField.inputView = startDatePicker
        
        endDatePicker.datePickerMode = UIDatePickerMode.date
        endDatePicker.maximumDate = Date()
        let endToolbar = UIToolbar()
        endToolbar.sizeToFit()
        let endDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endDatePickerDone))
        endToolbar.setItems([endDoneButton], animated: true)
        endDateField.inputAccessoryView = endToolbar
        endDateField.inputView = endDatePicker
    }
    
    func startDatePickerDone(){
        if(endDateField.text != localized("end") && startDatePicker.date > endDatePicker.date) {
            //TODO nice message
            self.view.endEditing(true)
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = gbDateFormat
        let gbDate = formatter.string(from: startDatePicker.date)
        startDateField.text = "\(gbDate)"
        startDateField.textColor = UIColor.darkGray
        self.view.endEditing(true)
        if(endDateField.text != localized("end")){
            getEngagementData()
        }
    }
    
    func endDatePickerDone(){
        if(startDateField.text != localized("start") && endDatePicker.date < startDatePicker.date) {
            //TODO nice message
            self.view.endEditing(true)
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = gbDateFormat
        let gbDate = formatter.string(from: endDatePicker.date)
        endDateField.text = "\(gbDate)"
        endDateField.textColor = UIColor.darkGray
        self.view.endEditing(true)
        if(startDateField.text != localized("start")){
            getEngagementData()
        }
    }
    
    @IBAction func openMenu(_ sender:UIButton?) {
        DELEGATE.menuView?.open()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            graphType = .Bar
            graphTypePath = "bargraph"
        case 1:
            graphType = .Line
            graphTypePath = "linegraph"
        default:
            break
        }
        
        getEngagementData()
    }
    
    @IBAction func showModuleSelector(_ sender:UIButton) {
        var array:[String] = [String]()
        array.append(localized("all_modules"))
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
        let period = periods[selectedPeriod]
        var moduleID:String? = nil
        var courseID:String? = nil
        
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
        
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
        }
        xAPIManager().checkMod(testUrl:urlString)
    }
    
    @IBAction func showCompareToSelector(_ sender:UIButton) {
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
            array.append(localized("average"))
            compareToSelectorView = CustomPickerView.create(localized("choose_student"), delegate: self, contentArray: array, selectedItem: selectedStudent)
            view.addSubview(compareToSelectorView)
        }
    }
    
    func view(_ view: CustomPickerView, selectedRow: Int) {
        switch (view) {
        case moduleSelectorView:
            if (selectedModule != selectedRow) {
                compareToButton.alpha = 1.0
                compareToButton.isUserInteractionEnabled = true
                if (selectedModule == 0) {
                    if (selectedStudent != 0) {
                        compareToButton.setTitle(localized("no_one"), for: UIControlState())
                        compareToSelectorView.alpha = 0.5
                        compareToSelectorView.isUserInteractionEnabled = false
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
                    compareToButton.setTitle(localized("compare_to"), for: UIControlState())
                    compareToButton.alpha = 0.5
                    compareToButton.isUserInteractionEnabled = false
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
        case compareToSelectorView:
            if (selectedStudent != selectedRow) {
                selectedStudent = selectedRow
                if (selectedStudent == 0) {
                    compareToButton.setTitle(localized("no_one"), for: UIControlState())
                } else if ((selectedStudent - 1) < friendsInTheSameCourse().count) {
                    let student = friendsInTheSameCourse()[selectedStudent - 1]
                    compareToButton.setTitle("\(student.firstName) \(student.lastName)", for: UIControlState())
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
                }
                getEngagementData()
            }
        break
        default:break
        }
    }
    
    @IBAction func callPeriodData(_ sender:UIButton){
        switch (sender){
        case sevenDaysSelectorButton:
            selectedPeriod = 0
            sevenDaysSelectorButton.isSelected = true
            twentyEightDaysSelectorButton.isSelected = false
            getEngagementData()
            break
        case twentyEightDaysSelectorButton:
            selectedPeriod = 1
            sevenDaysSelectorButton.isSelected = false
            twentyEightDaysSelectorButton.isSelected = true
            getEngagementData()
            break
        default: break
        }
    }
}
