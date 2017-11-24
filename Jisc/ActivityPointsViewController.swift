//
//  ActivityPointsViewController.swift
//  Jisc
//
//  Created by therapy box on 13/10/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class PointsObject {
    var activity:String
    var count:Int
    var points:Int
    
    init(activity:String, count:Int, points:Int) {
        self.activity = activity
        self.count = count
        self.points = points
    }
}

class ActivityPointsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomPickerViewDelegate {
    
    @IBOutlet weak var segmentControl:UISegmentedControl!
    @IBOutlet weak var activityPointsSummaryView:UIView!
    @IBOutlet weak var activityPointsChartView:UIView!
    
    @IBOutlet weak var startDateField:UITextField!
    @IBOutlet weak var endDateField:UITextField!
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var webViewNullMessage:UILabel!
    @IBOutlet weak var activityPointsSum:UILabel!
    
    @IBOutlet weak var moduleButton:UIButton!
    @IBOutlet weak var thisWeekSelectorButton:UIButton!
    @IBOutlet weak var overallSelectorButton:UIButton!
    
    var activityPointsData = [PointsObject]()
    var selectedPeriod = 0
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "dd/MM/yyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    let databaseDateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    
    var moduleSelectorView:CustomPickerView = CustomPickerView()
    var selectedModule = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set localization for segment controller
        if(!iPad){
            segmentControl.setTitle(localized("summary"), forSegmentAt: 0)
            segmentControl.setTitle(localized("chart"), forSegmentAt: 1)
        }
        
        customizeLayout()
        setupDatePickers()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: kPointsCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kPointsCellIdentifier)
        tableView.tableFooterView = UIView()
        
        getActivityPoints(period: .SevenDays) { }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityPointsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kPointsCellIdentifier, for: indexPath)
        if let pointsCell = cell as? PointsCell {
            pointsCell.loadPoints(points: activityPointsData[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let pointsCell = cell as? PointsCell {
            pointsCell.loadPoints(points: activityPointsData[indexPath.row])
        }
    }
    
    func getActivityPoints(period:kXAPIActivityPointsPeriod, completion:@escaping (() -> Void)) {
        webViewNullMessage.isHidden = true
        activityPointsData.removeAll()
        activityPointsSum.text = "0"
        let xMGR = xAPIManager()
        xMGR.silent = true
        xMGR.getActivityPoints(period) { (success, result, results, error) in
            if (result != nil) {
                if let totalPoints = result!["totalPoints"] as? Int {
                    print(dataManager.currentStudent!)
                    print(totalPoints)
                    print(totalPoints as NSNumber)
                    dataManager.currentStudent!.totalActivityPoints = totalPoints as NSNumber
                    self.activityPointsSum.text = "\(totalPoints)"
                }
                if let info = result!["info"] as? [AnyHashable:Any] {
                    let keys = info.keys
                    for (_, key) in keys.enumerated() {
                        if let object = info[key] as? [AnyHashable:Any] {
                            if let count = object["count"] as? Int {
                                if let points = object["points"] as? Int {
                                    if let id = object["_id"] as? String {
                                        if let activity = id.components(separatedBy: "/").last {
                                            var activity = activity
                                            if activity.isEmpty { activity = id.components(separatedBy: "/")[id.components(separatedBy: "/").count-2]}
                                            self.activityPointsData.append(PointsObject(activity: activity.capitalized, count: count, points: points))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.loadPieChart()
            
            self.tableView.reloadData()
            
            if(self.activityPointsData.count == 0){
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: self.tableView.bounds.size.height, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                noDataLabel.text          = localized("no_data_available")
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                self.tableView.backgroundView  = noDataLabel
                self.tableView.separatorStyle  = .none
            } else {
                self.tableView.backgroundView = nil
            }
            completion()
        }
    }
    
    private func loadPieChart() {
        if(activityPointsData.count == 0){
            webViewNullMessage.isHidden = true
        } else {
            do {
                guard let filePath = Bundle.main.path(forResource: "stats_points_pi_chart", ofType: "html")
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
                
                var data: String = ""
                
                for point in activityPointsData {
                    data += "{"
                    if (point.activity == "Loggedin"){
                        data += "name:'\(localized("logged_in"))',"
                    } else {
                        data += "name:'\(point.activity)',"
                    }
                    
                    data += "y:\(point.points)"
                    data += "},"
                }
                contents = contents.replacingOccurrences(of: "REPLACE_DATA", with: data)
                
                let baseUrl = URL(fileURLWithPath: filePath)
                webView.loadHTMLString(contents as String, baseURL: baseUrl)
            } catch {
                print("File HTML error on pie chart") 
            }
        }
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
            getActivityPoints(period: .Overall) {
                
            }
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
            getActivityPoints(period: .Overall) {
                
            }
        }
    }
    
    @IBAction func openMenu(_ sender:UIButton?) {
        DELEGATE.menuView?.open()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            activityPointsSummaryView.isHidden = false
            activityPointsChartView.isHidden = true
        case 1:
            activityPointsSummaryView.isHidden = true
            activityPointsChartView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func showModuleSelector(_ sender:UIButton) {
        var array:[String] = [String]()
        array.append(localized("all_modules"))
        let centeredIndexes = [Int]()
        for (_, item) in dataManager.modules().enumerated() {
            array.append(" - \(item.name)")
        }
        moduleSelectorView = CustomPickerView.create(localized("filter"), delegate: self, contentArray: array, selectedItem: selectedModule)
        moduleSelectorView.centerIndexes = centeredIndexes
        view.addSubview(moduleSelectorView)
        var moduleID:String? = nil
        
        if (selectedModule > 0) {
            let theIndex = selectedModule - 1
            if (theIndex < dataManager.modules().count) {
                moduleID = dataManager.modules()[theIndex].id
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
    
    func view(_ view: CustomPickerView, selectedRow: Int) {
        if (selectedModule != selectedRow) {
            selectedModule = selectedRow
            let moduleIndex = selectedModule - 1
            
            if (selectedModule == 0) {
                moduleButton.setTitle(localized("filter_modules"), for: UIControlState())
            } else if (moduleIndex >= 0 && moduleIndex < dataManager.modules().count) {
                moduleButton.setTitle(dataManager.modules()[moduleIndex].name, for: UIControlState())
                //specific call
            }
            if(selectedPeriod == 0){
                getActivityPoints(period: .SevenDays) { }
            } else {
                getActivityPoints(period: .Overall) { }
            }
        }
    }
    
    @IBAction func callPeriodData(_ sender:UIButton){
        switch (sender){
        case thisWeekSelectorButton:
            selectedPeriod = 0
            getActivityPoints(period: .SevenDays){ }
            thisWeekSelectorButton.isSelected = true
            overallSelectorButton.isSelected = false
            break
        case overallSelectorButton:
            selectedPeriod = 1
            getActivityPoints(period: .Overall){ }
            overallSelectorButton.isSelected = true
            thisWeekSelectorButton.isSelected = false
            break
        default: break
        }
    }
}
