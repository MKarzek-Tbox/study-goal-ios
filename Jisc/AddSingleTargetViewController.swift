//
//  AddSingleTargetViewController.swift
//  Jisc
//
//  Created by Therapy Box on 22/08/2017.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit
import CoreData


class AddSingleTargetViewController: BaseViewController, UITextViewDelegate, UIAlertViewDelegate, CustomPickerViewDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var moduleLabel: LocalizableLabel!
    @IBOutlet weak var recurringSegmentControl: UISegmentedControl!
    @IBOutlet weak var closeTimePickerButton:UIButton!
    @IBOutlet weak var moduleButton:UIButton!
    @IBOutlet weak var contentScroll:UIScrollView!
    @IBOutlet weak var scrollBottomSpace:NSLayoutConstraint!
    @IBOutlet weak var noteTextView:UITextView!
    @IBOutlet weak var myGoalTextField: UITextView!
    
    @IBOutlet weak var reminderSwitch:UISwitch!
    @IBOutlet weak var reminderView:UIView!
    @IBOutlet weak var reminderDateField:UITextField!
    @IBOutlet weak var endDateField:UITextField!
    
    var goal:String = targetGoalPlaceholder
    var because:String = targetReasonPlaceholder
    
    var selectedModule:Int = 0
    var theTarget:Target?
    @IBOutlet weak var titleLabel:UILabel!
    var isEditingTarget:Bool = false
    @IBOutlet weak var addModuleView:UIView!
    @IBOutlet weak var addModuleTextField:UITextField!
    
    var initialSelectedModule:Int = 0
    var initialReason = ""
    var initialGoal = ""
    
    var reminderDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE d MMM yyyy - hh:mm", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    let gbDateFormatShort = DateFormatter.dateFormat(fromTemplate: "EEEE d MMM yyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
    
    var moduleSelectorView:CustomPickerView = CustomPickerView()
    
    var isInEditingMode:Bool = false
    
    init(target:Target) {
        theTarget = target
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        super.init(nibName: "AddSingleTargetViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func cameFromEditing(){
        isInEditingMode = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDatePickers()
        
        xAPIManager().checkMod(testUrl:"https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=viewed&contentID=targets-main&contentName=singleTargetsPage")
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddSingleTargetViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddSingleTargetViewController
            .keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        recurringSegmentControl.setTitle(localized("single"), forSegmentAt: 0)
        recurringSegmentControl.setTitle(localized("recurring"), forSegmentAt: 1)
        
        if (theTarget != nil) {
            print("editing mode for single targets entered")
            isEditingTarget = true
            isInEditingMode = true
            
            because = theTarget!.because
            
            if (theTarget!.module != nil) {
                selectedModule = dataManager.indexOfModuleWithID(theTarget!.module!.id)!
                selectedModule += 1
            }
            titleLabel.text = localized("edit_target")
            recurringSegmentControl.isHidden = true
        }
        
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
        
        if (selectedModule > 0) {
            moduleButton.setTitle(dataManager.moduleNameAtIndex(selectedModule - 1), for: UIControlState())
        } else {
            moduleButton.setTitle(localized("any_module"), for: UIControlState())
        }
        moduleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        moduleButton.titleLabel?.numberOfLines = 2
        
        initialSelectedModule = selectedModule
        initialReason = because
        initialGoal = goal
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let initialDate = Date()
        
        self.endDatePicker.setDate(initialDate, animated: true)
        dateFormatter.dateFormat = gbDateFormatShort
        endDateField.text = dateFormatter.string(for: endDatePicker.date)
        
        self.reminderDatePicker.setDate(Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: initialDate)!, animated: true)
        dateFormatter.dateFormat = gbDateFormat
        reminderDateField.text = dateFormatter.string(for: reminderDatePicker.date)
        
        if (isInEditingMode){
            print("isInEditingMode trying to add information")
            let defaults = UserDefaults.standard
            let editedReason = defaults.object(forKey: "EditedReason") as! String
            let editedDescribe = defaults.object(forKey: "EditedDescribe") as! String
            let editedDateObject = defaults.object(forKey: "EditedDate") as! String
            let editedModule = defaults.object(forKey: "EditedModule") as! String
            let editedReminderDate = defaults.object(forKey: "EditedReminderDate") as! String
            
            myGoalTextField?.textColor = UIColor.black
            myGoalTextField?.text = editedDescribe
            
            noteTextView?.textColor = UIColor.black
            noteTextView?.text = editedReason
            
            if (editedModule.uppercased() == "NO MODULE" || editedModule == "no_module" || editedModule.isEmpty){
                moduleButton.setTitle("Any Module", for: UIControlState())
            } else {
                moduleButton.setTitle(editedModule, for: UIControlState())
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.init(identifier: "en_GB")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            var date = dateFormatter.date(from: editedDateObject)
            self.endDatePicker.setDate(date!, animated: true)
            dateFormatter.dateFormat = gbDateFormatShort
            endDateField.text = dateFormatter.string(for: endDatePicker.date)
            
            date = dateFormatter.date(from: editedReminderDate)
            self.reminderDatePicker.setDate(date!, animated: true)
            dateFormatter.dateFormat = gbDateFormat
            reminderDateField.text = dateFormatter.string(for: reminderDatePicker.date)
            reminderDatePicker.maximumDate = date
            reminderDatePicker.minimumDate = date
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            let vc = SingleTargetVC()
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func recurringSegmentControlAction(_ sender: Any) {
        if (recurringSegmentControl.selectedSegmentIndex == 1){
            let vc = AddRecurringTargetViewController()
            navigationController?.pushViewController(vc, animated: false)
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
        } else if (initialReason != noteTextView.text) {
            changesWereMade = true
        } else if (initialGoal != myGoalTextField.text) {
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

            var itemSelectedModule:Int = 0
            if (item.module != nil) {
                itemSelectedModule = dataManager.indexOfModuleWithID(item.module!.id)!
                itemSelectedModule += 1
            }
        }
        return conflictExists
    }
    
    @IBAction func recurringSaveAction(_ sender: Any) {
        if demo(){
            let alert = UIAlertController(title: "", message: localized("demo_mode_add_target"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
            
        } else {
            dateFormatter.dateFormat = "y-MM-dd"
            let somedateString = dateFormatter.string(from: self.endDatePicker.date)
            let urlString = "https://stuapp.analytics.alpha.jisc.ac.uk/fn_add_todo_task?"
            let urlStringEdit = "https://stuapp.analytics.alpha.jisc.ac.uk/fn_edit_todo_task?"
            var module = ""
            if (selectedModule - 1 < 0){
                module = "No Module"
            } else {
                module = dataManager.moduleNameAtIndex(selectedModule - 1)!
            }
            if (myGoalTextField.text.isEmpty || myGoalTextField.text == targetGoalPlaceholder){
                //Make sure to localize the following message
                
                AlertView.showAlert(false, message: localized("Make sure to fill in My Goal section")) { (done) -> Void in
                    
                }
                return
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
            
            if(!isInEditingMode){
                let somethingWentWrong = xAPIManager().postRequest(testUrl: urlString, body: myBody)
                
                if (somethingWentWrong){
                    AlertView.showAlert(false, message: localized("something_went_wrong")) { (done) -> Void in
                        let vc = SingleTargetVC()
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                } else if (!somethingWentWrong && !myGoalTextField.text.isEmpty){
                    AlertView.showAlert(true, message: localized("saved_successfully")) { (done) -> Void in
                        let vc = SingleTargetVC()
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            } else {
                print("saving edited single target")
                let defaults = UserDefaults.standard
                let recordId = defaults.object(forKey: "EditedID") as! Int
                myBody = myBody + "&record_id=\(recordId)"
                print(myBody)
                
                let somethingWentWrong = xAPIManager().postRequest(testUrl: urlStringEdit, body: myBody)
                
                if (somethingWentWrong){
                    AlertView.showAlert(false, message: localized("something_went_wrong")) { (done) -> Void in
                        let vc = SingleTargetVC()
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                } else if (!somethingWentWrong && !myGoalTextField.text.isEmpty){
                    AlertView.showAlert(true, message: localized("saved_successfully")) { (done) -> Void in
                        let vc = SingleTargetVC()
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
    }
    
    func keyboardWillHide(notification: NSNotification) {
    }
    
    //MARK: UIAlertView Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 0) {
            let vc = SingleTargetVC()
            navigationController?.pushViewController(vc, animated: true)
            
        } else {
            recurringSaveAction(UIButton())
        }
    }
    
    //MARK: Show Selector Views
    
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
        if(!iPad){
            if(textView == noteTextView){
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.scrollBottomSpace.constant = keyboardHeight - 5.0
                    self.contentScroll.contentOffset = CGPoint(x: 0.0, y: self.contentScroll.contentSize.height - self.scrollBottomSpace.constant)
                    self.view.layoutIfNeeded()
                })
            } else if (textView == myGoalTextField){
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.scrollBottomSpace.constant = keyboardHeight - 5.0
                    self.contentScroll.contentOffset = CGPoint(x: 0.0, y: 0.0)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(!iPad){
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.scrollBottomSpace.constant = 0.0
                self.view.layoutIfNeeded()
            })
        }
        
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
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.scrollBottomSpace.constant = keyboardHeight //- 44.0
            self.view.layoutIfNeeded()
        })
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(!iPad){
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.scrollBottomSpace.constant = 0.0
                self.view.layoutIfNeeded()
            })
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            if(!iPad){
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.scrollBottomSpace.constant = 0.0
                    self.contentScroll.contentOffset = CGPoint(x: 0.0, y: 0.0)
                    self.view.layoutIfNeeded()
                })
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func setupDatePickers(){
        reminderDateField.borderStyle = UITextBorderStyle.none
        reminderDatePicker.datePickerMode = UIDatePickerMode.dateAndTime
        reminderDatePicker.minimumDate = Date()
        reminderDatePicker.minuteInterval = 15
        let reminderToolbar = UIToolbar()
        reminderToolbar.sizeToFit()
        let reminderDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(reminderPickerDone))
        reminderToolbar.setItems([reminderDoneButton], animated: true)
        reminderDateField.inputAccessoryView = reminderToolbar
        reminderDateField.inputView = reminderDatePicker
        
        endDateField.borderStyle = UITextBorderStyle.none
        endDatePicker.datePickerMode = UIDatePickerMode.date
        endDatePicker.minimumDate = Date()
        let endDateToolbar = UIToolbar()
        endDateToolbar.sizeToFit()
        let endDateDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endDatePickerDone))
        endDateToolbar.setItems([endDateDoneButton], animated: true)
        endDateField.inputAccessoryView = endDateToolbar
        endDateField.inputView = endDatePicker
    }
    
    func reminderPickerDone(){
        if (isInEditingMode){
            let defaults = UserDefaults.standard
            if demo(){
            } else {
                let editedTutor = defaults.object(forKey: "EditedTutor") as! String
                if (editedTutor == "yes"){
                    let editedDateObject = defaults.object(forKey: "EditedReminderDate")
                    if (editedDateObject != nil){
                        let formatter = DateFormatter()
                        formatter.dateFormat = gbDateFormat
                        let dateTime = formatter.date(from:editedDateObject as! String)
                        reminderDateField.text = formatter.string(from: dateTime!)
                        
                        UIAlertView(title: localized("error"), message: localized("tutor_target"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
                    }
                } else {
                    let editedDateObject = defaults.object(forKey: "EditedReminderDate") //as! Date
                    if (editedDateObject != nil){
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let TestDateTime = formatter.string(from: reminderDatePicker.date)
                        defaults.set(TestDateTime, forKey: "EditedReminderDate")
                    }
                }
            }
            self.view.endEditing(true)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = gbDateFormat
            let gbDate = formatter.string(from: reminderDatePicker.date)
            reminderDateField.text = "\(gbDate)"
            self.view.endEditing(true)
        }
    }
    
    func endDatePickerDone(){
        if (isInEditingMode){
            let defaults = UserDefaults.standard
            if demo(){
            } else {
                let editedTutor = defaults.object(forKey: "EditedTutor") as! String
                if (editedTutor == "yes"){
                    let editedDateObject = defaults.object(forKey: "EditedDate")
                    if (editedDateObject != nil){
                        let formatter = DateFormatter()
                        formatter.dateFormat = gbDateFormatShort
                        let dateTime = formatter.date(from:editedDateObject as! String)
                        endDateField.text = formatter.string(from: dateTime!)
                        
                        UIAlertView(title: localized("error"), message: localized("tutor_target"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
                    }
                } else {
                    let editedDateObject = defaults.object(forKey: "EditedDate") //as! Date
                    if (editedDateObject != nil){
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateTime = formatter.string(from: endDatePicker.date)
                        defaults.set(dateTime, forKey: "EditedDate")
                    }
                }
            }
            self.view.endEditing(true)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = gbDateFormatShort
            let gbDate = formatter.string(from: endDatePicker.date)
            endDateField.text = "\(gbDate)"
            
            let reminderDate = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: endDatePicker.date)!
            self.reminderDatePicker.setDate(reminderDate, animated: false)
            dateFormatter.dateFormat = gbDateFormat
            reminderDateField.text = dateFormatter.string(for: reminderDate)
            reminderDatePicker.maximumDate = endDatePicker.date
            self.view.endEditing(true)
        }
    }
    
    @IBAction func changeReminderSettings(){
        if(reminderSwitch.isOn){
            reminderView.isHidden = false
        } else {
            reminderView.isHidden = true
        }
    }
}
