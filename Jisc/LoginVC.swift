//
//  LoginVC.swift
//  Jisc
//
//  Created by Paul on 3/24/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import FBSDKCoreKit
import Google
import Fabric
import TwitterKit

enum UserType:String {
	case regular = "regular"
	case staff = "staff"
	case social = "social"
	case demo = "demo"
}

func setUserType(_ type:UserType) {
	NSKeyedArchiver.archiveRootObject(type.rawValue, toFile: filePath("UserType"))
}

func currentUserType() -> UserType {
	var userType = UserType.regular
	if let userTypeString = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("UserType")) as? String {
		if let type = UserType(rawValue: userTypeString) {
			userType = type
		}
	}
	return userType
}

func setRememberMe(_ value:Bool) {
	NSKeyedArchiver.archiveRootObject(NSNumber(value: value), toFile: filePath("shouldRememberTheUser"))
}

func shouldRememberMe() -> Bool {
	var shouldRememberMe = false
	if let value = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("shouldRememberTheUser")) as? Bool {
		shouldRememberMe = value
	}
	return shouldRememberMe
}

func setPickedinstitutionId(_ id:String) {
	NSKeyedArchiver.archiveRootObject(id, toFile: filePath("pickedInstitutionId"))
}

func pickedInstitutionId() -> String {
	var pickedInstitutionId = ""
	if let value = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("pickedInstitutionId")) as? String {
		pickedInstitutionId = value
	}
	return pickedInstitutionId
}

func saveSocialData(email:String, name:String, userId:String) {
	var data = [String:String]()
	data["email"] = email
	data["name"] = name
	data["userId"] = userId
	NSKeyedArchiver.archiveRootObject(data, toFile: "socialData")
}

func getSocialData() -> (email:String, name:String, userId:String) {
	var email = ""
	var name = ""
	var userId = ""
	if let data = NSKeyedUnarchiver.unarchiveObject(withFile: "socialData") as? [String:String] {
		if let string = data["email"] {
			email = string
		}
		if let string = data["name"] {
			name = string
		}
		if let string = data["userId"] {
			userId = string
		}
	}
	return (email, name, userId)
}

class LoginVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GIDSignInUIDelegate {

	@IBOutlet weak var studentButton:UIButton!
	@IBOutlet weak var staffButton:UIButton!
	@IBOutlet weak var rememberButton:UIButton!
	@IBOutlet weak var nextButton:UIButton!
	@IBOutlet var loginStep2:UIView!
	@IBOutlet var loginStep3:UIView!
	
	@IBOutlet weak var instituteTextField:UITextField!
	@IBOutlet weak var institutesTable:UITableView!
	@IBOutlet weak var institutesTableHeight:NSLayoutConstraint!
	var filteredInstitutions:[Institution] = [Institution]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(xAPILoginComplete(_:)), name: NSNotification.Name(rawValue: xAPILoginCompleteNotification), object: nil)
		GIDSignIn.sharedInstance().uiDelegate = self
		FBSDKLoginManager().logOut()
		GIDSignIn.sharedInstance().signOut()
		loginStep2.translatesAutoresizingMaskIntoConstraints = false
		loginStep3.translatesAutoresizingMaskIntoConstraints = false
		putViewInHierarchy(loginStep2)
		putViewInHierarchy(loginStep3)
		institutesTable.register(UINib(nibName: kInstituteCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kInstituteCellIdentifier)
		let xmgr = xAPIManager()
		xmgr.silent = true
		xmgr.getIDPS { (success, result, results, error) in
			if success {
				if let keys = result?.allKeys as? [String] {
					for (index, item) in keys.enumerated() {
						let dictionary = NSMutableDictionary()
						dictionary["id"] = "\(index)"
						dictionary["is_learning_analytics"] = "yes"
						dictionary["name"] = item
						dictionary["accesskey"] = ""
						dictionary["secret"] = ""
						_ = Institution.insertInManagedObjectContext(managedContext, dictionary: dictionary)
					}
					dataManager.safelySaveContext()
					self.filterInstitutions("")
					self.institutesTable.reloadData()
					self.institutesTableHeight.constant = self.institutesTable.contentSize.height
					self.view.layoutIfNeeded()
				}
			}
		}
		if shouldRememberMe() {
			print("REMEMBER")
			if JWTStillValid() {
				print("VALID")
				let type = currentUserType()
				var somethingWentWrong = false
				switch type {
				case .regular:
					print("REGULAR")
					let institutions = dataManager.institutions().filter({ (institution) -> Bool in
						var included = false
						if institution.id == pickedInstitutionId() {
							included = true
						}
						return included
					})
					if let institution = institutions.first {
						dataManager.pickedInstitution = institution
					} else {
						somethingWentWrong = true
					}
					break
				case .staff:
					print("STAFF")
					let institutions = dataManager.institutions().filter({ (institution) -> Bool in
						var included = false
						if institution.id == pickedInstitutionId() {
							included = true
						}
						return included
					})
					if let institution = institutions.first {
						dataManager.pickedInstitution = institution
					} else {
						somethingWentWrong = true
					}
					break
				case .social:
					print("SOCIAL")
					dataManager.pickedInstitution = dataManager.socialInstitution()
					let socialData = getSocialData()
					if !socialData.email.isEmpty && !socialData.name.isEmpty && !socialData.userId.isEmpty {
						print("LOGIN")
						socialLogin(email: socialData.email, name: socialData.name, userId: socialData.userId)
					} else {
						print("FAIL")
						setRememberMe(false)
						clearXAPIToken()
					}
					break
				case .demo:
					print("DEMO")
					dataManager.pickedInstitution = dataManager.demoInstitution()
					break
				}
				if somethingWentWrong {
					print("SOMETHING WENT WRONG")
					setRememberMe(false)
					clearXAPIToken()
				} else if type != .social {
					print("LOGIN")
					xAPIManager().getStudentDetails({ (success, result, results, error) in
						var loginSuccessful = false
						if let result = result {
							if let shibID = result["APPSHIB_ID"] as? String {
								if (shibID != "null") {
									loginSuccessful = true
								}
							}
						}
						if (loginSuccessful) {
							print("SUCCESS")
							if type == .staff {
								if let staffId = result?["STAFF_ID"] as? String {
									NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: staffId)
								} else {
									NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: result?["STUDENT_ID"] as? String)
								}
							} else {
								NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: result?["STUDENT_ID"] as? String)
							}
							self.dismiss(animated: true, completion: {})
						} else {
							print("FAIL")
							setRememberMe(false)
							clearXAPIToken()
						}
					})
				}
			} else {
				print("NOT VALID")
				setRememberMe(false)
				clearXAPIToken()
			}
		}
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		view.layoutIfNeeded()
		institutesTableHeight.constant = institutesTable.contentSize.height
		view.layoutIfNeeded()
	//	loginFieldsBottomSpace = view.frame.size.height - (loginView.frame.origin.y + loginView.frame.size.height)
	//	loginFieldsBottomSpace += loginView.frame.size.height - (loginFieldsView.frame.origin.y + loginFieldsView.frame.size.height)
//		let currentUser = getCurrentUser()
//		var instituteID:String? = nil
//		var email:String? = nil
//		var password:String? = nil
//		if (currentUser != nil) {
//			instituteID = currentUser!["instituteID"]
//			email = currentUser!["email"]
//			password = currentUser!["password"]
//		} else if (weHaveACurrentUser()) {
//			instituteID = currentlyLoggedInStudentInstitute
//			email = currentlyLoggedInStudentEmail
//			password = currentlyLoggedInStudentPassword
//		} else if (shouldRememberXAPIUser() && xAPIToken() != nil) {
//			dataManager.loginWithXAPI(xAPIToken()!, completion: { (success, failureReason) in
//				if (success) {
//					DELEGATE.mainController = MainTabBarController()
//					DELEGATE.window?.rootViewController = DELEGATE.mainController
//				} else {
//					self.launchImage.removeFromSuperview()
//					UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalizedString).show()
//				}
//			})
//		}
//		
//		if (instituteID != nil && email != nil && password != nil) {
//			dataManager.loginStudent(instituteID!, email: email!, password: password!, completion: { (success, failureReason) -> Void in
//				if (success) {
//					currentlyLoggedInStudentInstitute = instituteID!
//					currentlyLoggedInStudentEmail = email!
//					currentlyLoggedInStudentPassword = password!
//					DELEGATE.mainController = MainTabBarController()
//					DELEGATE.window?.rootViewController = DELEGATE.mainController
//				} else {
//					self.launchImage.removeFromSuperview()
//					UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalizedString).show()
//				}
//			})
//		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	func socialLogin(email:String, name:String, userId:String) {
		dataManager.pickedInstitution = dataManager.socialInstitution()
		dataManager.socialLogin(email: email, name: name, userId: userId) { (success, failureReason) in
			if (success) {
				if let student = dataManager.currentStudent {
					dataManager.currentStudent?.jisc_id = student.id
				}
				RunLoop.current.add(runningActivititesTimer, forMode: RunLoopMode.commonModes)
				DELEGATE.menuView = MenuView.createView()
			} else {
				UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
            }
        }
    }
	func putViewInHierarchy(_ subview:UIView) {
		subview.alpha = 0.0
		view.addSubview(subview)
		let leading = NSLayoutConstraint(item: subview, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
		let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: subview, attribute: .trailing, multiplier: 1.0, constant: 0.0)
		let top = NSLayoutConstraint(item: subview, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
		let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: subview, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		view.addConstraints([leading, trailing, top, bottom])
	}
	
	func filterInstitutions(_ string:String) {
		filteredInstitutions.removeAll()
		let fetchRequest:NSFetchRequest<Institution> = NSFetchRequest(entityName: institutionEntityName)
		if (!string.isEmpty) {
			fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", string)
		}
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		do {
			let institutions = try managedContext.fetch(fetchRequest)
			for (_, item) in institutions.enumerated() {
				filteredInstitutions.append(item)
			}
		} catch let error as NSError {
			print("filter institutions error: \(error.localizedDescription)")
		}
		removeInstitutionWithName("Social")
		removeInstitutionWithName("Demo")
	}
	
	func removeInstitutionWithName(_ name:String) {
		var institutionIndex = -1
		for (index, item) in filteredInstitutions.enumerated() {
			if item.name.lowercased() == name.lowercased() {
				institutionIndex = index
				break
			}
		}
		if institutionIndex >= 0 {
			filteredInstitutions.remove(at: institutionIndex)
		}
	}
	
	func xAPILoginComplete(_ notification:Notification) {
		if let token = xAPIToken() {
			dataManager.loginWithXAPI(token, completion: { (success, failureReason) in
				if (success) {
					if let jisc_id = notification.object as? String {
						dataManager.currentStudent?.jisc_id = jisc_id
					}
					if let institution = dataManager.pickedInstitution {
						dataManager.currentStudent?.institution = institution
					}
					RunLoop.current.add(runningActivititesTimer, forMode: RunLoopMode.commonModes)
					DELEGATE.menuView = MenuView.createView()
				} else {
					UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
				}
			})
		}
	}
	
	func goToStep1() {
		UIView.animate(withDuration: 0.25) { 
			self.loginStep2.alpha = 0.0
			self.loginStep3.alpha = 0.0
		}
	}
	
	func goToStep2() {
		UIView.animate(withDuration: 0.25) {
			self.loginStep2.alpha = 1.0
			self.loginStep3.alpha = 0.0
		}
	}
	
	func goToStep3() {
		UIView.animate(withDuration: 0.25) {
			self.loginStep2.alpha = 0.0
			self.loginStep3.alpha = 1.0
		}
	}

	@IBAction func imAStudent(_ sender:UIButton?) {
		setUserType(.regular)
		studentButton.isSelected = true
		staffButton.isSelected = false
		nextButton.isEnabled = true
	}
	
	@IBAction func imAMemberOfStaff(_ sender:UIButton?) {
		setUserType(.staff)
		studentButton.isSelected = false
		staffButton.isSelected = true
		nextButton.isEnabled = true
	}
	
	@IBAction func next(_ sender:UIButton?) {
		goToStep3()
	}
	
	@IBAction func rememberMe(_ sender:UIButton?) {
		rememberButton.isSelected = !rememberButton.isSelected
		setRememberMe(rememberButton.isSelected)
	}
	
	@IBAction func dontRememberMe(_ sender:UIButton?) {
		setRememberMe(false)
		goToStep3()
	}
	
	@IBAction func facebook(_ sender:UIButton?) {
		setUserType(.social)
		FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
			if error == nil {
				FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name"]).start(completionHandler: { (connection, result, error) in
					if error == nil {
						var dataOk = false
						if let result = result as? [String:String] {
							if let email = result["email"] {
								if let id = result["id"] {
									if let name = result["name"] {
										dataOk = true
										self.socialLogin(email: email, name: name, userId: id)
									}
								}
							}
						}
						if !dataOk {
							self.finishedWithError(localized("an_unknown_error_occured_please_try_again"))
						}
					} else {
						self.finishedWithError(error!.localizedDescription)
					}
				})
			} else {
				self.finishedWithError(error!.localizedDescription)
			}
		}
	}
	
	/*@IBAction func twitter(_ sender:UIButton?) {
		setUserType(.social)
		Twitter().logIn(with: self) { (session, error) in
			if error == nil {
				TWTRAPIClient.withCurrentUser().requestEmail(forCurrentUser: { (string, error) in
					if error == nil {
						var dataOk = false
						if let email = string {
							if let id = session?.userID {
								if let name = session?.userName {
									dataOk = true
									self.socialLogin(email: email, name: name, userId: id)
								}
							}
						}
						if !dataOk {
							self.finishedWithError(localized("an_unknown_error_occured_please_try_again"))
						}
					} else {
						self.finishedWithError(error!.localizedDescription)
					}
					DELEGATE.menuView = MenuView.createView()
				} else {
					UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
				}
			})

		}
	}*/
	
	@IBAction func goolgePlus(_ sender:UIButton?) {
		setUserType(.social)
		GIDSignIn.sharedInstance().signIn()
	}
	
    @IBAction func backToFirstPage(_ sender: UIButton) {
        goToStep1()
    }
    
    /*func socialLogin(email:String, name:String, userId:String) {
		if shouldRememberMe() {
			saveSocialData(email: email, name: name, userId: userId)
		}
		dataManager.pickedInstitution = dataManager.socialInstitution()
		dataManager.socialLogin(email: email, name: name, userId: userId) { (success, failureReason) in
			if (success) {
				if let student = dataManager.currentStudent {
					dataManager.currentStudent?.jisc_id = student.id
				}
				RunLoop.current.add(runningActivititesTimer, forMode: RunLoopMode.commonModes)
				DELEGATE.mainController = MainTabBarController()
				DELEGATE.window?.rootViewController = DELEGATE.mainController
			} else {
				UIAlertView(title: localized("error"), message: failureReason, delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
			}
		}
	}*/
	
	@IBAction func demoMode(_ sender:UIButton?) {
		setUserType(.demo)
		setXAPIToken(demoXAPIToken)
		dataManager.pickedInstitution = dataManager.demoInstitution()
		xAPIManager().getStudentDetails({ (success, result, results, error) in
			var loginSuccessful = false
			if let result = result {
				if let shibID = result["APPSHIB_ID"] as? String {
					if (shibID != "null") {
						loginSuccessful = true
					}
				}
			}
			if (loginSuccessful) {
				NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: result?["STUDENT_ID"] as? String)
			} else {
				
			}
		})
	}
	
	//MARK: - Google Delegate
	
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		if error == nil {
			if let signIn = signIn {
				if let currentUser = signIn.currentUser {
					if let profile = currentUser.profile {
						if let email = profile.email {
							if let name = profile.name {
								if let id = currentUser.userID {
									self.socialLogin(email: email, name: name, userId: id)
								}
							}
						}
					}
				}
			}
		} else {
			self.finishedWithError(error!.localizedDescription)
		}
	}
	
	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		navigationController?.present(viewController, animated: true, completion: nil)
	}
	
	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		viewController.dismiss(animated: true, completion: nil)
	}
	
	//MARK: - Handle completion
	
	func finishedWithError(_ message:String) {
		let alert = UIAlertController(title: localized("error"), message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
		navigationController?.present(alert, animated: true, completion: nil)
	}
	
	//MARK: UITextField Delegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let shouldChange = true
		if (textField == instituteTextField && textField.text != nil) {
			let nsString = NSString(string: textField.text!)
			filterInstitutions(nsString.replacingCharacters(in: range, with: string))
			institutesTable.reloadData()
			institutesTableHeight.constant = institutesTable.contentSize.height
			view.layoutIfNeeded()
		}
		return shouldChange
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredInstitutions.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var theCell = tableView.dequeueReusableCell(withIdentifier: kInstituteCellIdentifier)
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 35.0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let theCell = cell as? InstituteCell {
			if indexPath.row < filteredInstitutions.count {
				theCell.loadInstitute(filteredInstitutions[indexPath.row])
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedInstituteObject = filteredInstitutions[indexPath.row]
		dataManager.pickedInstitution = selectedInstituteObject
		setPickedinstitutionId(selectedInstituteObject.id)
		if (selectedInstituteObject.isLearningAnalytics.boolValue) {
			xAPIManager().getIDPS { (success, result, results, error) in
				if (result != nil) {
					let vc:xAPILoginVC = xAPILoginVC()
					vc.idp = getIDPForInstitution(selectedInstituteObject.name, dictionary: result!)
					self.navigationController?.present(vc, animated: true, completion: nil)
				}
			}
		} else {
			print("not learning analityics: \(selectedInstituteObject.name)");
		}
		
		instituteTextField.resignFirstResponder()
	}
}
