//
//  SingleTargetVC.swift
//  Jisc
//
//  Created by Therapy Box on 18/08/2017.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

let emptySingleTargetPageMessage = localized("empty_target_page_message")
let myNotificationKey = "goToSingleTarget"
var optionsOpened = false

class SingleTargetVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var singleTargetTableView: UITableView!
    var aSingleCellIsOpen:Bool = false
    var arrayOfResponses: [[String:Any]] = []
    var arrayOfResponses2: [[String:Any]] = []
    var noHeight = 0.0
    var refreshTimer:Timer?
    
    @IBOutlet weak var singleTargetSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xAPIManager().checkMod(testUrl:"https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-main&contentName=recurringTargetsPage")
        
        singleTargetTableView.register(UINib(nibName: kTargetCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kTargetCellIdentifier)
        singleTargetSegmentControl.selectedSegmentIndex = 0
        singleTargetTableView.contentInset = UIEdgeInsetsMake(20.0, 0, 20.0, 0)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(SingleTargetVC.manuallyRefreshFeeds(_:)), for: UIControlEvents.valueChanged)
        singleTargetTableView.addSubview(refreshControl)
        
        singleTargetTableView.delegate = self
        singleTargetTableView.dataSource = self
        singleTargetTableView.reloadData()
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-main&contentName=MainTargetsPage"
        } else {
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-main&contentName=MainTargetsPage"
        }
        xAPIManager().checkMod(testUrl:urlString)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(navigateToEditSingleTarget),
                                               name: NSNotification.Name(rawValue: myNotificationKey),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(callGetToDoList),
                                               name: NSNotification.Name(rawValue: "getToDoList"),
                                               object: nil)
    }
    
    /**
     Reloads the single target data.
     
     :sender: refresh control that triggered the action
     */
    func manuallyRefreshFeeds(_ sender:UIRefreshControl) {
        getTodoListData()
        self.singleTargetTableView.reloadData()
        sender.endRefreshing()
    }
    
    /**
     Navigates to add single target view when notified.
     */
    func navigateToEditSingleTarget(){
        let vc = RecurringTargetVC()
        vc.cameFromEditing()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    /**
     Reloads the single target data by calling getTodoListData.
     */
    func callGetToDoList(){
        getTodoListData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        kButtonsWidth = 240
        getTodoListData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        singleTargetTableView.reloadData()
    }
    
    /**
     Opens menu drawer.
     
     :sender: button that triggered the action
     */
    @IBAction func openMenuAction(_ sender: Any) {
        DELEGATE.menuView?.open()
    }
    
    /**
     Starts the add single target action.
     
     :sender: button that triggered the action
     */
    @IBAction func newTargetAction(_ sender: Any) {
        let vc = RecurringTargetVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
     Handles segment controller action.
     
     :sender: button that triggered the action
     */
    @IBAction func singelTargetSegmentAction(_ sender: Any) {
        if (singleTargetSegmentControl.selectedSegmentIndex == 0){
            let vc = SingleTargetVC()
            navigationController?.pushViewController(vc, animated: false)
        } else {
            let vc = TargetVC()
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    /**
     Reloads the single target data.
     
     :sender: button that triggered the action
     */
    private func getTodoListData(){
        self.arrayOfResponses.removeAll()
        self.arrayOfResponses2.removeAll()
        
        var urlStringCall = ""
        
        if social(){
            urlStringCall = "https://stuapp.analytics.alpha.jisc.ac.uk/fn_get_todo_list?is_social=true&language=en&is_social=no"
        } else {
            urlStringCall = "https://stuapp.analytics.alpha.jisc.ac.uk/fn_get_todo_list?student_id=\(dataManager.currentStudent!.id)&language=en&is_social=no"
        }
        
        var request:URLRequest?
        if let urlString = urlStringCall.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
        }
        if var request = request {
            if let token = xAPIToken() {
                request.addValue("\(token)", forHTTPHeaderField: "Authorization")
            }
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                        
                        for item in json {
                            let object = item as? [String:Any]
                            let singleDictionary = object
                            let status = singleDictionary?["from_tutor"] as! String
                            let status2 = singleDictionary?["is_accepted"] as! String
                            let status3 = singleDictionary?["status"] as! String
                            
                            if (status3 == "1" ){
                                print("complete task")
                            } else if(status == "yes" && status2 == "0"){
                                self.arrayOfResponses2.append(object!)
                            } else {
                                self.arrayOfResponses.append(object!)
                            }
                            print("it works \(status)");
                        }
                        for item in self.arrayOfResponses2{
                            self.arrayOfResponses.insert(item, at: 0)
                        }
                        let defaults = UserDefaults.standard
                        defaults.set(self.arrayOfResponses, forKey: "AllTheSingleTargets")
                        self.singleTargetTableView.reloadData()
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
            }
        }
    }
    
    //MARK: UITableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfResponses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let theCell = tableView.dequeueReusableCell(withIdentifier: kTargetCellIdentifier) as! TargetCell
        theCell.completionColorView.isHidden = true
        print(indexPath.row)
        
        print("This is the array of responses in SingleTargetVC", arrayOfResponses)
        let singleDictionary = arrayOfResponses[indexPath.row]
        let describe = singleDictionary["description"] as! String
        let endDate = singleDictionary["end_date"] as! String
        let module = singleDictionary["module"] as! String
        let reason = singleDictionary["reason"] as! String
        let status = singleDictionary["from_tutor"] as! String
        let status2 = singleDictionary["is_accepted"] as! String
        if (status == "0"){
        }
        if(status == "yes" && status2 == "0"){
            
        } else if (status == "yes" && status2 == "2"){
            
        } else {
            print("This is the array of responses in SingleTargetVC", arrayOfResponses)
            let singleDictionary = arrayOfResponses[indexPath.row]
            let describe = singleDictionary["description"] as! String
            let endDate = singleDictionary["end_date"] as! String
            let module = singleDictionary["module"] as! String
            let reason = singleDictionary["reason"] as! String
            let status = singleDictionary["from_tutor"] as! String
            let status2 = singleDictionary["is_accepted"] as! String
            
            if(status == "yes" && status2 == "0"){
                theCell.backgroundColor = UIColor(red: 186.0/255.0, green: 216.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            } else if (status == "yes" && status2 == "2"){
                theCell.backgroundColor = UIColor.red
            } else {
                theCell.backgroundColor = UIColor.clear
                
            }
            let todaysDateObject = Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd"
            dateFormatter.locale = Locale.init(identifier: "en_GB")
            
            let dateObj = dateFormatter.date(from: endDate)
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            let finalDate = dateFormatter.string(from: dateObj!)
            
            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: todaysDateObject)
            let date2 = calendar.startOfDay(for: dateObj!)
            
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            let numberOfDaysAgo = components.day
            
            var finalText = ""
            if (module.isEmpty || module == "no_module" || module.uppercased() == "NO MODULE" || module == "No Module"){
                if (Calendar.current.isDateInTomorrow(dateObj!)){
                    if (reason.isEmpty || reason == "Add a reason to keep this target"){
                        finalText = "\(describe) by tomorrow"
                    } else {
                        finalText = "\(describe) by tomorrow because \(reason.lowercased())"
                    }
                } else if (Calendar.current.isDateInToday(dateObj!)){
                    if (reason.isEmpty || reason == "Add a reason to keep this target"){
                        finalText = "\(describe) by end of today"
                    } else {
                        finalText = "\(describe) by end of today because \(reason.lowercased())"
                    }
                } else if (numberOfDaysAgo! < 0){
                    if (reason.isEmpty || reason == "Add a reason to keep this target"){
                        finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe)"
                    } else {
                        finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe) because \(reason.lowercased())"
                    }
                } else {
                    if (reason.isEmpty || reason == "Add a reason to keep this target"){
                        finalText = "\(describe) by \(finalDate)"
                    } else {
                        finalText = "\(describe) by \(finalDate) because \(reason.lowercased())"
                    }
                }
            } else if (reason.isEmpty || reason == "Add a reason to keep this target"){
                if (Calendar.current.isDateInTomorrow(dateObj!)){
                    finalText = "\(describe) for \(module) by tomorrow"
                } else if (Calendar.current.isDateInToday(dateObj!)){
                    finalText = "\(describe) for \(module) by end of today"
                } else if (numberOfDaysAgo! < 0 ){
                    if(module.isEmpty || module == "no_module" || module == "no module" || module == "No Module"){
                        finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe)"
                    } else {
                        finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe) for \(module)"
                    }
                } else {
                    finalText = "\(describe) for \(module) by \(finalDate)"
                }
            } else {
                if (Calendar.current.isDateInTomorrow(dateObj!)){
                    finalText = "\(describe) by tomorrow"
                } else if (Calendar.current.isDateInToday(dateObj!)){
                    finalText = "\(describe) by end of today"
                } else if (numberOfDaysAgo! < 0){
                    finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe)"
                } else {
                    finalText = "\(describe) by \(finalDate)"
                }
            }
            
            /*
             1. Cool is for if there are more than 7 days remaining
             2. watch_time is for fewer than 7 days but more than 2 days before end date.
             3. watch_time_sweet is for 1 day before
             4. watch_time_panik for same day
             5. watch_time_break for overdue
             */
            theCell.targetTypeIcon.image = nil
            if (numberOfDaysAgo! >= 7) {
                theCell.targetTypeIcon.image = UIImage(named: "cool")
            } else if (numberOfDaysAgo! < 7 && numberOfDaysAgo! >= 2){
                theCell.targetTypeIcon.image = UIImage(named: "watch_time")
            } else if (numberOfDaysAgo! == 1){
                theCell.targetTypeIcon.image = UIImage(named: "watch_time_sweet")
            } else if (numberOfDaysAgo! == 0){
                theCell.targetTypeIcon.image = UIImage(named: "watch_time_panic")
            } else {
                theCell.targetTypeIcon.image = UIImage(named: "watch_time_break")
            }
            
            theCell.textLabel?.numberOfLines = 6
            theCell.completionColorView.isHidden = true
            theCell.titleLabel.text = finalText
        }
        
        return theCell
    }
    
    //MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let singleDictionary = arrayOfResponses[indexPath.row]
        let status = singleDictionary["status"] as! String
        let status1 = singleDictionary["from_tutor"] as! String
        let status2 = singleDictionary["is_accepted"] as! String
        
        if(status1 == "yes" && status2 == "0"){
            return 108.0
        } else if (status1 == "yes" && status2 == "2"){
            return 0.0
        }  else if (status1 == "yes" && status2 == "1"){
            return 0.0
        } else {
            return 108.0
        }
        if (status == "0"){
            return 108.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let theCell:TargetCell? = cell as? TargetCell
        theCell?.completionColorView.isHidden = true
        if (theCell != nil) {
            theCell!.indexPath = indexPath
            theCell!.tableView = tableView
            theCell!.navigationController = navigationController
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!demo()) {
            let singleDictionary = arrayOfResponses[indexPath.row]
            let status = singleDictionary["from_tutor"] as! String
            let status2 = singleDictionary["is_accepted"] as! String
            if(status == "yes" && status2 == "0"){
                let alert = UIAlertController(title: "", message: "Would you like to accept this target request?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: localized("yes"), style: .default, handler: { (action) in
                    var dictionaryfordis = [String:String]()
                    dictionaryfordis.updateValue("1", forKey: "is_accepted")
                    dictionaryfordis.updateValue(String(describing: singleDictionary["student_id"]!), forKey: "student_id")
                    dictionaryfordis.updateValue(String(describing: singleDictionary["id"]!), forKey: "record_id")
                    dictionaryfordis.updateValue(singleDictionary["module"] as! String, forKey: "module")
                    dictionaryfordis.updateValue(singleDictionary["from_tutor"] as! String, forKey: "from_tutor")
                    
                    dictionaryfordis.updateValue(singleDictionary["description"] as! String, forKey: "description")
                    dictionaryfordis.updateValue(singleDictionary["end_date"] as! String, forKey: "end_date")
                    dictionaryfordis.updateValue("en", forKey: "language")
                    if currentUserType() == .social {
                        dictionaryfordis.updateValue("yes", forKey: "is_social")
                        
                    } else {
                        dictionaryfordis.updateValue("no", forKey: "is_social")
                    }
                    
                    DownloadManager().editToDo(dictionary:dictionaryfordis)
                    xAPIManager().checkMod(testUrl:"https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-accept-tutor-target&contentName=acceptTarget")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.getTodoListData()
                    }
                }))
                alert.addAction(UIAlertAction(title: localized("no"), style: .default, handler: { (action) in
                    let alert2 = UIAlertController(title: "", message: "Please give a reason for rejecting this target", preferredStyle: .alert)
                    alert2.addTextField { (textField) in
                        textField.placeholder = "Description"
                    }
                    alert2.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { (action) in
                        if let field = alert2.textFields?[0] {
                            print("\(field.text!)")
                            var dictionaryfordis = [String:String]()
                            dictionaryfordis.updateValue("2", forKey: "is_accepted")
                            dictionaryfordis.updateValue(String(describing: singleDictionary["student_id"]!), forKey: "student_id")
                            dictionaryfordis.updateValue(String(describing: singleDictionary["id"]!), forKey: "record_id")
                            dictionaryfordis.updateValue(singleDictionary["module"] as! String, forKey: "module")
                            dictionaryfordis.updateValue(singleDictionary["from_tutor"] as! String, forKey: "from_tutor")
                            
                            dictionaryfordis.updateValue(singleDictionary["description"] as! String, forKey: "description")
                            dictionaryfordis.updateValue(singleDictionary["end_date"] as! String, forKey: "end_date")
                            dictionaryfordis.updateValue(field.text!, forKey: "reason_for_ignoring")
                            
                            dictionaryfordis.updateValue("en", forKey: "language")
                            if currentUserType() == .social {
                                dictionaryfordis.updateValue("yes", forKey: "is_social")
                            } else {
                                dictionaryfordis.updateValue("no", forKey: "is_social")
                            }
                            DownloadManager().editToDo(dictionary:dictionaryfordis)
                            xAPIManager().checkMod(testUrl:"https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-decline-tutor-target&contentName=declineTarget")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.getTodoListData()
                            }
                        } else {
                            var dictionaryfordis = [String:String]()
                            dictionaryfordis.updateValue("2", forKey: "is_accepted")
                            dictionaryfordis.updateValue(String(describing: singleDictionary["student_id"]!), forKey: "student_id")
                            dictionaryfordis.updateValue(String(describing: singleDictionary["id"]!), forKey: "record_id")
                            dictionaryfordis.updateValue(singleDictionary["from_tutor"] as! String, forKey: "from_tutor")
                            
                            dictionaryfordis.updateValue(singleDictionary["module"] as! String, forKey: "module")
                            dictionaryfordis.updateValue(singleDictionary["description"] as! String, forKey: "description")
                            dictionaryfordis.updateValue(singleDictionary["end_date"] as! String, forKey: "end_date")
                            
                            dictionaryfordis.updateValue("en", forKey: "language")
                            if currentUserType() == .social {
                                dictionaryfordis.updateValue("yes", forKey: "is_social")
                            } else {
                                dictionaryfordis.updateValue("no", forKey: "is_social")
                            }
                            DownloadManager().editToDo(dictionary:dictionaryfordis)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.getTodoListData()
                            }
                        }
                    }))
                    self.navigationController?.present(alert2, animated: true, completion: nil)
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.navigationController?.present(alert, animated: true, completion: nil)
            } else {
                if let cell = tableView.cellForRow(at: indexPath) as? TargetCell {
                    if(!cell.optionsOpened){
                        cell.openCellOptions()
                    } else {
                        cell.closeCellOptions()
                    }
                }
            }
        }
    }
}
