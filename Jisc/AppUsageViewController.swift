//
//  AppUsageViewController.swift
//  Jisc
//
//  Created by Therapy Box on 05/09/2017.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class AppUsageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleLabel:UILabel!

    @IBOutlet weak var leftColumnTableView: UITableView!
    var leftColumnArray:Array = [localized("targets_met"),localized("targets_failed"),localized("targets_set"),localized("hours_of_activites_logged"),localized("sessions_on_app")]
    var rightColumnArray:Array = ["0","0","0","0","0"]
    
    @IBOutlet weak var targetsMet: LocalizableLabel!
    @IBOutlet weak var targetsFailed: LocalizableLabel!
    @IBOutlet weak var targetsSet: LocalizableLabel!
    @IBOutlet weak var activites: LocalizableLabel!
    @IBOutlet weak var sessions: LocalizableLabel!
    
    @IBOutlet weak var startDateField: UITextField!
    var startDatePicker = UIDatePicker()
    let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "dd/MM/yyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    let databaseDateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    
    @IBOutlet weak var endDateField: UITextField!
    var endDatePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        customiseLayout()
    
        loadData()
    }

    @IBAction func openMenu(_ sender: Any) {
        DELEGATE.menuView?.open()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppUsage", for: indexPath) as! AppUsageCell
        cell.leftLabel.text = leftColumnArray[indexPath.row]
        cell.rightLabel.text = rightColumnArray[indexPath.row]
        //cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.leftLabel.font = UIFont(name: "System", size: 12.0)
        cell.rightLabel.font = UIFont(name: "System", size: 12.0)

        return cell

    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppUsage", for: indexPath) as! AppUsageCell
        cell.leftLabel.text = leftColumnArray[indexPath.row]
        cell.rightLabel.text = rightColumnArray[indexPath.row]
        //cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.leftLabel.font = UIFont(name: "System", size: 12.0)
        cell.rightLabel.font = UIFont(name: "System", size: 12.0)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func customiseLayout(){
        startDateField.text = localized("start")
        endDateField.text = localized("end")
        titleLabel.text = localized("app_usage")
        
        startDateField.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        startDateField.layer.borderWidth = 1.5
        startDateField.layer.cornerRadius = 8
        startDateField.layer.masksToBounds = true
   
        startDatePicker.datePickerMode = UIDatePickerMode.date
        startDatePicker.maximumDate = Date()
        let startToolbar = UIToolbar()
        startToolbar.sizeToFit()
        let startDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(startDatePickerDone))
        startToolbar.setItems([startDoneButton], animated: true)
        startDateField.inputAccessoryView = startToolbar
        startDateField.inputView = startDatePicker
        
        endDateField.layer.borderColor = UIColor(red: 192.0/255.0, green: 159.0/255.0, blue: 246.0/255.0, alpha: 1.0).cgColor
        endDateField.layer.borderWidth = 1.5
        endDateField.layer.cornerRadius = 8
        endDateField.layer.masksToBounds = true
        
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
        self.view.endEditing(true)
        if(endDateField.text != localized("end")){
            loadData()
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
        self.view.endEditing(true)
        if(startDateField.text != localized("start")){
            loadData()
        }
    }
    
    func loadData(){
        print("data gets called")
        let manager = xAPIManager()
        if(startDateField.text != localized("start") && endDateField.text != localized("end")) {
            print("data gets called start and enddate")
            let databaseFormatter = DateFormatter()
            databaseFormatter.dateFormat = databaseDateFormat
            let startDate = databaseFormatter.string(from: startDatePicker.date)
            let endDate = databaseFormatter.string(from: endDatePicker.date)
        
            print("app usage start end date \(startDate) \(endDate)")
            let startDateArray = startDate.components(separatedBy: "/")
            let startDateCall = "\(startDateArray[2])-\(startDateArray[1])-\(startDateArray[0])"
            let endDateArray = endDate.components(separatedBy: "/")
            let endDateCall = "\(endDateArray[2])-\(endDateArray[1])-\(endDateArray[0])"
            print("app usage start end date \(startDateCall) \(endDateCall)")
            
            manager.getAppUsage(studentId: dataManager.currentStudent!.id, startDate: startDateCall, endDate: endDateCall)
        }
        else{
            print("data gets called without")
            manager.getAppUsage(studentId: dataManager.currentStudent!.id, startDate: "null", endDate: "null")
        }
        
        let defaults = UserDefaults.standard
        self.targetsMet.text = "\(localized("targets_met_on_time")): \(defaults.string(forKey: "AppUsage_targets_met") ?? "null")"
        self.targetsFailed.text = "\(localized("targets_not_met_on_time")): \(defaults.string(forKey: "AppUsage_targets_failed") ?? "null")"
        self.targetsSet.text = "\(localized("targets_set")): \(defaults.string(forKey: "AppUsage_targets_set") ?? "null")"
        self.activites.text = "\(localized("hours_of_activites_logged")): \(defaults.string(forKey: "AppUsage_activities") ?? "null")"
        self.sessions.text = "\(localized("sessions")): \(defaults.string(forKey: "AppUsage_sessions") ?? "null")"
    }
}
