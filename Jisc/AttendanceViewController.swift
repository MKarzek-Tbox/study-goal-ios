//
//  AttendanceViewController.swift
//  Jisc
//
//  Created by therapy box on 12/10/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class EventsAttendedObject {
    var date:String
    var time:String
    var activity:String
    var module:String
    
    init(date:String,time:String,activity:String,module:String){
        self.date = date
        self.time = time
        self.activity = activity
        self.module = module
    }
}

class AttendanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomPickerViewDelegate {
    
    @IBOutlet weak var segmentControl:UISegmentedControl!
    @IBOutlet weak var attendanceAllView:UIView!
    @IBOutlet weak var attendanceSummaryView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var noDataWebViewLabel:UILabel!
    
    @IBOutlet weak var startDateFieldSummary:UITextField!
    @IBOutlet weak var endDateFieldSummary:UITextField!
    @IBOutlet weak var startDateFieldAll:UITextField!
    @IBOutlet weak var endDateFieldAll:UITextField!
    
    var attendanceData = [EventsAttendedObject]()
    var attendanceDataUnique = [EventsAttendedObject]()
    var limit = 20
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "dd/MM/yyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    let databaseDateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    
    @IBOutlet weak var moduleButtonAll:UIButton!
    @IBOutlet weak var moduleButtonSummary:UIButton!
    var moduleSelectorView:CustomPickerView = CustomPickerView()
    var selectedModule:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set localization for segment controller
        if(!iPad){
            segmentControl.setTitle(localized("summary"), forSegmentAt: 0)
            segmentControl.setTitle(localized("all"), forSegmentAt: 1)
        }
        
        customizeLayout()
        setupDatePickers()
        
        //set up table view
        let eventsRefreshControl = UIRefreshControl()
        eventsRefreshControl.addTarget(self, action: #selector(refreshAttendanceData(_:)), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(eventsRefreshControl)
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        tableView.register(EventsAttendedCell.self, forCellReuseIdentifier: kEventsAttendedCellIdentifier)
        tableView.register(UINib(nibName: kEventsAttendedCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kEventsAttendedCellIdentifier)
        tableView.alwaysBounceVertical = false;
        tableView.tableFooterView = UIView()
        
        self.attendanceData.removeAll()
        getAttendance {
            self.loadHighChart()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func openMenu(_ sender:UIButton?) {
        DELEGATE.menuView?.open()
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            attendanceAllView.isHidden = true
            attendanceSummaryView.isHidden = false
        case 1:
            attendanceAllView.isHidden = false
            attendanceSummaryView.isHidden = true
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventsAttendedCell", for: indexPath)
        
        if let attendanceCell = cell as? EventsAttendedCell {
            attendanceCell.loadEvents(events: attendanceData[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let attendanceCell = cell as? EventsAttendedCell {
            attendanceCell.loadEvents(events: attendanceData[indexPath.row])
        }
    }
    
    func refreshAttendanceData(_ sender:UIRefreshControl) {
        self.limit = 20
        getAttendance {
            sender.endRefreshing()
            self.loadHighChart()
        }
    }
    
    func getAttendance(completion:@escaping (() -> Void)){
        attendanceData.removeAll()
        attendanceDataUnique.removeAll()
        let xMGR = xAPIManager()
        xMGR.silent = true
        xMGR.getEventsAttended(skip: 0, limit: self.limit) { (success, result, results, error) in
            if (results != nil){
                for event in results! {
                    var date:String?
                    var time:String?
                    var activity:String?
                    var module:String?
                    
                    if let object = event as? [String:Any] {
                        if let statement = object["statement"] as? [String:Any]{
                            if let object2 = statement["object"] as? [String:Any] {
                                if let definition = object2["definition"] as? [String:Any] {
                                    if let name = definition["name"] as? [String:Any]{
                                        if let en = name["en"] as? String {
                                            var separatedArray = en.components(separatedBy: " ")
                                            date = separatedArray.popLast()
                                            time = separatedArray.popLast()
                                            module = separatedArray.joined(separator: " ")
                                        }
                                    }
                                }
                            }
                            if let context = statement["context"] as? [String:Any]{
                                if let extensions = context["extensions"] as? [String:Any]{
                                    activity = extensions["http://xapi.jisc.ac.uk/activity_type_id"] as? String
                                    if let courseArea = extensions["http://xapi.jisc.ac.uk/courseArea"] as? [String:Any]{
                                        module = courseArea["http://xapi.jisc.ac.uk/uddModInstanceID"] as? String
                                    }
                                }
                            }
                        }
                    }
                    self.attendanceData.append(EventsAttendedObject(date: date!, time: time!, activity: activity!, module: module!))
                }
            }
            
            print(self.attendanceData)
            
            self.attendanceData.sort(by: { $0.date.compare($1.date) == .orderedDescending})
            
            print(self.attendanceData.count)
            self.tableView.reloadData()
            
            //set null message
            if(self.attendanceData.count == 0){
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                noDataLabel.text = localized("no_data_available")
                noDataLabel.textColor = UIColor.black
                noDataLabel.textAlignment = .center
                self.tableView.backgroundView = noDataLabel
                self.tableView.separatorStyle = .none
                
                self.noDataWebViewLabel.isHidden = false
            } else {
                self.noDataWebViewLabel.isHidden = true
            }
            
            completion()
        }
    }
    
    func customizeLayout(){
        if(!iPad){
            startDateFieldSummary.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
            startDateFieldSummary.layer.borderWidth = 1
            startDateFieldSummary.layer.cornerRadius = 4
            startDateFieldSummary.layer.masksToBounds = true
            
            endDateFieldSummary.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
            endDateFieldSummary.layer.borderWidth = 1
            endDateFieldSummary.layer.cornerRadius = 4
            endDateFieldSummary.layer.masksToBounds = true
        }
        
        startDateFieldAll.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        startDateFieldAll.layer.borderWidth = 1
        startDateFieldAll.layer.cornerRadius = 4
        startDateFieldAll.layer.masksToBounds = true
        
        endDateFieldAll.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        endDateFieldAll.layer.borderWidth = 1
        endDateFieldAll.layer.cornerRadius = 4
        endDateFieldAll.layer.masksToBounds = true
    }
    
    func setupDatePickers(){
        startDatePicker.datePickerMode = UIDatePickerMode.date
        startDatePicker.maximumDate = Date()
        let startToolbar = UIToolbar()
        startToolbar.sizeToFit()
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(startDatePickerDone))
        startToolbar.setItems([startDoneButton], animated: true)
        if(!iPad){
            startDateFieldSummary.inputAccessoryView = startToolbar
            startDateFieldSummary.inputView = startDatePicker
        }
        startDateFieldAll.inputAccessoryView = startToolbar
        startDateFieldAll.inputView = startDatePicker
        
        endDatePicker.datePickerMode = UIDatePickerMode.date
        endDatePicker.maximumDate = Date()
        let endToolbar = UIToolbar()
        endToolbar.sizeToFit()
        let endDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endDatePickerDone))
        endToolbar.setItems([endDoneButton], animated: true)
        if(!iPad){
            endDateFieldSummary.inputAccessoryView = endToolbar
            endDateFieldSummary.inputView = endDatePicker
        }
        endDateFieldAll.inputAccessoryView = endToolbar
        endDateFieldAll.inputView = endDatePicker
    }
    
    func startDatePickerDone(){
        if(endDateFieldAll.text != localized("end") && startDatePicker.date > endDatePicker.date) {
            //TODO nice message
            self.view.endEditing(true)
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = gbDateFormat
        let gbDate = formatter.string(from: startDatePicker.date)
        if(!iPad){
            startDateFieldSummary.text = "\(gbDate)"
            startDateFieldSummary.textColor = UIColor.darkGray
        }
        startDateFieldAll.text = "\(gbDate)"
        startDateFieldAll.textColor = UIColor.darkGray
        self.view.endEditing(true)
        if(endDateFieldAll.text != localized("end")){
            getAttendance {
                self.loadHighChart()
            }
        }
    }
    
    func endDatePickerDone(){
        if(startDateFieldAll.text != localized("start") && endDatePicker.date < startDatePicker.date) {
            //TODO nice message
            self.view.endEditing(true)
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = gbDateFormat
        let gbDate = formatter.string(from: endDatePicker.date)
        if(!iPad){
            endDateFieldSummary.text = "\(gbDate)"
            endDateFieldSummary.textColor = UIColor.darkGray
        }
        endDateFieldAll.text = "\(gbDate)"
        endDateFieldAll.textColor = UIColor.darkGray
        self.view.endEditing(true)
        if(startDateFieldAll.text != localized("start")){
            getAttendance {
                self.loadHighChart()
            }
        }
    }
    
    private func loadHighChart() {
        var countArray:[Int] = []
        var dateArray:[String] = []
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let result = dateFormatter.string(from: todaysDate)
        let twentyEightDaysAgo = Calendar.current.date(byAdding: .day, value: -34, to: Date())
        let daysAgoResult = dateFormatter.string(from: twentyEightDaysAgo!)
        
        var urlStringCall = ""
        if(!demo()){
            urlStringCall = "https://api.datax.jisc.ac.uk/sg/weeklyattendance?startdate=\(daysAgoResult)&enddate=\(result)"
        } else {
            urlStringCall = "https://stuapp.analytics.alpha.jisc.ac.uk/fn_fake_attendance_summary"
        }
        var request:URLRequest?
        if let urlString = urlStringCall.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
        }
        if var request = request {
            if let token = xAPIToken() {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                        self.webView.isHidden = false
                        for item in json {
                            let object = item as? [String:Any]
                            if let count = object?["count"] as? Int {
                                countArray.append(count)
                            }
                            
                            if let date = object?["date"] as? NSString {
                                let dateString = date.substring(with: NSRange(location: 0, length: 10)) as String
                                
                                let desiredDateFormatter = DateFormatter()
                                desiredDateFormatter.dateFormat = "dd-MM-yyyy"
                                
                                let makeDateFormatter = DateFormatter()
                                makeDateFormatter.dateFormat = "yyyy-MM-dd"
                                let makeDateFromDate = makeDateFormatter.date(from: dateString)
                                
                                let newDateFormatted = desiredDateFormatter.string(from: makeDateFromDate!)
                                
                                dateArray.append(newDateFormatted)
                            }
                        }
                        
                        do {
                            guard let filePath = Bundle.main.path(forResource: "stats_attendance_high_chart", ofType: "html")
                                else {
                                    print ("File reading error")
                                    self.noDataWebViewLabel.alpha = 1.0
                                    return
                            }
                            
                            self.webView.setNeedsLayout()
                            self.webView.layoutIfNeeded()
                            let w = self.webView.frame.size.width - 20
                            let h = self.webView.frame.size.height - 20
                            var contents = try String(contentsOfFile: filePath, encoding: .utf8)
                            contents = contents.replacingOccurrences(of: "300px", with: "\(w)px")
                            contents = contents.replacingOccurrences(of: "220px", with: "\(h)px")
                            var countData:String = ""
                            var dateData: String = ""
                            for count in countArray {
                                countData = countData + String(count) + ", "
                            }
                            var countDataFinal:String = ""
                            if(countData.characters.count > 1){
                                let endIndex = countData.index(countData.endIndex, offsetBy: -2)
                                countDataFinal = "[" + countData.substring(to: endIndex) + "]"
                                
                                for date in dateArray {
                                    dateData = dateData + "'\(date)'" + ", "
                                }
                                var dateDataFinal:String = ""
                                let endIndexDate = dateData.index(dateData.endIndex, offsetBy: -2)
                                
                                dateDataFinal = "[" + dateData.substring(to: endIndexDate) + "]"
                                
                                contents = contents.replacingOccurrences(of: "COUNT", with: countDataFinal)
                                contents = contents.replacingOccurrences(of: "DATES", with: dateDataFinal)
                            }
                            if(dateArray.count == 0){
                                self.noDataWebViewLabel.alpha = 1.0
                                self.noDataWebViewLabel.textColor = UIColor.black
                                self.noDataWebViewLabel.text = localized("no_data_available")
                                self.noDataWebViewLabel.isHidden = false
                            }
                            
                            let baseUrl = URL(fileURLWithPath: filePath)
                            self.webView.loadHTMLString(contents as String, baseURL: baseUrl)
                            
                        } catch {
                            print ("File HTML error for events graph")
                            self.noDataWebViewLabel.alpha = 1.0
                            self.noDataWebViewLabel.textColor = UIColor.black
                            self.noDataWebViewLabel.text = localized("no_data_available")
                            self.noDataWebViewLabel.isHidden = false
                        }
                    }
                } catch {
                    print("Error deserializing JSON for events graph: \(error)")
                    self.noDataWebViewLabel.alpha = 1.0
                    self.noDataWebViewLabel.textColor = UIColor.black
                    self.noDataWebViewLabel.text = localized("no_data_available")
                    self.noDataWebViewLabel.isHidden = false
                    
                }
            }
        } else {
            self.noDataWebViewLabel.alpha = 1.0
            self.noDataWebViewLabel.textColor = UIColor.black
            self.noDataWebViewLabel.text = localized("no_data_available")
            self.noDataWebViewLabel.isHidden = false
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
                moduleButtonAll.setTitle(localized("filter_modules"), for: UIControlState())
                if(!iPad){
                    moduleButtonSummary.setTitle(localized("filter_modules"), for: UIControlState())
                }
            } else if (moduleIndex >= 0 && moduleIndex < dataManager.modules().count) {
                moduleButtonAll.setTitle(dataManager.modules()[moduleIndex].name, for: UIControlState())
                if(!iPad){
                    moduleButtonSummary.setTitle(dataManager.modules()[moduleIndex].name, for: UIControlState())
                }
                //specific call
            }
            getAttendance {
                self.loadHighChart()
            }
        }
    }
}
