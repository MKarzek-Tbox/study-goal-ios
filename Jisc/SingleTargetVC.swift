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

class SingleTargetVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var singleTargetTableView: UITableView!
    var aSingleCellIsOpen:Bool = false
    var arrayOfResponses: [[String:Any]] = []
    var arrayOfResponses2: [[String:Any]] = []
    var noHeight = 0.0
    var demoData:[String] = ["These Single Targets are for demo purposes only, login to use the full functionality","3 DAYS OVERDUE! Read 2 chapters for history class ","Do maths assignment by tomorrow because it is due", "Swipe to the left to to edit, delete and mark as done", "You can accept or deny certain tutor set targert", "Switch between single or recurring targets that you want to post", "The icons indicate the urgency of the due date for that specific target"]
    var refreshTimer:Timer?


    @IBOutlet weak var singleTargetSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleTargetTableView.register(UINib(nibName: kTargetCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kTargetCellIdentifier)
        singleTargetSegmentControl.selectedSegmentIndex = 0
        singleTargetTableView.contentInset = UIEdgeInsetsMake(20.0, 0, 20.0, 0)
        //refreshTimer = Timer(timeInterval: 30, target: self, selector: #selector(FeedVC.refreshFeeds(_:)), userInfo:nil, repeats: true)
        //RunLoop.current.add(refreshTimer!, forMode: RunLoopMode.commonModes)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(SingleTargetVC.manuallyRefreshFeeds(_:)), for: UIControlEvents.valueChanged)
        singleTargetTableView.addSubview(refreshControl)

        singleTargetTableView.delegate = self
        singleTargetTableView.dataSource = self
        singleTargetTableView.reloadData()
        //London Developer July 24,2017
        let urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-main&contentName=MainTargetsPage"
        xAPIManager().checkMod(testUrl:urlString)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(doThisWhenNotify),
                                               name: NSNotification.Name(rawValue: myNotificationKey),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(callGetToDoList),
                                               name: NSNotification.Name(rawValue: "getToDoList"),
                                               object: nil)

    }
    
    
    func manuallyRefreshFeeds(_ sender:UIRefreshControl) {
        getTodoListData()
        self.singleTargetTableView.reloadData()
        sender.endRefreshing()
        
    }

    
    func doThisWhenNotify(){
        let vc = RecurringTargetVC()
        vc.cameFromEditing()
        navigationController?.pushViewController(vc, animated: false)
    }
    
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

    @IBAction func openMenuAction(_ sender: Any) {
        DELEGATE.menuView?.open()
    }

    @IBAction func newTargetAction(_ sender: Any) {
        if demo() {
            let alert = UIAlertController(title: "", message: localized("demo_mode_addtarget"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
        } else {
            let vc = RecurringTargetVC()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func singelTargetSegmentAction(_ sender: Any) {
        if (singleTargetSegmentControl.selectedSegmentIndex == 0){
            let vc = SingleTargetVC()
            navigationController?.pushViewController(vc, animated: false)
            
        } else {
            let vc = TargetVC()
            navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
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

                        defaults.set(self.arrayOfResponses, forKey: "AllTheSingleTargets") //My goal text

                        self.singleTargetTableView.reloadData()

                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
            }
            //startConnectionWithRequest(request)
        } else {
            // completionBlock?(false, nil, nil, "Error creating the url request")
        }
    }
    
    //MARK: UITableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let nrRows = dataManager.targets().count
//        if (nrRows == 0) {
//            emptyScreenMessageView.alpha = 1.0
//        } else {
//            emptyScreenMessageView.alpha = 0.0
//        }
        if demo(){
            return demoData.count
        } else {
            return arrayOfResponses.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let theCell = tableView.dequeueReusableCell(withIdentifier: kTargetCellIdentifier) as! TargetCell
        print(indexPath.row)
//        if (theCell == nil) {
//            theCell = UITableViewCell()
//        }
        if demo(){
            theCell.titleLabel.text = demoData[indexPath.row]
            theCell.targetTypeIcon.image = UIImage(named: "watch_time_sweet")
            theCell.completionColorView.isHidden = true
        } else {
        print("This is the array of responses in SingleTargetVC", arrayOfResponses)
        let singleDictionary = arrayOfResponses[indexPath.row] 
        let describe = singleDictionary["description"] as! String
        let endDate = singleDictionary["end_date"] as! String
        let module = singleDictionary["module"] as! String
        let reason = singleDictionary["reason"] as! String
        let status = singleDictionary["from_tutor"] as! String
        let status2 = singleDictionary["is_accepted"] as! String
         if (status == "0"){
          //  theCell.isHidden = true
            
        }
        if(status == "yes" && status2 == "0"){
            theCell.backgroundColor = UIColor(red: 186.0/255.0, green: 216.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        } else if (status == "yes" && status2 == "2"){
            theCell.backgroundColor = UIColor.red
            theCell.isHidden = true
        } else {
            print("This is the array of responses in SingleTargetVC", arrayOfResponses)
            let singleDictionary = arrayOfResponses[indexPath.row]
            let describe = singleDictionary["description"] as! String
            let endDate = singleDictionary["end_date"] as! String
            let module = singleDictionary["module"] as! String
            let reason = singleDictionary["reason"] as! String
            let status = singleDictionary["from_tutor"] as! String
            let status2 = singleDictionary["is_accepted"] as! String
            if (status == "0"){
                //theCell.isHidden = true
                
            }
            if(status == "yes" && status2 == "0"){
                theCell.backgroundColor = UIColor(red: 186.0/255.0, green: 216.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            } else if (status == "yes" && status2 == "2"){
                theCell.backgroundColor = UIColor.red
            } else {
                theCell.backgroundColor = UIColor.clear
                
            }
            let todaysDateObject = Date()
            
            //The date formatter of the incoming JSON date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd"
            dateFormatter.locale = Locale.init(identifier: "en_GB")
            //Formatting the date to something like Monday August 21, 2017
            let dateObj = dateFormatter.date(from: endDate)
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            let finalDate = dateFormatter.string(from: dateObj!)
            
            //Setting up some variables to compare today's date with the date incoming from the JSON and
            //how long ago it was
            let calendar = Calendar.current
            // Replace the hour (time) of both dates with 00:00 for a fair full day comparision.
            let date1 = calendar.startOfDay(for: todaysDateObject)
            let date2 = calendar.startOfDay(for: dateObj!)
            
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            let numberOfDaysAgo = components.day
            
            var finalText = ""
            //Checks to see if the module, reason sections are empty and returning the appropriate date.
            if (module.isEmpty || module == "no_module"){
                if (Calendar.current.isDateInTomorrow(dateObj!)){
                    finalText = "\(describe) by tomorrow because \(reason.lowercased())"
                } else if (Calendar.current.isDateInToday(dateObj!)){
                    finalText = "\(describe) by end of today because \(reason.lowercased())"
                } else if (numberOfDaysAgo! < 0){
                    finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe) because \(reason.lowercased())"
                    
                } else {
                    finalText = "\(describe) by \(finalDate) because \(reason.lowercased())"
                }
            } else if (reason.isEmpty || reason == "Add a reason to keep this target"){
                if (Calendar.current.isDateInTomorrow(dateObj!)){
                    finalText = "\(describe) for \(module) by tomorrow"
                } else if (Calendar.current.isDateInToday(dateObj!)){
                    finalText = "\(describe) for \(module) by end of today"
                } else if (numberOfDaysAgo! < 0 ){
                    if(module.isEmpty || module == "no_module"){
                        finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe)"
                    } else {
                        finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe) for \(module)"
                    }
                } else {
                    finalText = "\(describe) for \(module) by \(finalDate)"
                }
            } else {
                if (Calendar.current.isDateInTomorrow(dateObj!)){
                    finalText = "\(describe) by tomorrow because \(reason.lowercased())"
                } else if (Calendar.current.isDateInToday(dateObj!)){
                    finalText = "\(describe) by end of today because \(reason.lowercased())"
                } else if (numberOfDaysAgo! < 0){
                    finalText = "\(numberOfDaysAgo! * -1) DAYS OVERDUE \(describe) because \(reason.lowercased())"
                } else {
                    finalText = "\(describe) by \(finalDate) because \(reason.lowercased())"
                }
            }
            
            /*
             1. Cool is for if there are more than 7 days remaining
             2. watch_time is for fewer than 7 days but more than 2 days before end date.
             3. watch_time_sweet is for 1 day before
             4. watch_time_panik for same day
             5. watch_time_break for overdue
             */
            //Setting in the appropriate images
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
            
            //theCell.textLabel?.adjustsFontSizeToFitWidth = true
            theCell.textLabel?.numberOfLines = 6
            theCell.completionColorView.isHidden = true
            theCell.titleLabel.text = finalText
        }
        }
        
        return theCell
    }
    
    //MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if demo(){
            return 108.0

        } else {
        let singleDictionary = arrayOfResponses[indexPath.row]
        let status = singleDictionary["status"] as! String
        let status1 = singleDictionary["from_tutor"] as! String
        let status2 = singleDictionary["is_accepted"] as! String
        if (status == "0"){
            //theCell.isHidden = true
            
        }
        if(status1 == "yes" && status2 == "0"){
            return 108.0
        } else if (status1 == "yes" && status2 == "2"){
            return 0.0
            //theCell.isHidden = true
        }  else if (status1 == "yes" && status2 == "1"){
            return 0.0
            //theCell.isHidden = true
        } else {
            return 108.0
        }
        if (status == "0"){
            return 108.0
        }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let theCell:TargetCell? = cell as? TargetCell
  if (theCell != nil) {
//            theCell!.loadTarget(dataManager.targets()[indexPath.row], isLast:(indexPath.row == (dataManager.targets().count - 1)))
            theCell!.indexPath = indexPath
            theCell!.tableView = tableView
            theCell!.navigationController = navigationController
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (aSingleCellIsOpen) {
//            tableView.reloadData()
//        } else {
//            let target = dataManager.targets()[indexPath.row]
//            let vc = TargetDetailsVC(target: target, index: indexPath.row)
//            navigationController?.pushViewController(vc, animated: true)
//            
//        }
        if demo(){
        
        } else {
            print("Should be runnning did select row at indexpath", indexPath.row)
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
                    //            let url = ""
                    //            let body = ""
                    //            xAPIManager().postRequest(testUrl: <#T##String#>, body: <#T##String#>)
                    DownloadManager().editToDo(dictionary:dictionaryfordis)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // your code here
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
                            // store your data
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                // your code here
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
                                // your code here
                                self.getTodoListData()
                            }
                            // user did not fill field
                        }
                    }))
                    self.navigationController?.present(alert2, animated: true, completion: nil)
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.navigationController?.present(alert, animated: true, completion: nil)
            }
            
        }
        
        }
        
}
