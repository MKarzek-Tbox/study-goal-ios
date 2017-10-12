//
//  StatsVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}

class PointsObject {
    var activity:String
    var count:Int
    var points:Int
    
    init(activity:String, count:Int, points:Int) {
        self.activity = activity
        self.count = count
        self.points = points
    }
    //    //MARK: - NSCoding -
    //    required convenience init(coder aDecoder: NSCoder) {
    //        let activity = aDecoder.decodeObject(forKey: "activity") as! String
    //        let count1 = aDecoder.decodeObject(forKey: "count") as! String
    //        let points1 = aDecoder.decodeObject(forKey: "points") as! String
    //        let count:Int =  Int(count1)!
    //        let points:Int = Int(points1)!
    //        self.init(activity: activity, count: count, points: points)
    //    }
    //
    //    func encode(with aCoder: NSCoder) {
    //        aCoder.encode(activity, forKey: "activity")
    //        aCoder.encode(count, forKey: "count")
    //        aCoder.encode(points, forKey: "points")
    //
    //    }
    
}

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
    //    //MARK: - NSCoding -
    //    required convenience init(coder aDecoder: NSCoder) {
    //        let date = aDecoder.decodeObject(forKey: "date") as! Date
    //        let activity = aDecoder.decodeObject(forKey: "activity") as! String
    //        let module = aDecoder.decodeObject(forKey: "module") as! String
    //        self.init(date: date, activity: activity, module: module)
    //    }
    //
    //    func encode(with aCoder: NSCoder) {
    //        aCoder.encode(date, forKey: "date")
    //        aCoder.encode(activity, forKey: "activity")
    //        aCoder.encode(module, forKey: "module")
    //
    //    }
}

let periods:[kXAPIEngagementScope] = [.SevenDays, .ThirtyDays]
let myColor = UIColor(red: 0.53, green: 0.39, blue: 0.78, alpha: 1.0)
let otherStudentColor = UIColor(red: 0.22, green: 0.57, blue: 0.93, alpha: 1.0)

enum GraphType {
    case Line
    case Bar
}

class StatsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, CustomPickerViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var contentCenterX:NSLayoutConstraint!
    @IBOutlet weak var topLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var blueDot:UIImageView!
    @IBOutlet weak var comparisonStudentName:UILabel!
    var selectedModule:Int = 0
    var selectedPeriod:Int = 0 // 30 days
    var selectedStudent:Int = 0
    @IBOutlet weak var graphView:UIView!
    
    @IBOutlet weak var graphContainer:UIView!
    @IBOutlet weak var graphContainerWidth:NSLayoutConstraint!
    @IBOutlet weak var viewWithVerticalLabels:UIView!
    @IBOutlet weak var viewWithHorizontalLabels:UIView!
    var theGraphView:UIView?
    @IBOutlet weak var noDataLabel:UILabel!
    @IBOutlet weak var noPointsDataLabel:UILabel!
    var weekDays = [localized("monday"), localized("tuesday"), localized("wednesday"), localized("thursday"), localized("friday"), localized("saturday"), localized("sunday")]
    @IBOutlet weak var moduleButton:UIButton!
    @IBOutlet weak var periodSegment:UISegmentedControl!
    @IBOutlet weak var compareToButton:UIButton!
    var moduleSelectorView:CustomPickerView = CustomPickerView()
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
    
    @IBOutlet weak var attainmentTableView:UITableView!
    var attainmentArray = [AttainmentObject]()
    
    @IBOutlet weak var pointsLabel:UILabel!
    @IBOutlet weak var pointsTable:UITableView!
    var pointsArray = [PointsObject]()
    
    var staffAlert:UIAlertController? = UIAlertController(title: localized("staff_stats_alert"), message: "", preferredStyle: .alert)
    
    @IBOutlet weak var noPointsLabel: UILabel!
    
    @IBOutlet weak var vleGraphWebView: UIWebView!
    @IBOutlet weak var pieChartWebView: UIWebView!
    
    @IBOutlet weak var highChartWebView: UIWebView!
    @IBOutlet weak var pieChartSwitch: UISwitch!
    
    @IBOutlet weak var lineViews: UIView!
    @IBOutlet weak var rectangleView: UIView!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var leaderBoard: UIView!
    
    @IBOutlet weak var eventsAttendedTableView: UITableView!
    @IBOutlet weak var eventAtteneded: UIView!
    @IBOutlet weak var attendance: UIView!
    
    @IBOutlet weak var ipadGraphView: UIView!
    @IBOutlet weak var ipadAttainmentView: UIView!
    @IBOutlet weak var ipadPointsView: UIView!
    @IBOutlet weak var eventsAndAttendanceSegment: UISegmentedControl!
    @IBOutlet weak var attendanceSegmentControl: UISegmentedControl!
    @IBOutlet weak var weekOverallSegmentController: UISegmentedControl!
    
    var eventsAttendedArray = [EventsAttendedObject]()
    var eventsAttendedUniqueArray = [EventsAttendedObject]()
    var eventsAttendedLimit:Int = 20
    var attainmentDemoArray = ["Date   Module Name","20/7/2016 Introduction to Cell Biology", "18/4/2017 Computing 101", "11/11/2017 Introduction to World Literature"]
    var eventsAttendedDemoArray = [["Lecture","10:20","20/7/2016","Maths"],["Lab","12:00","13/4/2016","Chemistry"],["Lecture", "9:30","14/8/2016","English"]]
    var graphTypePath = "bargraph"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDataLabel.alpha = 0.0
        noPointsDataLabel.alpha = 0.0
        noPointsDataLabel.text = localized("no_points_earned_yet")
        noPointsLabel.text = localized("no_points_earned_yet")
        if !iPad{
            eventsAndAttendanceSegment.setTitle(localized("events_attended_segment"), forSegmentAt: 0)
            eventsAndAttendanceSegment.setTitle(localized("attendence_summary"), forSegmentAt: 1)
            eventsAndAttendanceSegment.selectedSegmentIndex = 1
            
            attendanceSegmentControl.setTitle(localized("events_attended_segment"), forSegmentAt: 0)
            attendanceSegmentControl.setTitle(localized("attendence_summary"), forSegmentAt: 1)
            attendanceSegmentControl.selectedSegmentIndex = 1
            
            weekOverallSegmentController.setTitle(localized("this_week"), forSegmentAt: 0)
            weekOverallSegmentController.setTitle(localized("overall"), forSegmentAt: 1)
            
            
        }
        
        staffAlert?.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
        staffAlert?.addAction(UIAlertAction(title: localized("dont_show_again"), style: .default, handler: { (action) in
            if let studentId = dataManager.currentStudent?.id {
                NSKeyedArchiver.archiveRootObject(true, toFile: filePath("dont_show_staff_alert\(studentId)"))
            }
        }))
        self.periodSegment.selectedSegmentIndex = 0 //Vle changed here
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAttainmentData(_:)), for: UIControlEvents.valueChanged)
        attainmentTableView.addSubview(refreshControl)
        attainmentTableView.alwaysBounceVertical = true
        attainmentTableView.estimatedRowHeight = 35.0
        attainmentTableView.rowHeight = UITableViewAutomaticDimension
        attainmentTableView.register(UINib(nibName: kAttainmentCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kAttainmentCellIdentifier)
        
        pointsTable.estimatedRowHeight = 36.0
        pointsTable.rowHeight = UITableViewAutomaticDimension
        pointsTable.register(UINib(nibName: kPointsCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kPointsCellIdentifier)
        pointsTable.alwaysBounceVertical = false;
        pointsTable.tableFooterView = UIView()
        
        let eventsRefreshControl = UIRefreshControl()
        eventsRefreshControl.addTarget(self, action: #selector(eventsRefreshAttainmentData(_:)), for: UIControlEvents.valueChanged)
        eventsAttendedTableView.addSubview(eventsRefreshControl)
        eventsAttendedTableView.estimatedRowHeight = 36.0
        eventsAttendedTableView.rowHeight = UITableViewAutomaticDimension
        eventsAttendedTableView.dataSource = self
        eventsAttendedTableView.delegate = self
        eventsAttendedTableView.reloadData()
        eventsAttendedTableView.register(EventsAttendedCell.self, forCellReuseIdentifier: kEventsAttendedCellIdentifier)
        eventsAttendedTableView.register(UINib(nibName: kEventsAttendedCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kEventsAttendedCellIdentifier)
        
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
        
        titleLabel.text = "\(localized("last_7_days")) \(localized("engagement"))"
        moduleButton.setTitle(localized("all_activity"), for: UIControlState())
        compareToButton.setTitle(localized("no_one"), for: UIControlState())
        
        blueDot.alpha = 0.0
        comparisonStudentName.alpha = 0.0
        //Commented below to test for iPad
        //initialGraphWidth = graphContainerWidth.constant
        
        getEngagementData()
        getActivityPoints(period: .SevenDays, completion: {
            
        })
        attainmentArray.removeAll()
        getAttainmentData {
            print("Getting Attainment data")
        }
        self.eventsAttendedArray.removeAll()
        getEventsAttended {
            print("requested events attended")
        }
        goToAttainment()
        self.highChartWebView.isHidden = false
        if !iPad{
            self.vleGraphWebView.isHidden = false
        }
        if(demo()){
            self.highChartWebView.isHidden = true;
        }
        self.noPointsLabel.isHidden = false
        self.eventsAttendedTableView.isHidden = false
        self.loadHighChart()
        self.loadVLEChart()
        
        if !iPad{
            self.attendanceSegmentControl.isHidden = true
        }
        
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main&contentName=MainStats"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main&contentName=MainStats"
        }
        xAPIManager().checkMod(testUrl:urlString)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getAttainmentData {
            self.attainmentTableView.reloadData()
        }
        self.eventsAttendedArray.removeAll()
        getEventsAttended {
            print("requested events attended")
            self.eventsAttendedTableView.reloadData()
        }
        
        if staff() {
            if let studentId = dataManager.currentStudent?.id {
                if NSKeyedUnarchiver.unarchiveObject(withFile: filePath("dont_show_staff_alert\(studentId)")) == nil {
                    if let alert = staffAlert {
                        navigationController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        staffAlert = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func openMenu(_ sender:UIButton?) {
        DELEGATE.menuView?.open()
    }
    
    @IBAction func tapPieChartSwitch(_ sender: UISwitch) {
        pieChartWebView.isHidden = !sender.isOn
        lineViews.isHidden = sender.isOn
        rectangleView.isHidden = sender.isOn
    }
    @IBAction func eventsAttendedAction(_ sender: Any) {
        if (eventsAndAttendanceSegment.selectedSegmentIndex == 0){
            goToEventsAttended()
            attendanceSegmentControl.selectedSegmentIndex = 0
        } else {
            goToAttendance()
            attendanceSegmentControl.selectedSegmentIndex = 1
        }
    }
    @IBAction func attendanceAction(_ sender: Any) {
        if (attendanceSegmentControl.selectedSegmentIndex == 0){
            goToEventsAttended()
            eventsAndAttendanceSegment.selectedSegmentIndex = 0
            print("From AttendanceAction going to attendance")
        } else {
            goToAttendance()
            eventsAndAttendanceSegment.selectedSegmentIndex = 1
            print("From AttendanceAction going to Events attended")
        }
    }
    
    func refreshAttainmentData(_ sender:UIRefreshControl) {
        getAttainmentData {
            sender.endRefreshing()
        }
    }
    
    func eventsRefreshAttainmentData(_ sender:UIRefreshControl) {
        self.eventsAttendedLimit = 20
        getEventsAttended {
            sender.endRefreshing()
        }
    }
    
    func getAttainmentData(_ completion:@escaping (() -> Void)) {
        attainmentArray.removeAll()
        attainmentTableView.reloadData()
        let xMGR = xAPIManager()
        xMGR.silent = true
        xMGR.getAttainment { (success, result, results, error) in
            self.attainmentArray.removeAll()
            self.attainmentArray.append(AttainmentObject(dateString: "\(localized("date"))     ", moduleName: localized("module"), grade: localized("mark")))
            if (results != nil) {
                for (_, item) in results!.enumerated() {
                    if let dictionary = item as? NSDictionary {
                        if let grade = dictionary["ASSESS_AGREED_GRADE"] as? String {
                            if let moduleName = dictionary["X_MOD_NAME"] as? String {
                                if let dateString = dictionary["CREATED_AT"] as? String {
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    if let temp = dateString.components(separatedBy: ".").first {
                                        if let date = dateFormatter.date(from: temp.replacingOccurrences(of: "T", with: " ")) {
                                            self.attainmentArray.append(AttainmentObject(date: date, moduleName: moduleName, grade: grade))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            } else {
                print("No results")
            }
            self.attainmentArray.sort(by: { (obj1:AttainmentObject, obj2:AttainmentObject) -> Bool in
                return (obj2.date.compare(obj1.date) != .orderedDescending)
            })
            
            if(self.attainmentArray.count == 0){
                print("noattain!")
            }
            self.attainmentTableView.reloadData()
            completion()
        }
    }
    
    func getActivityPoints(period:kXAPIActivityPointsPeriod, completion:@escaping (() -> Void)) {
        pointsArray.removeAll()
        let xMGR = xAPIManager()
        xMGR.silent = true
        xMGR.getActivityPoints(period) { (success, result, results, error) in
            if (result != nil) {
                if let totalPoints = result!["totalPoints"] as? Int {
                    print(dataManager.currentStudent!)
                    print(totalPoints)
                    print(totalPoints as NSNumber)
                    dataManager.currentStudent!.totalActivityPoints = totalPoints as NSNumber
                    self.pointsLabel.text = "\(totalPoints)"
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
                                            self.pointsArray.append(PointsObject(activity: activity.capitalized, count: count, points: points))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("result is nil")
            }
            self.loadPieChart()
            
            self.pointsTable.reloadData()
            completion()
        }
    }
    
    func getEventsAttended(completion:@escaping (() -> Void)){
        eventsAttendedArray.removeAll()
        eventsAttendedUniqueArray.removeAll()
        let xMGR = xAPIManager()
        xMGR.silent = true
        xMGR.getEventsAttended(skip: 0, limit: self.eventsAttendedLimit) { (success, result, results, error) in
            self.eventsAttendedArray.append(EventsAttendedObject(date: localized("date"), time: localized("time"), activity: localized("activity"), module: localized("module")))
            if (results != nil){
                print("receiving data")
                // handle data
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
                                        //self.eventsAttendedArray.append(EventsAttendedObject(date: date,activity: activity,module: module))
                                    }
                                }
                            }
                            if let context = statement["context"] as? [String:Any]{
                                if let extensions = context["extensions"] as? [String:Any]{
                                    activity = extensions["http://xapi.jisc.ac.uk/activity_type_id"] as? String
                                }
                            }
                        }
                    }
                    //Uncomment the following line to populate the eventsAttended table
                    // self.eventsAttendedArray.append(EventsAttendedObject(date: date!, time: time!, activity: activity!, module: module!))
                }
                
                //                self.eventsAttendedArray.sort(by: { $0.date.compare($1.date) == .orderedDescending})
                //                self.eventsAttendedUniqueArray = self.eventsAttendedArray.filterDuplicates { $0.date == $1.date }
                //self.eventsAttendedUniqueArray.sort(by: { $0.date.compare($1.date) == .orderedDescending})
                //Saving to UserDefaults for offline use.
                //                let defaults = UserDefaults.standard
                //                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.eventsAttendedArray)
                //                defaults.set(encodedData, forKey: "EventsAttendedArray")
                
            } else {
                print("results is nil")
            }
            
            print("events array")
            print(self.eventsAttendedArray)
            
            
            print("here is the sorted array ", self.eventsAttendedArray.sort(by: { $0.date.compare($1.date) == .orderedDescending}))
            
            print(self.eventsAttendedArray.count)
            self.eventsAttendedTableView.reloadData()
            completion()
        }
    }
    func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    func finelyFormatterNumber(_ number:NSNumber) -> String {
        var digits:[Int] = [Int]()
        var text = "\(number)"
        var numberValue = number.intValue
        while (numberValue > 0) {
            let lastDigit = numberValue % 10
            numberValue = numberValue / 10
            digits.append(lastDigit)
        }
        if (digits.count > 0) {
            text = ""
            for (index, digit) in digits.enumerated() {
                if ((index > 0) && ((index % 3) == 0)) {
                    text = "\(digit),\(text)"
                } else {
                    text = "\(digit)\(text)"
                }
            }
        }
        return text
    }
    
    @IBAction func settings(_ sender:UIButton) {
        let vc = SettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //	@IBAction func changePage(_ sender:UISegmentedControl) {
    //		switch sender.selectedSegmentIndex {
    //		case 0:
    //			goToGraph()
    //			break
    //		case 1:
    //			goToAttainment()
    //			break
    //		case 2:
    //			goToPoints()
    //			break
    //		default:
    //			break
    //		}
    //	}
    
    func goToGraph() {
        if !iPad{
            self.attendanceSegmentControl.isHidden = true
        }
        topLabel.text = localized("vle_activity")
        hideUpperViews()
        container.isHidden = false
        if iPad {
            ipadGraphView.isHidden = false
            ipadPointsView.isHidden = true
            ipadAttainmentView.isHidden = true
        }
        
        guard let center = contentCenterX else { return }
        UIView.animate(withDuration: 0.25) {
            center.constant = self.view.frame.size.width
            self.view.layoutIfNeeded()
        }
    }
    
    func goToAttainment() {
        if let attendanceSC = attendanceSegmentControl {
            self.attendanceSegmentControl.isHidden = true
        }
        hideUpperViews()
        container.isHidden = false
        topLabel.text = localized("attainment")
        if iPad {
            ipadAttainmentView.isHidden = false
            ipadPointsView.isHidden = true
            ipadGraphView.isHidden = true
        }
        guard let center = contentCenterX else { return }
        UIView.animate(withDuration: 0.25) {
            center.constant = 0.0
            self.view.layoutIfNeeded()
        }
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-attainment&contentName=attainment"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-attainment&contentName=attainment"
        }
        xAPIManager().checkMod(testUrl:urlString)
    }
    
    func goToPoints() {
        if let attendanceSC = attendanceSegmentControl {
            self.attendanceSegmentControl.isHidden = true
        }
        hideUpperViews()
        container.isHidden = false
        topLabel.text = localized("activity_points")
        if iPad {
            ipadPointsView.isHidden = false
            ipadGraphView.isHidden = true
            ipadAttainmentView.isHidden = true
        }
        guard let center = contentCenterX else { return }
        UIView.animate(withDuration: 0.25) {
            center.constant = -self.view.frame.size.width
            self.view.layoutIfNeeded()
        }
        //London Developer July 24,2017
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-points&contentName=points"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-points&contentName=points"
        }
        xAPIManager().checkMod(testUrl:urlString)
        
    }
    
    
    func goToLeaderBoard() {
        self.attendanceSegmentControl.isHidden = true
        hideUpperViews()
        topLabel.text = localized("leaderboard")
        
        leaderBoard.isHidden = true
        //London Developer July 24,2017
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-leaderboard&contentName=leaderboard"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-leaderboard&contentName=leaderboard"
        }
        xAPIManager().checkMod(testUrl:urlString)
        
    }
    
    func goToEventsAttended() {
        if !iPad{
            self.attendanceSegmentControl.isHidden = true
        }
        hideUpperViews()
        topLabel.text = localized("events_attended_segment")
        
        eventAtteneded.isHidden = false
        //London Developer July 24,2017
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-events&contentName=eventsAttended"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-events&contentName=eventsAttended"
        }
        xAPIManager().checkMod(testUrl:urlString)
    }
    
    func goToAttendance() {
        if !iPad{
            self.attendanceSegmentControl.isHidden = false
        }
        hideUpperViews()
        attendance.isHidden = false
        attendance.isUserInteractionEnabled = false
        topLabel.text = localized("attendence_summary")
        
        //container.isHidden = false
        //London Developer July 24,2017
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-attendance-summary&contentName=attendanceGraph"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-attendance-summary&contentName=attendanceGraph"
        }
        xAPIManager().checkMod(testUrl:urlString)
        //   self.view.addSubview(attendance)
        
    }
    
    private func hideUpperViews() {
        container.isHidden = true
        leaderBoard.isHidden = true
        eventAtteneded.isHidden = true
        attendance.isHidden = true
    }
    
    @IBAction func changePeriod(_ sender:UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if (selectedModule == 0) {
                compareToButton.setTitle(localized("no_one"), for: UIControlState())
                selectedStudent = 0
            }
            selectedPeriod = 0
            titleLabel.text = "\(localized("last_7_days")) \(localized("engagement"))"
            break
        case 1:
            selectedPeriod = 1
            titleLabel.text = "\(localized("last_30_days")) \(localized("engagement"))"
            break
        default:
            break
        }
        getEngagementData()
    }
    
    @IBAction func changePointsPeriod(_ sender:UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            getActivityPoints(period: .SevenDays, completion: {
                
            })
            break
        case 1:
            getActivityPoints(period: .Overall, completion: {
                
            })
            break
        default:
            break
        }
    }
    
    //MARK: UITableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var nrRows = 0
        switch tableView {
        case attainmentTableView:
            if demo(){
                nrRows = attainmentDemoArray.count
            } else {
                nrRows = attainmentArray.count
                if let student = dataManager.currentStudent {
                    if student.affiliation.contains("glos.ac.uk") {
                        nrRows += 1
                    }
                }
            }
            
            
            break
        case pointsTable:
            nrRows = pointsArray.count
            break
        case eventsAttendedTableView:
            if demo(){
                nrRows = 3
            } else {
                nrRows = eventsAttendedArray.count
            }
            break
        default:
            break
        }
        return nrRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        switch tableView {
        case attainmentTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: kAttainmentCellIdentifier, for: indexPath)
            
            if let theCell = cell as? AttainmentCell {
                if demo(){
                    //theCell.nameLabel.text = attainmentDemoArray[indexPath.row]
                    //theCell.positionLabel.text = String(arc4random_uniform(50))
                } else if indexPath.row < attainmentArray.count {
                    let attObject = attainmentArray[indexPath.row]
                    theCell.loadAttainmentObject(attObject)
                } else {
                    theCell.loadAttainmentObject(nil)
                }
                
            }
            
            break
        case pointsTable:
            cell = tableView.dequeueReusableCell(withIdentifier: kPointsCellIdentifier, for: indexPath)
            if let theCell = cell as? PointsCell {
                theCell.loadPoints(points: pointsArray[indexPath.row])
            }
            break
        case eventsAttendedTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: "EventsAttendedCell", for: indexPath)
            
            if let theCell = cell as? EventsAttendedCell {
                if indexPath.row < eventsAttendedArray.count {
                    theCell.loadEvents(events: eventsAttendedArray[indexPath.row])
                }
            }
            break
            
        default:
            cell = UITableViewCell()
            break
        }
        return cell
    }
    
    //MARK: UITableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        
        switch tableView {
        case attainmentTableView:
            if demo(){
                numOfSections = 1
                return numOfSections
            } else {
                
                if (attainmentArray.count > 0)
                {
                    tableView.separatorStyle = .singleLine
                    numOfSections            = 1
                    tableView.backgroundView = nil
                }
                else
                {
                    let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                    noDataLabel.text          = localized("no_data_available")
                    noDataLabel.textColor     = UIColor.black
                    noDataLabel.textAlignment = .center
                    tableView.backgroundView  = noDataLabel
                    tableView.separatorStyle  = .none
                }
                
            }
            break
        case pointsTable:
            if (pointsArray.count > 0)
            {
                tableView.separatorStyle = .singleLine
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: tableView.bounds.size.height, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = localized("no_data_available")
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            
            break
        case eventsAttendedTableView:
            if demo(){
                numOfSections = 1
                return numOfSections
            }
            if (eventsAttendedArray.count > 1)
            {
                tableView.separatorStyle = .singleLine
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = localized("no_data_available")
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            
            break
            
        default:
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: tableView.bounds.size.height, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = localized("no_data_available")
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            break
        }
        
        
        
        return numOfSections
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch tableView {
        case attainmentTableView:
            if let theCell = cell as? AttainmentCell {
                if demo(){
                    //theCell.nameLabel.text = attainmentDemoArray[indexPath.row]
                    //theCell.positionLabel.text = String(arc4random_uniform(50))
                }
                if indexPath.row < attainmentArray.count {
                    let attObject = attainmentArray[indexPath.row]
                    theCell.loadAttainmentObject(attObject)
                } else {
                    theCell.loadAttainmentObject(nil)
                }
            }
            break
        case pointsTable:
            if let theCell = cell as? PointsCell {
                theCell.loadPoints(points: pointsArray[indexPath.row])
            }
            break
        case eventsAttendedTableView:
            if let theCell = cell as? EventsAttendedCell {
                if demo(){
                    for item in self.eventsAttendedDemoArray[indexPath.row]{
                        theCell.activityLabel.text = item
                        theCell.timeLabel.text = item
                        theCell.dateLabel.text = item
                        theCell.moduleLabel.text = item
                    }
                } else if indexPath.row < eventsAttendedArray.count {
                    theCell.loadEvents(events: eventsAttendedArray[indexPath.row])
                    
                } else {
                    //theCell.loadAttainmentObject(nil)
                }
                
            }
            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                
                self.eventsAttendedTableView.tableFooterView = spinner
                self.eventsAttendedTableView.tableFooterView?.isHidden = false
                self.eventsAttendedLimit = self.eventsAttendedLimit + 10
                getEventsAttended {
                    self.eventsAttendedTableView.reloadData()
                }
                spinner.stopAnimating()
            }
            
            break
        default:
            break
        }
    }
    
    //MARK - GRAPH
    
    @IBAction func toggleGraphType(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            graphType = .Bar
            self.graphTypePath = "bargraph"
        } else {
            graphType = .Line
            self.graphTypePath = "linegraph"
        }
        loadVLEChart()
        representValues(graphValues)
    }
    
    private func loadPieChart() {
        do {
            guard let filePath = Bundle.main.path(forResource: "stats_points_pi_chart", ofType: "html")
                else {
                    print ("File reading error")
                    return
            }
            
            pieChartWebView.setNeedsLayout()
            pieChartWebView.layoutIfNeeded()
            let w = pieChartWebView.frame.size.width - 20
            let h = pieChartWebView.frame.size.height - 20
            var contents = try String(contentsOfFile: filePath, encoding: .utf8)
            contents = contents.replacingOccurrences(of: "300px", with: "\(w)px")
            contents = contents.replacingOccurrences(of: "220px", with: "\(h)px")
            
            /* {
             name: 'Computer',
             y: 56.33
             }, {
             name: 'English',
             y: 24.03
             } */
            var data: String = ""
            
            for point in pointsArray {
                data += "{"
                if (point.activity == "Loggedin"){
                    data += "name:'\(localized("logged_in"))',"
                } else {
                    data += "name:'\(point.activity)',"
                }
                
                data += "y:\(point.points)"
                data += "},"
                if(point.points != 0){
                    self.noPointsLabel.isHidden = true
                }
            }
            contents = contents.replacingOccurrences(of: "REPLACE_DATA", with: data)
            
            if(pointsArray.count == 0 && !demo()){
                self.noPointsDataLabel.alpha = 1.0
            }
            
            let baseUrl = URL(fileURLWithPath: filePath)
            pieChartWebView.loadHTMLString(contents as String, baseURL: baseUrl)
        } catch {
            print ("File HTML error on pie chart")
            print("no results for points graph found")
            if(!demo()){
                self.noPointsDataLabel.alpha = 1.0
            }
        }
    }
    
    private func loadVLEChart(){
        if !iPad{
            do {
                guard let filePath = Bundle.main.path(forResource: self.graphTypePath, ofType: "html")
                    else {
                        print ("File reading error")
                        return
                }
                
                vleGraphWebView.setNeedsLayout()
                vleGraphWebView.layoutIfNeeded()
                let w = vleGraphWebView.frame.size.width - 20
                let h = vleGraphWebView.frame.size.height - 20
                var contents = try String(contentsOfFile: filePath, encoding: .utf8)
                contents = contents.replacingOccurrences(of: "300px", with: "\(w)px")
                contents = contents.replacingOccurrences(of: "220px", with: "\(h)px")
                var dateDataFinal = ""
                var countDateFinal = ""
                if (self.graphValues?.columnNames != nil) {
                    dateDataFinal = self.graphValues!.columnNames!.description
                } else {
                    dateDataFinal = ""
                }
                if (self.graphValues?.me != nil) {
                    countDateFinal = self.graphValues!.me!.description
                } else {
                    countDateFinal = ""
                }
                
                //dateDataFinal = "['23/09', '24/09', '25/09', '26/09', '27/09', '28/09', '29/09']"
                //let countDateFinal = "[8,9,9,6,2,8,2]"
                contents = contents.replacingOccurrences(of: "COUNT", with: countDateFinal)
                contents = contents.replacingOccurrences(of: "DATES", with: dateDataFinal)
                
                let baseUrl = URL(fileURLWithPath: filePath)
                vleGraphWebView.loadHTMLString(contents as String, baseURL: baseUrl)
            } catch {
                print ("File HTML error")
            }
        }
        
    }
    
    private func loadHighChart() {
        print("Loading HighChart")
        //let completionBlock:downloadCompletionBlock?
        var countArray:[Int] = []
        var dateArray:[String] = []
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let result = dateFormatter.string(from: todaysDate)
        let twentyEightDaysAgo = Calendar.current.date(byAdding: .day, value: -34, to: Date())
        let daysAgoResult = dateFormatter.string(from: twentyEightDaysAgo!)
        
        
        var urlStringCall = ""
        if(!dataManager.developerMode){
            urlStringCall = "https://api.datax.jisc.ac.uk/sg/weeklyattendance?startdate=\(daysAgoResult)&enddate=\(result)"
        } else {
            urlStringCall = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/weeklyattendance?startdate=\(daysAgoResult)&enddate=\(result)"
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
                
                print("data received for events graph")
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                        print("json count events graph \(json.count)")
                        
                        for item in json {
                            let object = item as? [String:Any]
                            if let count = object?["count"] as? Int {
                                countArray.append(count)
                            }
                            
                            if let date = object?["date"] as? NSString {
                                //Date DONE!! put in an array and pass to the graph same with count
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
                                    self.noDataLabel.alpha = 1.0
                                    self.graphContainer.alpha = 0.0
                                    return
                            }
                            
                            self.highChartWebView.setNeedsLayout()
                            self.highChartWebView.layoutIfNeeded()
                            let w = self.highChartWebView.frame.size.width - 20
                            let h = self.highChartWebView.frame.size.height - 20
                            var contents = try String(contentsOfFile: filePath, encoding: .utf8)
                            contents = contents.replacingOccurrences(of: "300px", with: "\(w)px")
                            contents = contents.replacingOccurrences(of: "220px", with: "\(h)px")
                            var countData:String = ""
                            var dateData: String = ""
                            for count in countArray {
                                countData = countData + String(count) + ", "
                            }
                            var countDataFinal:String = ""
                            let endIndex = countData.index(countData.endIndex, offsetBy: -2)
                            countDataFinal = "[" + countData.substring(to: endIndex) + "]"
                            for date in dateArray {
                                //Here is where I think I should add the formattinfg code.
                                
                                dateData = dateData + "'\(date)'" + ", "
                            }
                            var dateDataFinal:String = ""
                            let endIndexDate = dateData.index(dateData.endIndex, offsetBy: -2)
                            
                            dateDataFinal = "[" + dateData.substring(to: endIndexDate) + "]"
                            
                            
                            contents = contents.replacingOccurrences(of: "COUNT", with: countDataFinal)
                            contents = contents.replacingOccurrences(of: "DATES", with: dateDataFinal)
                            
                            if(dateArray.count == 0){
                                self.noDataLabel.alpha = 1.0
                                self.noDataLabel.textColor = UIColor.black
                                self.noDataLabel.text = localized("no_data_available")
                                self.noDataLabel.isHidden = false
                                self.graphContainer.alpha = 0.0
                            }
                            
                            let baseUrl = URL(fileURLWithPath: filePath)
                            self.highChartWebView.loadHTMLString(contents as String, baseURL: baseUrl)
                            
                        } catch {
                            print ("File HTML error for events graph")
                            self.noDataLabel.alpha = 1.0
                            self.noDataLabel.textColor = UIColor.black
                            self.noDataLabel.text = localized("no_data_available")
                            self.noDataLabel.isHidden = false
                            self.graphContainer.alpha = 0.0
                        }
                    }
                } catch {
                    print("Error deserializing JSON for events graph: \(error)")
                    self.noDataLabel.alpha = 1.0
                    self.noDataLabel.textColor = UIColor.black
                    self.noDataLabel.text = localized("no_data_available")
                    self.noDataLabel.isHidden = false
                    self.graphContainer.alpha = 0.0
                    
                }
            }
            //startConnectionWithRequest(request)
        } else {
            // completionBlock?(false, nil, nil, "Error creating the url request")
            print("no results for events graph found")
            self.noDataLabel.alpha = 1.0
            self.noDataLabel.textColor = UIColor.black
            self.noDataLabel.text = localized("no_data_available")
            self.noDataLabel.isHidden = false
            self.graphContainer.alpha = 0.0
        }
        
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
        let getTopTenPercent = false
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
                studentID = localized("average_small")
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
                self.loadVLEChart()
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
        if (sender != nil) {
            if (sender!.columnNames != nil) {
                if (sender!.columnNames!.count > 7) {
                    graphContainerWidth.constant = min(60.0 * (CGFloat)(sender!.columnNames!.count), 8000.0)
                } else {
                    //Testing for ipad commented the following line
                    //graphContainerWidth.constant = initialGraphWidth
                }
                view.layoutIfNeeded()
            } else {
                graphContainerWidth.constant = initialGraphWidth
                view.layoutIfNeeded()
            }
        } else {
            graphContainerWidth.constant = initialGraphWidth
            view.layoutIfNeeded()
        }
        
        theGraphView?.removeFromSuperview()
        graphScroll.setContentOffset(CGPoint.zero, animated: false)
        var values = sender
        if (values != nil) {
            graphContainer.alpha = 1.0
            var maximum = Double(0.0)
            if (values!.me != nil) {
                for (_, item) in values!.me!.enumerated() {
                    maximum = max(maximum, item)
                }
            }
            if (values!.otherStudent != nil) {
                for (_, item) in values!.otherStudent!.enumerated() {
                    maximum = max(maximum, item)
                }
            }
            if (maximum > 3) {
                self.setVerticalValues(["0", "\(Int(maximum * 0.25))", "\(Int(maximum * 0.5))", "\(Int(maximum * 0.75))", "\(Int(maximum))"])
            } else if (maximum >= 2) {
                self.setVerticalValues(["0", "1", "\(Int(maximum))"])
            } else {
                self.setVerticalValues(["0", "1"])
            }
            if (values!.columnNames != nil) {
                self.setHorizontalValues(values!.columnNames!)
            }
            let frame = graphContainer.bounds
            var myV:[Double]?
            var hisV:[Double]?
            if (values!.me != nil) {
                if (values!.me!.count < 3) {
                    values!.me!.insert(0.0, at: 0)
                    values!.me!.append(0.0)
                }
                myV = values!.me
            }
            if (values!.otherStudent != nil) {
                if (values!.otherStudent!.count < 3) {
                    values!.otherStudent!.insert(0.0, at: 0)
                    values!.otherStudent!.append(0.0)
                }
                hisV = values!.otherStudent
            }
            
            if (maximum == 0.0) {
                noDataLabel.alpha = 1.0
                graphContainer.alpha = 0.0
                setVerticalValues([])
                setHorizontalValues([])
            } else {
                if (myV != nil) {
                    if (hisV != nil) {
                        switch graphType {
                        case .Line:
                            theGraphView = GraphGenerator.drawLineGraphInView(graphContainer, frame: frame, values: [myV!, hisV!], colors: [myColor, otherStudentColor], animationDuration: 0.0)
                            break
                        case .Bar:
                            theGraphView = GraphGenerator.drawBarChartInView(graphContainer, frame: frame, values: [myV!, hisV!], colors: [myColor, otherStudentColor])
                            break
                        }
                    } else {
                        switch graphType {
                        case .Line:
                            theGraphView = GraphGenerator.drawLineGraphInView(graphContainer, frame: frame, values: [myV!], colors: [myColor], animationDuration: 0.0)
                            break
                        case .Bar:
                            theGraphView = GraphGenerator.drawBarChartInView(graphContainer, frame: frame, values: [myV!], colors: [myColor])
                            break
                        }
                    }
                } else if (hisV != nil) {
                    switch graphType {
                    case .Line:
                        theGraphView = GraphGenerator.drawLineGraphInView(graphContainer, frame: frame, values: [hisV!], colors: [otherStudentColor], animationDuration: 0.0)
                        break
                    case .Bar:
                        theGraphView = GraphGenerator.drawBarChartInView(graphContainer, frame: frame, values: [hisV!], colors: [otherStudentColor])
                        break
                    }
                }
            }
        } else {
            noDataLabel.alpha = 1.0
        }
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
        //London Developer July 24,2017
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
        //Getting called for FilteredStatModuleMain
        // Add in a condition with all activity do not send the request.
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
        } else{
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
        }
        xAPIManager().checkMod(testUrl:urlString)
        if leaderBoard.isHidden == false {
            var urlString = ""
            if(!dataManager.developerMode){
                urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-leaderboard-module&contentName=leaderboardFilteredByModule&modid=\(String(describing: moduleID))"
            } else {
                urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-leaderboard-module&contentName=leaderboardFilteredByModule&modid=\(String(describing: moduleID))"
            }
            xAPIManager().checkMod(testUrl:urlString)
        }
        
        if eventAtteneded.isHidden == false{
            var urlString = ""
            if(!dataManager.developerMode){
                urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
            } else {
                urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
            }
            xAPIManager().checkMod(testUrl:urlString)
        }
        
        if (attendance.isHidden == false){
            var urlString = ""
            if(!dataManager.developerMode){
                urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
            } else {
                urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
            }
            xAPIManager().checkMod(testUrl:urlString)
        }
        
        
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
        if scrollView == graphScroll {
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
}


extension Array {
    
    func filterDuplicates( includeElement: @noescape (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element]{
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
}
