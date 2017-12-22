//
//  AttainmentViewController.swift
//  Jisc
//
//  Created by therapy box on 12/10/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class AttainmentObject {
    var date:Date
    var moduleName:String
    var grade:String
    var dateString:String
    
    init(date:Date, moduleName:String, grade:String) {
        self.date = date
        self.moduleName = moduleName
        self.grade = grade
        self.dateString = ""
    }
    init(dateString:String, moduleName:String, grade:String){
        self.dateString = dateString
        self.moduleName = moduleName
        self.grade = grade
        self.date = Date()
    }
}

class AttainmentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomPickerViewDelegate  {
    
    @IBOutlet weak var tableView:UITableView!
    var attainmentData = [AttainmentObject]()
    
    @IBOutlet weak var moduleButton:UIButton!
    var moduleSelectorView:CustomPickerView = CustomPickerView()
    var selectedModule:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup table view
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAttainmentData(_:)), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshControl)
        tableView.alwaysBounceVertical = true
        tableView.estimatedRowHeight = 35.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: kAttainmentCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kAttainmentCellIdentifier)
        tableView.alwaysBounceVertical = false;
        tableView.tableFooterView = UIView()
        
        //get attainment date
        attainmentData.removeAll()
        getAttainmentData { }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Open menu drawer.
     
     :sender: button that triggered the action
     */
    @IBAction func openMenu(_ sender:UIButton?) {
        DELEGATE.menuView?.open()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attainmentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kAttainmentCellIdentifier, for: indexPath)
        
        if let attainmentCell = cell as? AttainmentCell {
            if indexPath.row < attainmentData.count {
                let attObject = attainmentData[indexPath.row]
                attainmentCell.loadAttainmentObject(attObject)
            } else {
                attainmentCell.loadAttainmentObject(nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let attainmentCell = cell as? AttainmentCell {
            if indexPath.row < attainmentData.count {
                let attObject = attainmentData[indexPath.row]
                attainmentCell.loadAttainmentObject(attObject)
            } else {
                attainmentCell.loadAttainmentObject(nil)
            }
        }
    }
    
    /**
     Refreshes attainment data
     
     :sender: refresh control that triggered the action
     */
    func refreshAttainmentData(_ sender:UIRefreshControl) {
        getAttainmentData {
            sender.endRefreshing()
        }
    }
    
    /**
     Gets the attainment data.
     
     :completion: completion block
     */
    func getAttainmentData(_ completion:@escaping (() -> Void)) {
        attainmentData.removeAll()
        tableView.reloadData()
        let xMGR = xAPIManager()
        xMGR.silent = true
        xMGR.getAttainment() { (success, result, results, error) in
            self.attainmentData.removeAll()
            if (results != nil) {
                print(results)
                for (_, item) in results!.enumerated() {
                    if let dictionary = item as? NSDictionary {
                        if let grade = dictionary["ASSESS_AGREED_GRADE"] as? String {
                            if let moduleName = dictionary["X_MOD_NAME"] as? String {
                                if let dateString = dictionary["CREATED_AT"] as? String {
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    if let date = dateFormatter.date(from: dateString) {
                                        self.attainmentData.append(AttainmentObject(date: date, moduleName: moduleName, grade: grade))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.attainmentData.sort(by: { (obj1:AttainmentObject, obj2:AttainmentObject) -> Bool in
                return (obj2.date.compare(obj1.date) != .orderedDescending)
            })
            self.tableView.reloadData()
            
            //set null message
            if(self.attainmentData.count == 0){
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                noDataLabel.text = localized("no_data_available")
                noDataLabel.textColor = UIColor.black
                noDataLabel.textAlignment = .center
                self.tableView.backgroundView = noDataLabel
                self.tableView.separatorStyle = .none
            }
            
            completion()
        }
    }
    
    /**
     Shows module selector view.
     
     :sender: button that triggered the action
     */
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
        
        var moduleID:String? = nil
        
        if (selectedModule > 0) {
            var theIndex = selectedModule - 1
            theIndex -= dataManager.courses().count
            if (theIndex < dataManager.modules().count) {
                moduleID = dataManager.modules()[theIndex].id
            }
        }
        
        //send log
        var urlString = ""
        if(!dataManager.developerMode){
            urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
        } else{
            urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=stats-main-module&contentName=MainStatsFilteredByModule&modid=\(String(describing: moduleID))"
        }
        xAPIManager().checkMod(testUrl:urlString)
    }
    
    func view(_ view: CustomPickerView, selectedRow: Int) {
        if (selectedModule != selectedRow) {
            selectedModule = selectedRow
            if(selectedModule == 0){
                moduleButton.setTitle(localized("filter_modules"), for: UIControlState())
                getAttainmentData { }
            } else {
                moduleButton.setTitle(view.contentArray[selectedRow], for: UIControlState())
                let moduleIndex = selectedModule - (1 + dataManager.courses().count)
                if (moduleIndex >= 0 && moduleIndex < dataManager.modules().count) {
                    moduleButton.setTitle(dataManager.modules()[moduleIndex].name, for: UIControlState())
                    getAttainmentData { }
                }
            }
        }
    }
}
