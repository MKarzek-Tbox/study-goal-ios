//
//  RecurringTargetVC.swift
//  Jisc
//
//  Created by Therapy Box on 22/08/2017.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit
import CoreData


class RecurringTargetVC: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UIAlertViewDelegate, CustomPickerViewDelegate, UITextFieldDelegate  {
    @IBOutlet weak var topSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var myGoalTextField: UITextView! //H
    @IBOutlet weak var recurringDatePicker: UIDatePicker!//H
    @IBOutlet weak var recurringBecauseTextField: UITextView!
    
    @IBOutlet weak var moduleLabel: LocalizableLabel! //H
    @IBOutlet weak var recurringSegmentControl: UISegmentedControl! // H
    @IBOutlet weak var activityTypeButton:UIButton!
    @IBOutlet weak var chooseActivityButton:UIButton!
    @IBOutlet weak var intervalButton:UIButton!
    @IBOutlet weak var hoursPicker:UIPickerView!
    @IBOutlet weak var minutesPicker:UIPickerView!
    @IBOutlet weak var closeTimePickerButton:UIButton!
    @IBOutlet weak var timePickerBottomSpace:NSLayoutConstraint!
    @IBOutlet weak var moduleButton:UIButton! //H
    @IBOutlet weak var contentScroll:UIScrollView!
    @IBOutlet weak var scrollBottomSpace:NSLayoutConstraint!
    @IBOutlet weak var noteTextView:UITextView! //H
    @IBOutlet weak var hoursTextField:UITextField!
    @IBOutlet weak var minutesTextField:UITextField!
    @IBOutlet weak var toolbar:UIView!
    var selectedHours:Int = 0
    var selectedMinutes:Int = 0
    var timeSpan:kTargetTimeSpan = .Weekly
    var goal:String = targetGoalPlaceholder
    var because:String = targetReasonPlaceholder
    var selectedActivityType:Int = 0
    var selectedActivity:Int = 0
    var selectedTimeSpan:Int = 0
    var selectedModule:Int = 0
    var theTarget:Target?
    @IBOutlet weak var titleLabel:UILabel! //H
    var isEditingTarget:Bool = false
    @IBOutlet weak var addModuleView:UIView!
    @IBOutlet weak var addModuleTextField:UITextField!
    
    var initialSelectedActivityType = 0
    var initialSelectedActivity = 0
    var initialTime:Int = 0
    var initialSpan:kTargetTimeSpan = .Daily
    var initialSelectedModule:Int = 0
    var initialReason:String = ""
    
    var activityTypeSelectorView:CustomPickerView = CustomPickerView()
    var activitySelectorView:CustomPickerView = CustomPickerView()
    var intervalSelectorView:CustomPickerView = CustomPickerView()
    var moduleSelectorView:CustomPickerView = CustomPickerView()
    
    var isInEditingMode:Bool = false
    
    init(target:Target) {
        theTarget = target
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        super.init(nibName: "RecurringTargetVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func cameFromEditing(){
        isInEditingMode = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //		if iPad {
        //			hoursTextField.font = UIFont(name: "MyriadPro-Light", size: 44.0)
        //			minutesTextField.font = UIFont(name: "MyriadPro-Light", size: 44.0)
        //		} else {
        //			hoursTextField.font = UIFont(name: "MyriadPro-Light", size: 52.0)
        //			minutesTextField.font = UIFont(name: "MyriadPro-Light", size: 52.0)
        //		}
        
        if iPad {
            recurringSegmentControl.isHidden = true
        }
        
        
        if (theTarget != nil) {
            isEditingTarget = true
            selectedHours = Int(theTarget!.totalTime) / 60
            selectedMinutes = Int(theTarget!.totalTime) % 60
            if let tempTimeSpan = kTargetTimeSpan(rawValue: theTarget!.timeSpan) {
                timeSpan = tempTimeSpan
            }
            selectedTimeSpan = timeSpans.index(of: timeSpan)!
            because = theTarget!.because
            selectedActivityType = dataManager.indexOfActivityType(theTarget!.activityType)!
            selectedActivity = dataManager.indexOfActivityWithName(theTarget!.activity.englishName, type: theTarget!.activityType)!
            if (theTarget!.module != nil) {
                selectedModule = dataManager.indexOfModuleWithID(theTarget!.module!.id)!
                selectedModule += 1
            }
            titleLabel.text = localized("edit_target")
        }
//        hoursPicker.selectRow(selectedHours, inComponent: 0, animated: false)
//        minutesPicker.selectRow(selectedMinutes, inComponent: 0, animated: false)
        if (because.isEmpty) {
            because = targetReasonPlaceholder
        }
        noteTextView.text = because
        if (because == targetReasonPlaceholder) {
            because = ""
            noteTextView.textColor = UIColor.lightGray
        }
        if (goal.isEmpty) {
            goal = targetGoalPlaceholder
        }
        myGoalTextField.text = goal
        if (goal == targetGoalPlaceholder) {
            goal = ""
            myGoalTextField.textColor = UIColor.lightGray
        }
        
        
////        activityTypeButton.setTitle(dataManager.activityTypeNameAtIndex(selectedActivityType), for: UIControlState())
//        activityTypeButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        activityTypeButton.titleLabel?.numberOfLines = 2
        let activityType = dataManager.activityTypes()[selectedActivityType]
//        chooseActivityButton.setTitle(dataManager.activityAtIndex(selectedActivity, type: activityType)?.name, for: UIControlState())
//        chooseActivityButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        chooseActivityButton.titleLabel?.numberOfLines = 2
        timeSpan = timeSpans[selectedTimeSpan]
        var string = ""
//        switch (timeSpan) {
//        case .Daily:
//            maxTargetHours = 8
//            string = localized("day").capitalized
//        case .Weekly:
//            maxTargetHours = 40
//            string = localized("week").capitalized
//        case .Monthly:
//            maxTargetHours = 99
//            string = localized("month").capitalized
//        }
//        intervalButton.setTitle(string, for: UIControlState())
//        intervalButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        intervalButton.titleLabel?.numberOfLines = 2
        if (selectedModule > 0) {
            moduleButton.setTitle(dataManager.moduleNameAtIndex(selectedModule - 1), for: UIControlState())
        } else {
            moduleButton.setTitle(localized("any_module"), for: UIControlState())
        }
        moduleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        moduleButton.titleLabel?.numberOfLines = 2
        //var title = "\(selectedHours)"
//        if (selectedHours < 10) {
//            title = "0\(selectedHours)"
//        }
//        hoursTextField.text = title
//        title = "\(selectedMinutes)"
//        if (selectedMinutes < 10) {
//            title = "0\(selectedMinutes)"
//        }
//        minutesTextField.text = title
        
        initialSelectedActivityType = selectedActivityType
        initialSelectedActivity = selectedActivity
        initialTime = (selectedHours * 60) + selectedMinutes
        initialSpan = timeSpan
        initialSelectedModule = selectedModule
        initialReason = because
        
        if (isInEditingMode){
            //Below two lines of code to read from the userDefaults
            let defaults = UserDefaults.standard
            let editedReason = defaults.object(forKey: "EditedReason") as! String
            let editedDescribe = defaults.object(forKey: "EditedDescribe") as! String
            // let editedDateObject = defaults.object(forKey: "EditedDate") as! Date
            let editedModule = defaults.object(forKey: "EditedModule") as! String
            
            //self.recurringDatePicker.date = editedDateObject
            if !editedReason.isEmpty{
                myGoalTextField?.textColor = UIColor.black
                myGoalTextField?.text = editedDescribe
            }
            if !editedDescribe.isEmpty{
                noteTextView?.textColor = UIColor.black
                noteTextView?.text = editedReason
            }
            if !editedModule.isEmpty{
               moduleButton.setTitle(editedModule, for: UIControlState())
            }
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.init(identifier: "en_GB")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //moduleLabel.text = "Module"
        // recurringDatePicker.minimumDate = Date()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    @IBAction func goBack(_ sender:UIButton) {
        if (changesWereMade()) {
            UIAlertView(title: localized("confirmation"), message: localized("would_you_like_to_save_the_changes_you_made"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
        } else {
             _ = navigationController?.popViewController(animated: true)
            _ = navigationController?.popViewController(animated: true)

            
            //let vc = SingleTargetVC()
        //    navigationController?.present(vc, animated: false, completion: nil)
        }
    }
    /*
    @IBAction func topSegmentControlAction(_ sender: Any) {
        if (topSegmentControl.selectedSegmentIndex == 1){
            Bundle.main.loadNibNamed("NewTargetVC", owner: self, options: nil)
        } else {
            Bundle.main.loadNibNamed("RecurringTargetVC", owner: self, options: nil)
        }
        
    }
 */
    @IBAction func recurringSegmentControlAction(_ sender: Any) {
        if (recurringSegmentControl.selectedSegmentIndex == 0){
            let vc = RecurringTargetVC()
            navigationController?.pushViewController(vc, animated: false)
           //Bundle.main.loadNibNamed("RecurringTargetVC", owner: self, options: nil)
            
        } else {
           let vc = NewTargetVC()
            navigationController?.pushViewController(vc, animated: false)
            //Bundle.main.loadNibNamed("NewTargetVC", owner: self, options: nil)
        }
    }
    
    func addModule() {
        addModuleTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.addModuleView.alpha = 1.0
        }
    }
    
    @IBAction func closeAddModule(_ sender:UIButton?) {
        addModuleTextField.text = ""
        addModuleTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.addModuleView.alpha = 0.0
        }
    }
    
    func changesWereMade() -> Bool {
        var changesWereMade:Bool = false
        if (initialSelectedModule != selectedModule) {
            changesWereMade = true
        } else if (initialSelectedActivityType != selectedActivityType) {
            changesWereMade = true
        } else if (initialSelectedActivity != selectedActivity) {
            changesWereMade = true
        } else if (initialTime != ((selectedHours * 60) + selectedMinutes)) {
            changesWereMade = true
        } else if (initialSpan != timeSpan) {
            changesWereMade = true
        } else if (initialReason != noteTextView.text) {
            changesWereMade = true
        }
        return changesWereMade
    }
    
    @IBAction func settings(_ sender:UIButton) {
        let vc = SettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func closeActiveTextEntries() {
        closeTextView(UIBarButtonItem())
    }
    
    func checkForTargetConflicts() -> Bool {
        var conflictExists:Bool = false
        let targets = dataManager.targets()
        for (_, item) in targets.enumerated() {
            if (theTarget != nil) {
                if (item.id == theTarget!.id) {
                    continue
                }
            }
            let itemTimeSpan = kTargetTimeSpan(rawValue: item.timeSpan)
            let activityType = dataManager.activityTypes()[selectedActivityType]
            let activity = dataManager.activityAtIndex(selectedActivity, type: activityType)!
            
            var itemSelectedModule:Int = 0
            if (item.module != nil) {
                itemSelectedModule = dataManager.indexOfModuleWithID(item.module!.id)!
                itemSelectedModule += 1
            }
            
            if ((itemTimeSpan == timeSpan) && (item.activity.englishName == activity.englishName) && (itemSelectedModule == selectedModule)) {
                conflictExists = true
                break
            }
        }
        return conflictExists
    }
    
    @IBAction func saveTarget(_ sender:UIButton) {
        if (selectedMinutes == 0 && selectedHours == 0) {
            UIAlertView(title: localized("error"), message: localized("please_enter_a_time_target"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
        } else if (checkForTargetConflicts()) {
            UIAlertView(title: localized("error"), message: localized("you_already_have_a_target_with_the_same_parameters_set"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
        } else {
            var target = Target.insertInManagedObjectContext(managedContext, dictionary: NSDictionary())
            if (theTarget != nil) {
                dataManager.deleteObject(target)
                target = theTarget!
            }
            target.activityType = dataManager.activityTypes()[selectedActivityType]
            target.activity = dataManager.activityAtIndex(selectedActivity, type: target.activityType)!
            target.totalTime = ((selectedHours * 60) + selectedMinutes) as NSNumber
            target.timeSpan = timeSpan.rawValue
            if (selectedModule > 0 && selectedModule - 1 < dataManager.modules().count) {
                target.module = dataManager.modules()[selectedModule - 1]
                let urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-add&contentName=newTarget&modid=\(String(describing: target.module))"
                xAPIManager().checkMod(testUrl:urlString)
            } else {
                
                target.module = nil
                let urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-add&contentName=newTarget)"
                xAPIManager().checkMod(testUrl:urlString)
            }
            target.because = because
            if (theTarget != nil) {
                dataManager.editTarget(theTarget!, completion: { (success, failureReason) -> Void in
                    if (success) {
                        for (_, item) in target.stretchTargets.enumerated() {
                            dataManager.deleteObject(item as! NSManagedObject)
                        }
                        dataManager.deleteObject(target)
                        AlertView.showAlert(true, message: localized("saved_successfully")) { (done) -> Void in
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        AlertView.showAlert(false, message: failureReason) { (done) -> Void in
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            } else {
                dataManager.addTarget(target, completion: { (success, failureReason) -> Void in
                    if (success) {
                        dataManager.deleteObject(target)
                        AlertView.showAlert(true, message: localized("saved_successfully")) { (done) -> Void in
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        AlertView.showAlert(false, message: failureReason) { (done) -> Void in
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func recurringSaveAction(_ sender: Any) {
        if demo(){
            let alert = UIAlertController(title: "", message: localized("demo_mode_save_target"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)

        } else {
            dateFormatter.dateFormat = "y-MM-dd"
            let somedateString = dateFormatter.string(from: self.recurringDatePicker.date)
            let urlString = "https://stuapp.analytics.alpha.jisc.ac.uk/fn_add_todo_task?"
            var module = ""
            if (selectedModule - 1 < 0){
                module = "No Module"
            } else {
                module = dataManager.moduleNameAtIndex(selectedModule - 1)!
            }
            if (myGoalTextField.text.isEmpty){
                //Make sure to localize the following message
                
                AlertView.showAlert(false, message: localized("Make sure to fill in My Goal section")) { (done) -> Void in
                    //self.dismiss(animated: true, completion: nil)
                }
            }
            var myBody = ""
            if social(){
                 myBody = "is_social=true&module=\(module)&description=\(myGoalTextField.text!)&end_date=\(somedateString)&language=en&reason=\(noteTextView.text!)"
            } else {
                 myBody = "student_id=\(dataManager.currentStudent!.id)&module=\(module)&description=\(myGoalTextField.text!)&end_date=\(somedateString)&language=en&reason=\(noteTextView.text!)"
            }
            
            if (noteTextView.text! == "Add a reason to keep this target"){
                 myBody = "student_id=\(dataManager.currentStudent!.id)&module=\(module)&description=\(myGoalTextField.text!)&end_date=\(somedateString)&language=en"
                if social(){
                     myBody = "is_social=true&module=\(module)&description=\(myGoalTextField.text!)&end_date=\(somedateString)&language=en"
                } else {
                     myBody = "student_id=\(dataManager.currentStudent!.id)&module=\(module)&description=\(myGoalTextField.text!)&end_date=\(somedateString)&language=en"
                }

            }
            
            let somethingWentWrong = xAPIManager().postRequest(testUrl: urlString, body: myBody)
            
            if (somethingWentWrong){
                AlertView.showAlert(false, message: localized("something_went_wrong")) { (done) -> Void in
                   // _ = self.navigationController?.popViewController(animated: true)
                    let vc = SingleTargetVC()
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            } else if (!somethingWentWrong && !myGoalTextField.text.isEmpty){
                AlertView.showAlert(true, message: localized("saved_successfully")) { (done) -> Void in
                 //   _ = self.navigationController?.popViewController(animated: true)
                    let vc = SingleTargetVC()
                    self.navigationController?.pushViewController(vc, animated: false)

                }
            }

        }
        
        
    }
    
    @IBAction func datePickerAction(_ sender: Any) {
        if (isInEditingMode){
            let defaults = UserDefaults.standard
             if demo(){
             } else {
                let editedTutor = defaults.object(forKey: "EditedTutor") as! String //as! Date
                if (editedTutor == "yes"){
                    let editedDateObject = defaults.object(forKey: "EditedDate") //as! Date
                    if (editedDateObject != nil){
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let TestDateTime = formatter.date(from:editedDateObject as! String)
                        
                        recurringDatePicker.date = TestDateTime!
                        
                         UIAlertView(title: localized("error"), message: localized("tutor_target"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
                        
                    }

                } else {
            let editedDateObject = defaults.object(forKey: "EditedDate") //as! Date
            if (editedDateObject != nil){
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let TestDateTime = formatter.string(from: recurringDatePicker.date)
              //  recurringDatePicker.date = TestDateTime!
                defaults.set(TestDateTime, forKey: "EditedDate")
                
            }
                }
            }
        } else {
            recurringDatePicker.minimumDate = Date()
        }
//        let defaults = UserDefaults.standard
//        let editedDateObject = defaults.object(forKey: "EditedDate") as! Date
//        recurringDatePicker.date = editedDateObject
        
    }
    //MARK: UIAlertView Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            //_ = navigationController?.popViewController(animated: false)
            let vc = SingleTargetVC()
            navigationController?.pushViewController(vc, animated: true)

        } else {
            saveTarget(UIButton())
        }
    }
    
    //MARK: Show Selector Views
    
    @IBAction func showActivityTypeSelector(_ sender:UIButton) {
        if (!isEditingTarget) {
            closeActiveTextEntries()
            var array:[String] = [String]()
            for (_, item) in dataManager.activityTypes().enumerated() {
                array.append(item.name)
            }
            activityTypeSelectorView = CustomPickerView.create(localized("choose_activity_type"), delegate: self, contentArray: array, selectedItem: selectedActivityType)
            view.addSubview(activityTypeSelectorView)
        }
    }
    
    @IBAction func showActivitySelector(_ sender:UIButton) {
        var array:[String] = [String]()
        for (index, _) in dataManager.activityTypes()[selectedActivityType].activities.enumerated() {
            let activityType = dataManager.activityTypes()[selectedActivityType]
            let name = dataManager.activityAtIndex(index, type: activityType)?.name
            if (name != nil) {
                array.append(name!)
            }
        }
        activitySelectorView = CustomPickerView.create(localized("choose_activity"), delegate: self, contentArray: array, selectedItem: selectedActivity)
        view.addSubview(activitySelectorView)
    }
    
    @IBAction func showIntervalSelector(_ sender:UIButton) {
        closeActiveTextEntries()
        var array:[String] = [String]()
        array.append(localized("day").capitalized)
        array.append(localized("week").capitalized)
        array.append(localized("month").capitalized)
        intervalSelectorView = CustomPickerView.create(localized("choose_interval"), delegate: self, contentArray: array, selectedItem: selectedTimeSpan)
        view.addSubview(intervalSelectorView)
    }
    
    @IBAction func showModuleSelector(_ sender:UIButton) {
        if currentUserType() == .social {
            var array:[String] = [String]()
            array.append(localized("any_module"))
            for (_, item) in dataManager.modules().enumerated() {
                array.append(item.name)
            }
            moduleSelectorView = CustomPickerView.create(localized("choose_module"), delegate: self, contentArray: array, selectedItem: selectedModule)
            view.addSubview(moduleSelectorView)
        } else {
            if (!dataManager.currentStudent!.institution.isLearningAnalytics.boolValue) {
                return
            }
            closeActiveTextEntries()
            var array:[String] = [String]()
            array.append(localized("any_module"))
            for (_, item) in dataManager.modules().enumerated() {
                array.append(item.name)
            }
            moduleSelectorView = CustomPickerView.create(localized("choose_module"), delegate: self, contentArray: array, selectedItem: selectedModule)
            view.addSubview(moduleSelectorView)
        }
    }
    
    //MARK: CustomPickerView Delegate
    
    func view(_ view: CustomPickerView, selectedRow: Int) {
        switch (view) {
        case activityTypeSelectorView:
            selectedActivityType = selectedRow
            activityTypeButton.setTitle(dataManager.activityTypeNameAtIndex(selectedActivityType), for: UIControlState())
            selectedActivity = 0
            chooseActivityButton.setTitle(dataManager.activityAtIndex(selectedActivity, type: dataManager.activityTypes()[selectedActivityType])?.name, for: UIControlState())
            break
        case activitySelectorView:
            selectedActivity = selectedRow
            let activityType = dataManager.activityTypes()[selectedActivityType]
            chooseActivityButton.setTitle(dataManager.activityAtIndex(selectedActivity, type: activityType)?.name, for: UIControlState())
            break
        case intervalSelectorView:
            selectedTimeSpan = selectedRow
            timeSpan = timeSpans[selectedTimeSpan]
            switch timeSpan {
            case .Daily:
                maxTargetHours = 8
                break
            case .Weekly:
                maxTargetHours = 40
                break
            case .Monthly:
                maxTargetHours = 99
                break
            }
            let string = view.contentArray[selectedRow]
            intervalButton.setTitle(string, for: UIControlState())
            if (selectedHours >= maxTargetHours && timeSpan == .Daily) {
                selectedHours = maxTargetHours
                if maxTargetHours < 10 {
                    hoursTextField.text = "0\(maxTargetHours)"
                } else {
                    hoursTextField.text = "\(maxTargetHours)"
                }
                hoursPicker.selectRow(maxTargetHours, inComponent: 0, animated: true)
                selectedMinutes = 0
                minutesPicker.selectRow(0, inComponent: 0, animated: true)
                minutesTextField.text = "00"
            }
            break
        case moduleSelectorView:
            if currentUserType() == .social {
                if selectedRow == dataManager.modules().count {
                    addModule()
                } else {
                    selectedModule = selectedRow
                    moduleButton.setTitle(view.contentArray[selectedRow], for: UIControlState())
                }
            } else {
                selectedModule = selectedRow
                moduleButton.setTitle(view.contentArray[selectedRow], for: UIControlState())
            }
            break
        default:break
        }
    }
    
    //MARK: Time Picker
    
    @IBAction func changeTime(_ sender:UIButton) {
        closeActiveTextEntries()
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.closeTimePickerButton.alpha = 1.0
            self.timePickerBottomSpace.constant = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func closeTimePicker(_ sender:UIButton) {
        animateTimePickerClosing()
    }
    
    @IBAction func closeTimePickerFromToolbar(_ sender:UIBarButtonItem) {
        animateTimePickerClosing()
    }
    
    func animateTimePickerClosing() {
        hoursPicker.selectRow(selectedHours, inComponent: 0, animated: false)
        minutesPicker.selectRow(selectedMinutes, inComponent: 0, animated: false)
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.closeTimePickerButton.alpha = 0.0
            self.timePickerBottomSpace.constant = -260.0
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: UITextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if (textView == noteTextView && textView.text == targetReasonPlaceholder) {
            textView.text = ""
            noteTextView.textColor = UIColor.black
        } else if(textView == myGoalTextField && textView.text == targetGoalPlaceholder){
            textView.text = ""
            myGoalTextField.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.scrollBottomSpace.constant = keyboardHeight - 5.0
            self.contentScroll.contentOffset = CGPoint(x: 0.0, y: self.contentScroll.contentSize.height - self.scrollBottomSpace.constant)
            self.view.layoutIfNeeded()
        })
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.scrollBottomSpace.constant = 0.0
            self.view.layoutIfNeeded()
        })
        
        if (textView == noteTextView && textView.text.isEmpty) {
            textView.text = targetReasonPlaceholder
            noteTextView.textColor = UIColor.lightGray
        } else if(textView == myGoalTextField && textView.text.isEmpty){
            textView.text = targetGoalPlaceholder
            myGoalTextField.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func closeTextView(_ sender:UIBarButtonItem) {
        if(because != noteTextView.text){
            noteTextView.resignFirstResponder()
            because = noteTextView.text
            if (because == targetReasonPlaceholder) {
                because = ""
            }
        } else if (goal != myGoalTextField.text){
            myGoalTextField.resignFirstResponder()
            goal = myGoalTextField.text
            if(goal == targetGoalPlaceholder){
                goal = ""
            }
        }
        
    }
    
    //MARK: UIPickerView Datasource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var nrRows = 0
        switch (pickerView) {
        case hoursPicker:
            nrRows = maxTargetHours
        case minutesPicker:
            nrRows = 60
        default:break
        }
        return nrRows
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    //MARK: UIPickerView Delegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var viewForRow:UIView
        var title = "\(row)"
        if (row < 10) {
            title = "0\(row)"
        }
        
        if (view != nil) {
            viewForRow = view!
            
            let label = viewForRow.viewWithTag(1) as? UILabel
            if (label != nil) {
                label!.text = title
            }
        } else {
            viewForRow = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 50.0))
            viewForRow.backgroundColor = UIColor.clear
            
            let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 50.0))
            label.backgroundColor = UIColor.clear
            label.text = title
            label.textAlignment = NSTextAlignment.center
            label.textColor = lilacColor
            label.font = myriadProLight(44)
            label.tag = 1
            viewForRow.addSubview(label)
        }
        return viewForRow
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var title = "\(row)"
        if (row < 10) {
            title = "0\(row)"
        }
        switch (pickerView) {
        case hoursPicker:
            selectedHours = row
            hoursTextField.text = title
            if (selectedHours >= maxTargetHours && timeSpan == .Daily) {
                selectedHours = maxTargetHours
                if maxTargetHours < 10 {
                    hoursTextField.text = "0\(maxTargetHours)"
                } else {
                    hoursTextField.text = "\(maxTargetHours)"
                }
                hoursPicker.selectRow(maxTargetHours, inComponent: 0, animated: true)
                selectedMinutes = 0
                minutesPicker.selectRow(0, inComponent: 0, animated: true)
                minutesTextField.text = "00"
            }
        case minutesPicker:
            if (selectedHours >= maxTargetHours && timeSpan == .Daily) {
                selectedMinutes = 0
                minutesPicker.selectRow(0, inComponent: 0, animated: true)
                minutesTextField.text = "00"
            } else {
                selectedMinutes = row
                minutesTextField.text = title
            }
        default:break
        }
    }
    
    //MARK: - UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text {
            DownloadManager().addSocialModule(studentId: dataManager.currentStudent!.id, module: text, alertAboutInternet: true, completion: { (success, result, results, error) in
                DownloadManager().getSocialModules(studentId: dataManager.currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) in
                    if (success) {
                        if let modules = results as? [String] {
                            for (_, item) in modules.enumerated() {
                                let dictionary = NSMutableDictionary()
                                dictionary[item] = item
                                let object = Module.insertInManagedObjectContext(managedContext, dictionary: dictionary)
                                dataManager.currentStudent!.addModule(object)
                            }
                        }
                    }
                    self.selectedModule = 0
                    self.moduleButton.setTitle(dataManager.moduleNameAtIndex(self.selectedModule), for: UIControlState())
                })
            })
        }
        closeAddModule(nil)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        toolbar.alpha = 0.0
        var shouldBegin = true
        if selectedHours == maxTargetHours && textField == minutesTextField {
            shouldBegin = false
            AlertView.showAlert(false, message: localizedWith1Parameter("time_spent_max", parameter: "\(maxTargetHours)"), completion: nil)
        } else {
            textField.text = ""
        }
        return shouldBegin
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.scrollBottomSpace.constant = keyboardHeight - 44.0
            self.view.layoutIfNeeded()
        })
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if selectedHours == maxTargetHours && textField == hoursTextField {
            minutesTextField.text = "00"
            selectedMinutes = 0
        }
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.scrollBottomSpace.constant = 0.0
            self.view.layoutIfNeeded()
        })
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        toolbar.alpha = 1.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldChange = false
        if string.isEmpty || textField == addModuleTextField {
            shouldChange = true
        } else {
            if "0123456789".contains(string) {
                shouldChange = true
                switch textField {
                case hoursTextField:
                    switch timeSpan {
                    case .Daily:
                        if string == "9" {
                            shouldChange = false
                        } else {
                            textField.text = "0\(string)"
                            selectedHours = (string as NSString).integerValue
                            textField.resignFirstResponder()
                        }
                        break
                    case .Weekly, .Monthly:
                        if let text = textField.text {
                            if ((text as NSString).replacingCharacters(in: range, with: string) as NSString).integerValue > maxTargetHours {
                                shouldChange = false
                            } else {
                                shouldChange = false
                                textField.text = (text as NSString).replacingCharacters(in: range, with: string)
                                selectedHours = ((text as NSString).replacingCharacters(in: range, with: string) as NSString).integerValue
                                if ((text as NSString).replacingCharacters(in: range, with: string) as NSString).integerValue > 9 {
                                    textField.resignFirstResponder()
                                }
                            }
                        }
                        break
                    }
                    break
                case minutesTextField:
                    if let text = textField.text {
                        if text.isEmpty {
                            if !"012345".contains(string) {
                                shouldChange = false
                            }
                        } else {
                            if let text = textField.text {
                                textField.text = (text as NSString).replacingCharacters(in: range, with: string)
                                selectedMinutes = ((text as NSString).replacingCharacters(in: range, with: string) as NSString).integerValue
                                textField.resignFirstResponder()
                            }
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
        return shouldChange
    }
}
