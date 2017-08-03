//
//  DataManager.swift
//  Jisc
//
//  Created by Therapy Box on 10/21/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import CoreData

let kDefaultFailureReason = localized("an_unknown_error_occured_please_try_again")
let kRefreshActivitiesScreen = "kRefreshActivitiesScreen"

typealias dataManagerCompletionBlock = ((_ success:Bool, _ failureReason:String) -> Void)

let managedContext = DELEGATE.managedObjectContext
let dataManager = DataManager()

var runningActivititesTimer:Timer!

/*
An activity must be stopped after 3 hours
*/

let maximumMinutesActivity = 180

func readModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"1", name:localized("reading"), present: localized("read"), past: localized("read"), english: "Reading")
}
func writeModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"2", name: localized("writing"), present: localized("write"), past: localized("wrote"), english: "Writing")
}
func researchModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"3", name: localized("research"), present: localized("research"), past: localized("researched"), english: "Research")
}
func groupStudyModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"4", name: localized("group_study"), present: localized("group_study"), past: localized("studied"), english: "Group Study")
}
func designModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"5", name: localized("designing"), present: localized("design"), past: localized("designed"), english: "Designing")
}
func presentModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"6", name: localized("presenting"), present: localized("present"), past: localized("presented"), english: "Presenting")
}
func blogModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"7", name: localized("blogging"), present: localized("blog"), past: localized("blogged"), english: "Blogging")
}
func reviseModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"8", name: localized("revising"), present: localized("revise"), past: localized("revised"), english: "Revising")
}
func practiceModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"9", name: localized("practicing"), present: localized("practice"), past: localized("practiced"), english: "Practicing")
}
func experimentModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"10", name: localized("experimenting"), present: localized("experiment"), past: localized("experimented"), english: "Experimenting")
}
func cAssgnModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"11", name: localized("completing_assignment"), present: localized("complete_assignment"), past: localized("completed_assignment"), english: "Completing Assignment")
}
func examModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"12", name: localized("in_an_exam"), present: localized("be_in_an_exam"), past: localized("been_in_an_exam"), english: "In an exam")
}
func disModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"13", name: localized("preparing_a_dissertation"), present: localized("prepare_a_dissertation"), past: localized("prepared_a_dissertation"), english: "Preparing a dissertation")
}
func lecturesModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"14", name: localized("attending_lectures"), present: localized("attend_lectures"), past: localized("attended_lectures"), english: "Attending Lectures")
}
func seminarsModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"15", name: localized("attending_seminars"), present: localized("attend_seminars"), past: localized("attended_seminars"), english: "Attending Seminars")
}
func tutorialsModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"16", name: localized("attending_tutorials"), present: localized("attend_tutorials"), past: localized("attended_tutorials"), english: "Attending Tutorials")
}
func labsModel() -> (context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String) {
	return (context:managedContext, id:"17", name: localized("attending_labs"), present: localized("attend_labs"), past: localized("attended_labs"), english: "Attending Labs")
}

class DataManager: NSObject {
	
	var currentStudent:Student?
	var pickedInstitution:Institution?
	var studentLastWeekRankings:[Int:Int] = [Int:Int]()
	var studentOverallRankings:[Int:Int] = [Int:Int]()
	var runningLogs:[RunningLogContainer] = [RunningLogContainer]()
	var myAssignmentRankings:[(name:String, rank:Int)] = [(name:String, rank:Int)]()
	
	func initialize() {
		cleanEverything()
		runningActivititesTimer = Timer(timeInterval: 10, target: self, selector: #selector(DataManager.checkRunningActivitites), userInfo: nil, repeats: true)
	}
	
	func remakeActivityAndActivityTypes() {
		let readActivity = Activity.insertInManagedObjectContext(readModel())
		let writeActivity = Activity.insertInManagedObjectContext(writeModel())
		let researchActivity = Activity.insertInManagedObjectContext(researchModel())
		let groupStudyActivity = Activity.insertInManagedObjectContext(groupStudyModel())
		let designActivity = Activity.insertInManagedObjectContext(designModel())
		let presentActivity = Activity.insertInManagedObjectContext(presentModel())
		let blogActivity = Activity.insertInManagedObjectContext(blogModel())
		let reviseActivity = Activity.insertInManagedObjectContext(reviseModel())
		let practiceActivity = Activity.insertInManagedObjectContext(practiceModel())
		let experimentActivity = Activity.insertInManagedObjectContext(experimentModel())
		let completingAssignmentActivity = Activity.insertInManagedObjectContext(cAssgnModel())
		let examActivity = Activity.insertInManagedObjectContext(examModel())
		let dissertationActivity = Activity.insertInManagedObjectContext(disModel())
		let lecturesActivity = Activity.insertInManagedObjectContext(lecturesModel())
		let seminarsActivity = Activity.insertInManagedObjectContext(seminarsModel())
		let tutorialsActivity = Activity.insertInManagedObjectContext(tutorialsModel())
		let labsActivity = Activity.insertInManagedObjectContext(labsModel())
		
		let artsActivityType = ActivityType.insertInManagedObjectContext(managedContext, name: localized("studying_arts"), english: "Studying (arts)")
		artsActivityType.addActivities([readActivity, writeActivity, researchActivity, groupStudyActivity, designActivity, presentActivity, blogActivity, reviseActivity, practiceActivity])
		let scienceActivityType = ActivityType.insertInManagedObjectContext(managedContext, name: localized("studying_science"), english: "Studying (science)")
		scienceActivityType.addActivities([readActivity, writeActivity, researchActivity, groupStudyActivity, experimentActivity, presentActivity, blogActivity, reviseActivity])
		let courseworkActivityType = ActivityType.insertInManagedObjectContext(managedContext, name: localized("coursework_exams"), english: "Coursework/Exams")
		courseworkActivityType.addActivities([completingAssignmentActivity, examActivity, dissertationActivity, reviseActivity])
		let attendanceActivityType = ActivityType.insertInManagedObjectContext(managedContext, name: localized("attending"), english: "Attending")
		attendanceActivityType.addActivities([lecturesActivity, seminarsActivity, tutorialsActivity, labsActivity])
		safelySaveContext()
	}
	
	func cleanEverything() {
		runningLogs.removeAll()
		var array = getDBObjectsWithEntityName(activityLogEntityName)
		for (_, item) in array.enumerated() {
			let log = item as? ActivityLog
			if (log != nil) {
				if (log!.isRunning.boolValue) {
					runningLogs.append(RunningLogContainer(log: log!))
					deleteLocalNotification(log!.id)
				}
			}
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(studentEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(trophyEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(studentTrophyEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(friendEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(friendRequestEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(sentFriendRequestEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(colleagueEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(courseEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(moduleEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(targetEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(stretchTargetEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(feedEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(markEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(markValueEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = activityTypes()
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = allActivities()
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		safelySaveContext()
	}
	
	func cleanUserSpecificData() {
		runningLogs.removeAll()
		var array = getDBObjectsWithEntityName(activityLogEntityName)
		for (_, item) in array.enumerated() {
			let log = item as? ActivityLog
			if (log != nil) {
				if (log!.isRunning.boolValue) {
					runningLogs.append(RunningLogContainer(log: log!))
					deleteLocalNotification(log!.id)
				}
			}
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(studentEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(trophyEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(studentTrophyEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(friendEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(friendRequestEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(sentFriendRequestEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(colleagueEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(courseEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(moduleEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(targetEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(stretchTargetEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(feedEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(markEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		array = getDBObjectsWithEntityName(markValueEntityName)
		for (_, item) in array.enumerated() {
			managedContext.delete(item)
		}
		safelySaveContext()
	}
	
	func getDBObjectsWithEntityName(_ name:String) -> [NSManagedObject] {
		let fetchRequest:NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: name)
		var array:[NSManagedObject] = [NSManagedObject]()
		do {
			let logs = try managedContext.fetch(fetchRequest)
			for (_, item) in logs.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get \(name) for deletion error: \(error.localizedDescription)")
		}
		return array
	}
	
	func logout() {
		setRememberMe(false)
		setUserType(.regular)
		setPickedinstitutionId("")
		saveSocialData(email: "", name: "", userId: "")
		if let cookies = HTTPCookieStorage.shared.cookies {
			for cookie in cookies {
				HTTPCookieStorage.shared.deleteCookie(cookie)
			}
		}
		runningActivititesTimer.invalidate()
		//DELEGATE.mainController?.feedViewController.refreshTimer?.invalidate()
		dataManager.currentStudent = nil
		dataManager.firstTrophyCheck = true
		clearXAPIToken()
		let nvc = UINavigationController(rootViewController: LoginVC())
		nvc.isNavigationBarHidden = true
		DELEGATE.window?.rootViewController = nvc
	}
	
	//MARK: Institutions
	
	func institutions() -> [Institution] {
		let fetchRequest:NSFetchRequest<Institution> = NSFetchRequest(entityName: institutionEntityName)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		var array:[Institution] = [Institution]()
		do {
			let institutions = try managedContext.fetch(fetchRequest)
			for (_, item) in institutions.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get institutions error: \(error.localizedDescription)")
		}
		return array
	}
	
	func socialInstitution() -> Institution {
		let fetchRequest:NSFetchRequest<Institution> = NSFetchRequest(entityName: institutionEntityName)
		fetchRequest.predicate = NSPredicate(format: "name == %@", "Social")
		var object:Institution?
		do {
			if let institution = try managedContext.fetch(fetchRequest).first {
				object = institution
			}
		} catch let error as NSError {
			print("get social institution error: \(error.localizedDescription)")
		}
		let dictionary = NSMutableDictionary()
		dictionary["id"] = "SOCIAL"
		dictionary["is_learning_analytics"] = "yes"
		dictionary["name"] = "Social"
		dictionary["accesskey"] = "key"
		dictionary["secret"] = "secret"
		if let institution = object {
			institution.loadDictionary(dictionary)
			return institution
		} else {
			return Institution.insertInManagedObjectContext(managedContext, dictionary: dictionary)
		}
	}
	
	func demoInstitution() -> Institution {
		let fetchRequest:NSFetchRequest<Institution> = NSFetchRequest(entityName: institutionEntityName)
		fetchRequest.predicate = NSPredicate(format: "name == %@", "Demo")
		var object:Institution?
		do {
			if let institution = try managedContext.fetch(fetchRequest).first {
				object = institution
			}
		} catch let error as NSError {
			print("get demo institution error: \(error.localizedDescription)")
		}
		let dictionary = NSMutableDictionary()
		dictionary["id"] = "DEMO"
		dictionary["is_learning_analytics"] = "yes"
		dictionary["name"] = "Demo"
		dictionary["accesskey"] = "key"
		dictionary["secret"] = "secret"
		if let institution = object {
			institution.loadDictionary(dictionary)
			return institution
		} else {
			return Institution.insertInManagedObjectContext(managedContext, dictionary: dictionary)
		}
	}
	
	//MARK: ActivityLogs
	
	func activityLogsArray() -> [ActivityLog] {
		var array:[ActivityLog] = [ActivityLog]()
		array.append(contentsOf: runningActivities())
		array.append(contentsOf: finishedActivities())
		return array
		
//		let fetchRequest = NSFetchRequest(entityName: activityLogEntityName)
//		fetchRequest.predicate = NSPredicate(format: "student.id == %@", currentStudent!.id)
//		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//		var array:[ActivityLog] = [ActivityLog]()
//		do {
//			let logs = try managedContext.executeFetchRequest(fetchRequest)
//			for (_, item) in logs.enumerate() {
//				let object = item as? ActivityLog
//				if (object != nil) {
//					array.append(object!)
//				}
//			}
//		} catch let error as NSError {
//			print("get ALL activities error: \(error.localizedDescription)")
//		}
//		return array
	}
	
	func finishedActivities() -> [ActivityLog] {
		let fetchRequest:NSFetchRequest<ActivityLog> = NSFetchRequest(entityName: activityLogEntityName)
		fetchRequest.predicate = NSPredicate(format: "student.id == %@ AND isRunning == false", currentStudent!.id)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false), NSSortDescriptor(key: "createdDate", ascending: false)]
		var array:[ActivityLog] = [ActivityLog]()
		do {
			let logs = try managedContext.fetch(fetchRequest)
			for (_, item) in logs.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get finished activities error: \(error.localizedDescription)")
		}
		return array
	}
	
	func runningActivities() -> [ActivityLog] {
		var array:[ActivityLog] = [ActivityLog]()
		if (currentStudent != nil) {
			let fetchRequest:NSFetchRequest<ActivityLog> = NSFetchRequest(entityName: activityLogEntityName)
			fetchRequest.predicate = NSPredicate(format: "student.id == %@ AND isRunning == true", currentStudent!.id)
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
			do {
				let logs = try managedContext.fetch(fetchRequest)
				for (_, item) in logs.enumerated() {
					array.append(item)
				}
			} catch let error as NSError {
				print("get running activities error: \(error.localizedDescription)")
			}
		}
		return array
	}
	
	func checkRunningActivitites() {
		if (currentStudent != nil) {
			let array = runningActivities()
			for (_, item) in array.enumerated() {
				if (!item.isPaused.boolValue) {
					item.timeSpent = Int(abs(item.date.timeIntervalSinceNow) / 60) as NSNumber
					if (item.timeSpent.intValue >= maximumMinutesActivity) {
						item.timeSpent = maximumMinutesActivity as NSNumber
						deleteLocalNotification(item.id)
						let mgr = DownloadManager()
						mgr.shouldNotifyAboutInternetConnection = false
						mgr.addActivityLog(item, alertAboutInternet: false) { (success, result, results, error) -> Void in
							self.deleteObject(item)
							self.getStudentTrophies({ (success, failureReason) -> Void in
								self.refreshStudentActivityLogs(success, error: error, completion: { (success, failureReason) -> Void in
									self.checkRunningActivitites()
									NotificationCenter.default.post(name: Notification.Name(rawValue: kRefreshActivitiesScreen), object: nil)
								})
							})
						}
						break
					}
				}
			}
			self.getStudentTrophies({ (success, failureReason) -> Void in
				
			})
		}
	}
	
	func stopRunningActivity(_ sender:ActivityLog, completion:@escaping dataManagerCompletionBlock) {
		deleteLocalNotification(sender.id)
		sender.timeSpent = Int(abs(sender.date.timeIntervalSinceNow) / 60) as NSNumber
		if (sender.timeSpent.intValue > maximumMinutesActivity) {
			sender.timeSpent = maximumMinutesActivity as NSNumber
		}
		if (sender.timeSpent.intValue < 1) {
			completion(false, "timeZero")
		} else {
			DownloadManager().addActivityLog(sender, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
				if (success) {
					self.getStudentTrophies({ (success, failureReason) -> Void in
						self.refreshStudentActivityLogs(success, error: error, completion: completion)
					})
				} else {
					if (error != nil) {
						completion(false, error!)
					} else {
						completion(false, kDefaultFailureReason)
					}
				}
			})
		}
		deleteObject(sender)
	}
	
	//MARK: Targets
	
	func targets() -> [Target] {
		let fetchRequest:NSFetchRequest<Target> = NSFetchRequest(entityName: targetEntityName)
		fetchRequest.predicate = NSPredicate(format: "student.id == %@", currentStudent!.id)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
		var array:[Target] = [Target]()
		do {
			let logs = try managedContext.fetch(fetchRequest)
			for (_, item) in logs.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get targets error: \(error.localizedDescription)")
		}
		return array
	}
	
	//MARK: Stretch Targets
	
	func stretchTargets() -> [StretchTarget] {
		let fetchRequest:NSFetchRequest<StretchTarget> = NSFetchRequest(entityName: stretchTargetEntityName)
		var array:[StretchTarget] = [StretchTarget]()
		do {
			let logs = try managedContext.fetch(fetchRequest)
			for (_, item) in logs.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get stretch targets error: \(error.localizedDescription)")
		}
		return array
	}
	
	func getStretchTargetForTarget(_ target:Target) -> StretchTarget? {
		let fetchRequest:NSFetchRequest<StretchTarget> = NSFetchRequest(entityName: stretchTargetEntityName)
		fetchRequest.predicate = NSPredicate(format: "target.id == %@ AND student.id == %@", target.id, currentStudent!.id)
		var stretchTarget:StretchTarget?
		do {
			try stretchTarget = managedContext.fetch(fetchRequest).first
		} catch let error as NSError {
			print("stretch target with id: \(target.id) was not found. Error: \(error.localizedDescription)")
		}
		return stretchTarget
	}
	
	//MARK: Student Modules
	
	func courses() -> [Course] {
		let fetchRequest:NSFetchRequest<Course> = NSFetchRequest(entityName: courseEntityName)
		fetchRequest.predicate = NSPredicate(format: "student.id == %@", currentStudent!.id)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		var array:[Course] = [Course]()
		do {
			let logs = try managedContext.fetch(fetchRequest)
			for (_, item) in logs.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get courses error: \(error.localizedDescription)")
		}
		return array
	}
	
	func modules() -> [Module] {
		let fetchRequest:NSFetchRequest<Module> = NSFetchRequest(entityName: moduleEntityName)
		fetchRequest.predicate = NSPredicate(format: "ANY students.id == %@", currentStudent!.id)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		var array:[Module] = [Module]()
		do {
			let logs = try managedContext.fetch(fetchRequest)
			for (_, item) in logs.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get modules error: \(error.localizedDescription)")
		}
		if currentUserType() == .social {
			array.sort { (module1, module2) -> Bool in
				var sorted = true
				if module1.name > module2.name {
					sorted = false
				}
				if module1.id == "add_module" {
					sorted = false
				} else if module2.id == "add_module" {
					sorted = true
				}
				return sorted
			}
		}
		return array
	}
	
	func moduleWithID(_ ID:String?) -> Module? {
		var module:Module? = nil
		if (ID != nil) {
			let fetchRequest:NSFetchRequest<Module> = NSFetchRequest(entityName: moduleEntityName)
			fetchRequest.predicate = NSPredicate(format: "id == %@ AND ANY students.id == %@", ID!, currentStudent!.id)
			do {
				try module = managedContext.fetch(fetchRequest).first
			} catch let error as NSError {
				print("module with id: \(ID) was not found. Error: \(error.localizedDescription)")
			}
		}
		return module
	}
	
	func moduleNameAtIndex(_ index:Int) -> String? {
		var module:Module? = nil
		let modulesArray = modules()
		if (modulesArray.count > index) {
			module = modules()[index]
		}
		return module?.name
	}
	
	func moduleIDAtIndex(_ index:Int) -> String? {
		var module:Module? = nil
		let modulesArray = modules()
		if (modulesArray.count > index) {
			module = modules()[index]
		}
		return module?.id
	}
	
	func indexOfModuleWithID(_ moduleID:String) -> Int? {
		let module = moduleWithID(moduleID)
		var index:Int? = nil
		if (module != nil) {
			index = modules().index(of: module!)
		}
		return index
	}
	
	//MARK: Delete an object
	
	func deleteObject(_ sender:NSManagedObject) {
		let object = sender as? ActivityLog
		if (object != nil) {
			deleteLocalNotification(object!.id)
		}
		managedContext.delete(sender)
		safelySaveContext()
	}
	
	//MARK: ActivityTypes
	
	func activityTypes() -> [ActivityType] {
		let fetchRequest:NSFetchRequest<ActivityType> = NSFetchRequest(entityName: activityTypeEntityName)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		var array:[ActivityType] = [ActivityType]()
		do {
			let types = try managedContext.fetch(fetchRequest)
			for (_, item) in types.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get activity types error: \(error.localizedDescription)")
		}
		return array
	}
	
	func activityTypeWithName(_ name:String) -> ActivityType? {
		let fetchRequest:NSFetchRequest<ActivityType> = NSFetchRequest(entityName: activityTypeEntityName)
//		fetchRequest.predicate = NSPredicate(format: "name == %@", name)
		fetchRequest.predicate = NSPredicate(format: "englishName == %@", name)
		var activityType:ActivityType? = nil
		do {
			try activityType = managedContext.fetch(fetchRequest).first
		} catch let error as NSError {
			print("get running activities error: \(error.localizedDescription)")
		}
		return activityType
	}
	
	func activityTypeNameAtIndex(_ index:Int) -> String? {
		let array = activityTypes()
		var name:String? = nil
		if (index < array.count) {
			name = array[index].name
		}
		return name
	}
	
	func indexOfActivityType(_ activityType:ActivityType) -> Int? {
		let array = activityTypes()
		var index:Int? = nil
		if (array.contains(activityType)) {
			index = array.index(of: activityType)
		}
		return index
	}
	
	//MARK: Activities
	
	func allActivities() -> [Activity] {
		let fetchRequest:NSFetchRequest<Activity> = NSFetchRequest(entityName: activityEntityName)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		var array:[Activity] = [Activity]()
		do {
			let activities = try managedContext.fetch(fetchRequest)
			for (_, item) in activities.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get all activities error: \(error.localizedDescription)")
		}
		return array
	}
	
	func activitiesWithType(_ type:ActivityType) -> [Activity] {
		let fetchRequest:NSFetchRequest<Activity> = NSFetchRequest(entityName: activityEntityName)
//		fetchRequest.predicate = NSPredicate(format: "ANY activityTypes.name == %@", type.name)
		fetchRequest.predicate = NSPredicate(format: "ANY activityTypes.englishName == %@", type.englishName)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		var array:[Activity] = [Activity]()
		do {
			let activities = try managedContext.fetch(fetchRequest)
			for (_, item) in activities.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get activities with type \(type.name) error: \(error.localizedDescription)")
		}
		return array
	}
	
	func activityWithName(_ name:String, type:ActivityType) -> Activity? {
		let fetchRequest:NSFetchRequest<Activity> = NSFetchRequest(entityName: activityEntityName)
		fetchRequest.predicate = NSPredicate(format: "englishName == %@ AND ANY activityTypes.englishName == %@", name, type.englishName)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		var activity:Activity?
		do {
			try activity = managedContext.fetch(fetchRequest).first
		} catch let error as NSError {
			print("activity with name: \(name) was not found. Error: \(error.localizedDescription)")
		}
		return activity
	}
	
	func activityAtIndex(_ index:Int, type:ActivityType) -> Activity? {
		let activity:Activity? = activitiesWithType(type)[index]
		return activity
	}
	
	func indexOfActivityWithName(_ name:String, type:ActivityType) -> Int? {
		let activity = activityWithName(name, type: type)
		var index:Int? = nil
		if (activity != nil) {
			index = activitiesWithType(type).index(of: activity!)
		}
		return index
	}
	
	//MARK: Friend Requests
	
	func friendRequests() -> [FriendRequest] {
		let fetchRequest:NSFetchRequest<FriendRequest> = NSFetchRequest(entityName: friendRequestEntityName)
		fetchRequest.predicate = NSPredicate(format: "requestedFriendshipOf.id == %@", currentStudent!.id)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
		var array:[FriendRequest] = [FriendRequest]()
		do {
			let types = try managedContext.fetch(fetchRequest)
			for (_, item) in types.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get friend requests error: \(error.localizedDescription)")
		}
		return array
	}
	
	//MARK: Friends
	
	func friends() -> [Friend] {
		let fetchRequest:NSFetchRequest<Friend> = NSFetchRequest(entityName: friendEntityName)
		fetchRequest.predicate = NSPredicate(format: "friendOf.id == %@", currentStudent!.id)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
		var array:[Friend] = [Friend]()
		do {
			let types = try managedContext.fetch(fetchRequest)
			for (_, item) in types.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get friend requests error: \(error.localizedDescription)")
		}
		return array
	}
	
	//MARK: Sent Friend Requests
	
	func sentFriendRequests() -> [SentFriendRequest] {
		let fetchRequest:NSFetchRequest<SentFriendRequest> = NSFetchRequest(entityName: sentFriendRequestEntityName)
		fetchRequest.predicate = NSPredicate(format: "requestSender.id == %@", currentStudent!.id)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
		var array:[SentFriendRequest] = [SentFriendRequest]()
		do {
			let types = try managedContext.fetch(fetchRequest)
			for (_, item) in types.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get friend requests error: \(error.localizedDescription)")
		}
		return array
	}
	
	//MARK: Students in the same course
	
	func studentsInTheSameCourse() -> [Colleague] {
		let fetchRequest:NSFetchRequest<Colleague> = NSFetchRequest(entityName: colleagueEntityName)
		fetchRequest.predicate = NSPredicate(format: "inTheSameCourseWith.id == %@", currentStudent!.id)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
		var array:[Colleague] = [Colleague]()
		do {
			let types = try managedContext.fetch(fetchRequest)
			for (_, item) in types.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get friend requests error: \(error.localizedDescription)")
		}
		return array
	}
	
	//MARK: Feeds
	
	func myFeeds() -> [Feed] {
		let fetchRequest:NSFetchRequest<Feed> = NSFetchRequest(entityName: feedEntityName)
//		fetchRequest.predicate = NSPredicate(format: "to == %@ AND isHidden == FALSE", currentStudent!.id)
		fetchRequest.predicate = NSPredicate(format: "isHidden == FALSE")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
		var array:[Feed] = [Feed]()
		do {
			let feeds = try managedContext.fetch(fetchRequest)
			for (_, item) in feeds.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get feeds requests error: \(error.localizedDescription)")
		}
		array.sort { (feed1, feed2) -> Bool in
			var isSorted = true
			if feed1.activityType != "temp_push_notification" {
				if feed2.activityType == "temp_push_notification" {
					isSorted = false
				}
			}
			if isSorted {
				if feed1.activityType != "temp_push_notification" {
					if feed2.activityType != "temp_push_notification" {
						if feed1.createdDate.compare(feed2.createdDate) == .orderedAscending {
							isSorted = false
						}
					}
				}
				if feed1.activityType == "temp_push_notification" {
					if feed2.activityType == "temp_push_notification" {
						if feed1.createdDate.compare(feed2.createdDate) == .orderedAscending {
							isSorted = false
						}
					}
				}
			}
			return isSorted
		}
		return array
	}
	
	//MARK: Marks
	
	func myMarks() -> [Mark] {
		let fetchRequest:NSFetchRequest<Mark> = NSFetchRequest(entityName: markEntityName)
		fetchRequest.predicate = NSPredicate(format: "student.id == %@", currentStudent!.id)
		var array:[Mark] = [Mark]()
		do {
			let marks = try managedContext.fetch(fetchRequest)
			for (_, item) in marks.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get marks requests error: \(error.localizedDescription)")
		}
		return array
	}
	
	//MARK: Trophies
	
	func availableTrophies() -> [Trophy] {
		let fetchRequest:NSFetchRequest<Trophy> = NSFetchRequest(entityName: trophyEntityName)
		var array:[Trophy] = [Trophy]()
		do {
			let trophies = try managedContext.fetch(fetchRequest)
			for (_, item) in trophies.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get trophies requests error: \(error.localizedDescription)")
		}
		array.sort { (trophy1, trophy2) -> Bool in
			var result:Bool = false
			let string1:NSString = trophy1.id as NSString
			let string2:NSString = trophy2.id as NSString
			if (string1.integerValue <= string2.integerValue) {
				result = true
			}
			return result
		}
		return array
	}
	
	func myTrophies() -> [StudentTrophy] {
		let fetchRequest:NSFetchRequest<StudentTrophy> = NSFetchRequest(entityName: studentTrophyEntityName)
		fetchRequest.predicate = NSPredicate(format: "owner.id == %@", currentStudent!.id)
		var array:[StudentTrophy] = [StudentTrophy]()
		do {
			let studentTrophies = try managedContext.fetch(fetchRequest)
			for (_, item) in studentTrophies.enumerated() {
				array.append(item)
			}
		} catch let error as NSError {
			print("get student trophies requests error: \(error.localizedDescription)")
		}
		array.sort { (trophy1, trophy2) -> Bool in
			var result:Bool = false
			let string1:NSString = trophy1.id as NSString
			let string2:NSString = trophy2.id as NSString
			if (string1.integerValue <= string2.integerValue) {
				result = true
			}
			return result
		}
		return array
	}
	
	//MARK: Login
	
	func completedLogin(_ success:Bool, social:Bool, result:NSDictionary?, results:NSArray?, error:String?, completion:@escaping dataManagerCompletionBlock) {
		var loginSuccessfull = true
		var reason = kDefaultFailureReason
		if (success) {
			if (result != nil) {
				self.currentStudent = Student.insertInManagedObjectContext(managedContext, dictionary: result!)
				if social {
					self.currentStudent?.institution = self.socialInstitution()
				} else if currentUserType() == .demo {
					self.currentStudent?.institution = self.demoInstitution()
				}
				self.safelySaveContext()
				self.getStudentData(completion)
			} else {
				DispatchQueue.main.async { () -> Void in
					LoadingView.hide()
					inheritSilent = false
				}
				loginSuccessfull = false
				completion(loginSuccessfull, reason)
			}
		} else {
			DispatchQueue.main.async { () -> Void in
				LoadingView.hide()
				inheritSilent = false
			}
			loginSuccessfull = false
			if (error != nil) {
				reason = error!
			}
			completion(loginSuccessfull, reason)
		}
	}
	
	func getStudentData(_ completion:@escaping dataManagerCompletionBlock) {
		self.getAppSettings({ (success, failureReason) -> Void in
			self.remakeActivityAndActivityTypes()
			self.getAvailableTrophies({ (success, failureReason) -> Void in
				self.getStudentTrophies({ (success, failureReason) -> Void in
					self.getStudentModules({ (success, failureReason) -> Void in
						self.getStudentActivityLogs({ (success, failureReason) -> Void in
							self.getStudentTargets({ (success, failureReason) -> Void in
								self.getStudentStretchTargets({ (success, failureReason) -> Void in
									self.getStudentFeeds({ (success, failureReason) -> Void in
										self.getStudentMarks({ (success, failureReason) -> Void in
											self.getStudentAssignmentRankings({ (success, failureReason) -> Void in
												self.calculateLastWeekRankings({ (success, failureReason) -> Void in
													self.calculateOverallRankings({ (success, failureReason) -> Void in
														self.getStudentFriendsData({ (success, failureReason) -> Void in
															self.safelySaveContext()
															for (_, item) in self.runningLogs.enumerated() {
																if (item.studentID == self.currentStudent!.id) {
																	let module = self.moduleWithID(item.moduleID)
																	if (module != nil) {
																		let activityType = self.activityTypeWithName(item.activityTypeName)
																		if (activityType != nil) {
																			let activity = self.activityWithName(item.activityName, type: activityType!)
																			if (activity != nil) {
																				let log = ActivityLog.insertInManagedObjectContext(managedContext, dictionary: NSDictionary())
																				log.student = dataManager.currentStudent!
																				log.module = module!
																				log.activityType = activityType!
																				log.activity = activity!
																				log.date = item.date
																				log.timeSpent = item.timeSpent
																				log.note = item.note
																				log.isRunning = item.isRunning
																				log.id = item.id
																				log.isPaused = item.isPaused
																				log.pauseDate = item.pauseDate
																				dataManager.currentStudent!.addActivityLog(log)
																				let timeInterval = getLocalNotificationTime(item.id)
																				if (timeInterval != nil) {
																					let fireDate = item.date.addingTimeInterval(timeInterval!)
																					let result = fireDate.compare(Date())
																					if (result == .orderedDescending) {
																						log.startBreatherNotificationAfter(Int(timeInterval! / 60.0))
																					}
																				}
																			}
																		}
																	}
																}
															}
															self.safelySaveContext()
															self.checkRunningActivitites()
															DispatchQueue.main.async { () -> Void in
																LoadingView.hide()
																inheritSilent = false
															}
															completion(true, "")
														})
													})
												})
											})
										})
									})
								})
							})
						})
					})
				})
			})
		})
	}
	
	func loginStudent(_ instituteID:String, email:String, password:String, completion:@escaping dataManagerCompletionBlock) {
		cleanUserSpecificData()
		inheritSilent = true
		DispatchQueue.main.async { () -> Void in
			LoadingView.show()
		}
		DownloadManager().login(instituteID, email: email, password: password, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
			self.completedLogin(success, social: false, result: result, results: results, error: error, completion: completion)
		})
	}
	
	func loginWithXAPI(_ jwt:String, completion:@escaping dataManagerCompletionBlock) {
		cleanUserSpecificData()
		inheritSilent = true
		DispatchQueue.main.async { () -> Void in
			LoadingView.show()
		}
		DownloadManager().loginWithXAPI(jwt, alertAboutInternet: true) { (success, result, results, error) in
			if (result != nil) {
				dataManager.currentStudent = Student.insertInManagedObjectContext(managedContext, dictionary: result!)
				if (dataManager.pickedInstitution != nil) {
					dataManager.currentStudent?.institution = dataManager.pickedInstitution!
				}
				self.safelySaveContext()
				self.getStudentData(completion)
			} else {
				completion(false, "Something went wrong")
			}
		}
	}
	
	func socialLogin(email:String, name:String, userId:String, completion:@escaping dataManagerCompletionBlock) {
		cleanUserSpecificData()
		inheritSilent = true
		DispatchQueue.main.async { () -> Void in
			LoadingView.show()
		}
		let mgr = DownloadManager()
		mgr.socialLogin(email: email, name: name, userId: userId, alertAboutInternet: true) { (success, result, results, error) in
			if success {
				self.completedLogin(success, social: true, result: result, results: results, error: error, completion: completion)
			} else if mgr.code == .forbidden {
				completion(false, localized("social_login_error"))
				DispatchQueue.main.async { () -> Void in
					LoadingView.hide()
				}
			} else {
				completion(false, localized("an_unknown_error_occured_please_try_again"))
				DispatchQueue.main.async { () -> Void in
					LoadingView.hide()
				}
			}
		}
	}
	
	//MARK: Get App Settings
	
	func getAppSettings(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getAppSettings(self.currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) -> Void in
			if (result != nil) {
				let screenTabString = stringFromDictionary(result!, key: "home_screen")
				if (!screenTabString.isEmpty) {
					let screenTab = screenTabFromString(screenTabString)
					setHomeScreenTab(screenTab)
				}
				let languageString = stringFromDictionary(result!, key: "language")
				if (!languageString.isEmpty) {
					let language = languageFromString(languageString)
					setAppLanguage(language)
				}
			}
			completion(true, "")
		})
	}
	
	//MARK: Get Activity Points
	
//	func getStudentActivityPoints(silent:Bool, completion:dataManagerCompletionBlock) {
//		let mgr = DownloadManager()
//		mgr.silent = silent
//		mgr.getActivityPoints(self.currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) -> Void in
//			self.currentStudent!.lastWeekActivityPoints = 0
//			self.currentStudent!.totalActivityPoints = 0
//			if (success) {
//				if (result != nil) {
//					let lastWeek = result!["last_week_activity_points"]?.integerValue
//					if (lastWeek != nil) {
//						self.currentStudent!.lastWeekActivityPoints = lastWeek!
//					}
//					let total = result!["total_activity_points"]?.integerValue
//					if (total != nil) {
//						self.currentStudent!.totalActivityPoints = total!
//					}
//				}
//			}
//			completion(success: true, failureReason: "")
//		})
//	}
	
	//MARK: Get Modules
	
	func getStudentModules(_ completion:@escaping dataManagerCompletionBlock) {
		if currentUserType() == .social {
			DownloadManager().getSocialModules(studentId: self.currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) in
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
				let key = "add_module"
				let moduleName = "Add Module"
				let dictionary = NSMutableDictionary()
				dictionary[key] = moduleName
				let object = Module.insertInManagedObjectContext(managedContext, dictionary: dictionary)
				self.currentStudent!.addModule(object)
				completion(true, "")
			})
		} else if currentUserType() == .staff {
			let modulesCount = 2
			for i in stride(from: 1, through: modulesCount, by: 1) {
				let key = "DUMMY_\(i)"
				let moduleName = "Dummy Module \(i)"
				let dictionary = NSMutableDictionary()
				dictionary[key] = moduleName
				let object = Module.insertInManagedObjectContext(managedContext, dictionary: dictionary)
				self.currentStudent!.addModule(object)
			}
			completion(true, "")
		} else {
			xAPIManager().getModules { (success, result, results, error) in
				if (success) {
					if (result != nil) {
						if let courses = result!["courses"] as? [NSDictionary] {
							for (_, item) in courses.enumerated() {
								let object = Course.insertInManagedObjectContext(managedContext, dictionary: item)
								object.student = self.currentStudent!
							}
						}
						if let modules = result!["modules"] as? [NSDictionary] {
							for (_, item) in modules.enumerated() {
								//							let object = Module.insertInManagedObjectContext(managedContext, array: array)
								let object = Module.insertInManagedObjectContext(managedContext, dictionary: item)
								self.currentStudent!.addModule(object)
							}
						}
						self.safelySaveContext()
					}
				}
				if (!self.currentStudent!.institution.isLearningAnalytics.boolValue) {
					for (_, item) in self.modules().enumerated() {
						self.deleteObject(item)
					}
					self.safelySaveContext()
					//				var array = [String]()
					//				array.append(localized("no_module"))
					//				array.append("")
					//				let object = Module.insertInManagedObjectContext(managedContext, array: array)
					let object = Module.insertInManagedObjectContext(managedContext, dictionary: ["":localized("no_module")])
					self.currentStudent!.addModule(object)
				}
				var reason = kDefaultFailureReason
				if (error != nil) {
					reason = error!
				}
				completion(success, reason)
			}
		}
//		DownloadManager().getStudentModules(currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
//			if (success) {
//				if (results != nil) {
//					for (_, item) in results!.enumerate() {
//						let dictionary = item as? NSDictionary
//						if (dictionary != nil) {
//							let object = Module.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
//							self.currentStudent!.addModule(object)
//						}
//					}
//					self.safelySaveContext()
//				}
//			}
//			if (!self.currentStudent!.institution.isLearningAnalytics.boolValue) {
//				for (_, item) in self.modules().enumerate() {
//					self.deleteObject(item)
//				}
//				self.safelySaveContext()
//				var dictionary = [String:String]()
//				dictionary["module_id"] = ""
//				dictionary["module_name"] = localized("no_module")
//				let object = Module.insertInManagedObjectContext(managedContext, dictionary: dictionary)
//				self.currentStudent!.addModule(object)
//			}
//			var reason = kDefaultFailureReason
//			if (error != nil) {
//				reason = error!
//			}
//			completion(success: success, failureReason:reason)
//		}
	}
	
	//MARK: Manage Activity Logs
	
	func getStudentActivityLogs(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getStudentActivityLogs(currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
			if (success) {
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary = item as? NSDictionary
						if (dictionary != nil) {
							let object = ActivityLog.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
							let activityTypeName = stringFromDictionary(dictionary!, key: "activity_type")
							let activityType = self.activityTypeWithName(activityTypeName)
							var activitiesOk = false
							if (activityType != nil) {
								let activityName = stringFromDictionary(dictionary!, key: "activity")
								let activity = self.activityWithName(activityName, type: activityType!)
								if (activity != nil) {
									object.activityType = activityType!
									object.activity = activity!
									activitiesOk = true
								}
							}
							var moduleOk = false
//							let module = self.moduleWithID(stringFromDictionary(dictionary!, key: "module_id"))
							let module = self.moduleWithID(stringFromDictionary(dictionary!, key: "module"))
							if (module != nil) {
								object.module = module!
								moduleOk = true
							}
							moduleOk = true
							let allOk = activitiesOk && moduleOk
							if (allOk) {
								object.student = self.currentStudent!
								self.currentStudent!.addActivityLog(object)
							} else {
								managedContext.delete(object)
							}
						}
					}
					self.safelySaveContext()
				}
			}
			var reason = kDefaultFailureReason
			if (error != nil) {
				reason = error!
			}
			completion(success, reason)
		}
	}
	
	func silentActivityLogsRefresh(_ completion:@escaping dataManagerCompletionBlock) {
		let mgr = DownloadManager()
		mgr.silent = true
		mgr.getStudentActivityLogs(currentStudent!.id, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if (success) {
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary = item as? NSDictionary
						if (dictionary != nil) {
							let object = ActivityLog.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
							let activityTypeName = stringFromDictionary(dictionary!, key: "activity_type")
							let activityType = self.activityTypeWithName(activityTypeName)
							var activitiesOk = false
							if (activityType != nil) {
								let activityName = stringFromDictionary(dictionary!, key: "activity")
								let activity = self.activityWithName(activityName, type: activityType!)
								if (activity != nil) {
									object.activityType = activityType!
									object.activity = activity!
									activitiesOk = true
								}
							}
							var moduleOk = false
//							let module = self.moduleWithID(stringFromDictionary(dictionary!, key: "module_id"))
							let module = self.moduleWithID(stringFromDictionary(dictionary!, key: "module"))
							if (module != nil) {
								object.module = module!
								moduleOk = true
							}
							moduleOk = true
							let allOk = activitiesOk && moduleOk
							if (allOk) {
								object.student = self.currentStudent!
								self.currentStudent!.addActivityLog(object)
							} else {
								managedContext.delete(object)
							}
						}
					}
					self.safelySaveContext()
				}
			}
			var reason = kDefaultFailureReason
			if (error != nil) {
				reason = error!
			}
			completion(success, reason)
		}
	}
	
	func refreshStudentActivityLogs(_ success:Bool, error:String?, completion:@escaping dataManagerCompletionBlock) {
		if (success) {
			getStudentActivityLogs(completion)
		} else {
			var reason = kDefaultFailureReason
			if (error != nil) {
				reason = error!
			}
			completion(false, reason)
		}
	}
	
	func addActivityLog(_ activityLog:ActivityLog, completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().addActivityLog(activityLog, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
			if (success) {
				self.getStudentTrophies({ (success, failureReason) -> Void in
					self.refreshStudentActivityLogs(success, error: error, completion: completion)
				})
			} else {
				if (error != nil) {
					completion(false, error!)
				} else {
					completion(false, kDefaultFailureReason)
				}
			}
		})
	}
	
	func editActivityLog(_ activityLog:ActivityLog, completion:@escaping dataManagerCompletionBlock) {
		let logID = activityLog.id
		let activityDate = activityLog.date
		let timeSpent = activityLog.timeSpent
		let note = activityLog.note
		DownloadManager().editActivityLog(logID, activityDate: activityDate, timeSpentInMinutes: Int(timeSpent), note: note, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
			if (success) {
				self.getStudentTrophies({ (success, failureReason) -> Void in
					self.refreshStudentActivityLogs(success, error: error, completion: completion)
				})
			} else {
				if (error != nil) {
					completion(false, error!)
				} else {
					completion(false, kDefaultFailureReason)
				}
			}
		})
	}
	
	func deleteActivityLog(_ activityLog:ActivityLog, completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().deleteActivityLog(activityLog.id, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
			self.refreshStudentActivityLogs(success, error: error, completion: completion)
		})
	}
	
	//MARK: Manage Targets
	
	func getStudentTargets(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getTargets(currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
			if (success) {
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary = item as? NSDictionary
						if (dictionary != nil) {
							let object = Target.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
							let activityTypeName = stringFromDictionary(dictionary!, key: "activity_type")
							let activityType = self.activityTypeWithName(activityTypeName)
							var activitiesOk = false
							if (activityType != nil) {
								let activityName = stringFromDictionary(dictionary!, key: "activity")
								let activity = self.activityWithName(activityName, type: activityType!)
								if (activity != nil) {
									object.activityType = activityType!
									object.activity = activity!
									activitiesOk = true
								}
							}
//							let module = self.moduleWithID(stringFromDictionary(dictionary!, key: "module_id"))
							let module = self.moduleWithID(stringFromDictionary(dictionary!, key: "module"))
							if (module != nil) {
								object.module = module!
							}
							let allOk = activitiesOk
							if (allOk) {
								object.student = self.currentStudent!
								self.currentStudent!.addTarget(object)
							} else {
								managedContext.delete(object)
							}
						}
					}
					self.safelySaveContext()
				}
			}
			var reason = kDefaultFailureReason
			if (error != nil) {
				reason = error!
			}
			completion(success, reason)
		}
	}
	
	func refreshStudentTargets(_ success:Bool, error:String?, completion:@escaping dataManagerCompletionBlock) {
//		if (success) {
			getStudentTargets(completion)
//		} else {
//			var reason = kDefaultFailureReason
//			if (error != nil) {
//				reason = error!
//			}
//			completion(success: false, failureReason:reason)
//		}
	}
	
	func addTarget(_ target:Target, completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().addTarget(currentStudent!.id, target: target, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if success {
				self.refreshStudentTargets(success, error: error, completion: completion)
			} else {
				var failureReason = kDefaultFailureReason
				if error != nil {
					failureReason = error!
				}
				AlertView.showAlert(false, message: failureReason, completion: nil)
			}
		}
	}
	
	func editTarget(_ target:Target, completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().editTarget(target, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if success {
				self.refreshStudentTargets(success, error: error, completion: completion)
			} else {
				var failureReason = kDefaultFailureReason
				if error != nil {
					failureReason = error!
				}
				AlertView.showAlert(false, message: failureReason, completion: nil)
			}
		}
	}
	
	func deleteTarget(_ target:Target, completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().deleteTarget(target.id, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
			if success {
				self.refreshStudentTargets(success, error: error, completion: completion)
			} else {
				var failureReason = kDefaultFailureReason
				if error != nil {
					failureReason = error!
				}
				AlertView.showAlert(false, message: failureReason, completion: nil)
			}
		})
	}
	
	//MARK: Manage Stretch Targets
	
	func getStudentStretchTargets(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getStretchTargets(currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
			if (success) {
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary = item as? NSDictionary
						if (dictionary != nil) {
							let object = StretchTarget.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
							let fetchRequest:NSFetchRequest<Target> = NSFetchRequest(entityName: targetEntityName)
							let targetID = stringFromDictionary(dictionary!, key: "target_id")
							let studentID = stringFromDictionary(dictionary!, key: "student_id")
							fetchRequest.predicate = NSPredicate(format: "id == %@ AND student.id == %@", targetID, studentID)
							var target:Target?
							var targetOk = false
							do {
								try target = managedContext.fetch(fetchRequest).first
								if (target != nil) {
									targetOk = true
									object.target = target!
								}
							} catch let error as NSError {
								print("get target of stretch target failed: \(error.localizedDescription)")
							}
							if (targetOk) {
								object.student = self.currentStudent!
								self.currentStudent!.addStretchTarget(object)
							} else {
								managedContext.delete(object)
							}
						}
					}
					self.safelySaveContext()
				}
			}
			var reason = kDefaultFailureReason
			if (error != nil) {
				reason = error!
			}
			completion(success, reason)
		}
	}
	
	func refreshStudentStretchTargets(_ success:Bool, error:String?, completion:@escaping dataManagerCompletionBlock) {
		if (success) {
			getStudentStretchTargets(completion)
		} else {
			var reason = kDefaultFailureReason
			if (error != nil) {
				reason = error!
			}
			completion(false, reason)
		}
	}
	
	func addStretchTarget(_ targetID:String, minutes:Int, completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().addStretchTarget(targetID, stretchTimeInMinutes: minutes, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if success {
				self.refreshStudentStretchTargets(success, error: error, completion: completion)
			} else {
				var failureReason = kDefaultFailureReason
				if error != nil {
					failureReason = error!
				}
				AlertView.showAlert(false, message: failureReason, completion: nil)
			}
		}
	}
	
	func editStretchTarget(_ stretchTargetID:String, minutes:Int, completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().editStretchTarget(stretchTargetID, stretchTimeInMinutes: minutes, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if success {
				self.refreshStudentStretchTargets(success, error: error, completion: completion)
			} else {
				var failureReason = kDefaultFailureReason
				if error != nil {
					failureReason = error!
				}
				AlertView.showAlert(false, message: failureReason, completion: nil)
			}
		}
	}
	
	func deleteStretchTarget(_ stretchTargetID:String, completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().deleteStretchTarget(stretchTargetID, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if success {
				self.refreshStudentStretchTargets(success, error: error, completion: completion)
			} else {
				var failureReason = kDefaultFailureReason
				if error != nil {
					failureReason = error!
				}
				AlertView.showAlert(false, message: failureReason, completion: nil)
			}
		}
	}
	
	//MARK: Manage Friends
	
	func getStudentFriendsData(_ completion:@escaping dataManagerCompletionBlock) {
		getStudentsInTheSameCourse(completion)
	}
	
	fileprivate func getStudentsInTheSameCourse(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getStudentsInTheSameCourse(dataManager.currentStudent!.id, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if (success) {
				let array = self.studentsInTheSameCourse()
				for (_, item) in array.enumerated() {
					self.deleteObject(item)
				}
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary:NSDictionary? = item as? NSDictionary
						if (dictionary != nil) {
							let object = Colleague.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
							self.currentStudent!.addStudentInTheSameCourse(object)
						}
					}
					self.safelySaveContext()
				}
			}
			self.getFriendRequests(completion)
		}
	}
	
	fileprivate func getFriendRequests(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getFriendRequests(dataManager.currentStudent!.id, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if (success) {
				let array = self.friendRequests()
				for (_, item) in array.enumerated() {
					self.deleteObject(item)
				}
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary:NSDictionary? = item as? NSDictionary
						if (dictionary != nil) {
							let object = FriendRequest.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
							self.currentStudent!.addFriendRequest(object)
						}
					}
					self.safelySaveContext()
				}
			}
			self.getFriends(completion)
		}
	}
	
	fileprivate func getFriends(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getFriendsList(currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) -> Void in
			if (success) {
				let array = self.friends()
				for (_, item) in array.enumerated() {
					self.deleteObject(item)
				}
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary:NSDictionary? = item as? NSDictionary
						if (dictionary != nil) {
							let object = Friend.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
							self.currentStudent!.addFriend(object)
						}
					}
					self.safelySaveContext()
				}
			}
			self.getSentFriendRequests(completion)
		})
	}
	
	fileprivate func getSentFriendRequests(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().listSentFriendRequests(currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
			if (success) {
				let array = self.sentFriendRequests()
				for (_, item) in array.enumerated() {
					self.deleteObject(item)
				}
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary:NSDictionary? = item as? NSDictionary
						if (dictionary != nil) {
							let object = SentFriendRequest.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
							self.currentStudent!.addSentFriendRequest(object)
						}
					}
					self.safelySaveContext()
				}
			}
			var failureReason = kDefaultFailureReason
			if (error != nil) {
				failureReason = error!
			}
			completion(success, failureReason)
		}
	}
	
	//MARK: Feeds
	
	func silentStudentFeedsRefresh(_ alertAboutInternet:Bool, completion:@escaping dataManagerCompletionBlock) {
		let downloadManager = DownloadManager()
		downloadManager.silent = true
		downloadManager.getFeeds(currentStudent!.id, alertAboutInternet: alertAboutInternet) { (success, result, results, error) -> Void in
			if (success) {
				let array = self.myFeeds()
				for (_, item) in array.enumerated() {
					managedContext.delete(item)
				}
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary:NSDictionary? = item as? NSDictionary
						if (dictionary != nil) {
							_ = Feed.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
						}
					}
				}
				self.safelySaveContext()
			}
			var failureReason = kDefaultFailureReason
			if (error != nil) {
				failureReason = error!
			}
			self.getPushNotifications(failureReason: failureReason, completion: completion)
		}
	}
	
	func getStudentFeeds(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getFeeds(currentStudent!.id, alertAboutInternet: true) { (success, result, results, error) -> Void in
			if (success) {
				let array = self.myFeeds()
				for (_, item) in array.enumerated() {
					managedContext.delete(item)
				}
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						let dictionary:NSDictionary? = item as? NSDictionary
						if (dictionary != nil) {
							_ = Feed.insertInManagedObjectContext(managedContext, dictionary: dictionary!)
						}
					}
				}
				self.safelySaveContext()
			}
			var failureReason = kDefaultFailureReason
			if (error != nil) {
				failureReason = error!
			}
			self.getPushNotifications(failureReason: failureReason, completion: completion)
		}
	}
	
	func getPushNotifications(failureReason:String, completion:@escaping dataManagerCompletionBlock) {
		if let studentId = dataManager.currentStudent?.id {
			let downloadManager = DownloadManager()
			downloadManager.silent = true
			downloadManager.getPushNotifications(studentdId: studentId, alertAboutInternet: false, completion: { (success, dictionary, array, error) in
				if let array = array as? [NSDictionary] {
					for (_, item) in array.enumerated() {
						if let read = item["is_read"] as? String {
							if read == "0" {
								let dictionary = NSMutableDictionary()
								dictionary["created_date"] = stringFromDictionary(item, key: "created")
								dictionary["id"] = stringFromDictionary(item, key: "id")
								dictionary["message_from"] = stringFromDictionary(item, key: "message_from")
								dictionary["message"] = stringFromDictionary(item, key: "message")
								dictionary["activity_type"] = "temp_push_notification"
								_ = Feed.insertInManagedObjectContext(managedContext, dictionary: dictionary)
							}
						}
					}
				}
				completion(success, failureReason)
			})
		} else {
			completion(false, failureReason)
		}
	}
	
	
	//MARK: Marks
	
	func getStudentMarks(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getMarksObtainedByStudent(currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
			if (success) {
				let array = self.myMarks()
				for (_, item) in array.enumerated() {
					self.deleteObject(item)
				}
				if (result != nil) {
					let keys = result!.allKeys
					for (_, moduleID) in keys.enumerated() {
						let result2 = result!.object(forKey: moduleID) as? NSDictionary
						if (result2 != nil) {
							let keys2 = result2!.allKeys
							for (_, moduleID2) in keys2.enumerated() {
								let result3 = result2!.object(forKey: moduleID2) as? NSDictionary
								if (result3 != nil) {
									let keys3 = result3!.allKeys
									for (_, markName) in keys3.enumerated() {
										let studentID = self.currentStudent!.id
//										let name = "\(moduleID2)_\(markName)"
										let name = "\(markName)"
										let object = Mark.insertInManagedObjectContext(managedContext, studentID: studentID, moduleID: "\(moduleID)", markName: name)
										self.currentStudent!.addMark(object)
										object.student = self.currentStudent!
										if let marks = result3!.object(forKey: markName) as? [NSNumber] {
											for (_, value) in marks.enumerated() {
												let valueInt = value.intValue
												let vObject = MarkValue.insertInManagedObjectContext(managedContext, mark: object, markValue: valueInt)
												vObject.mark = object
												object.addValue(vObject)
											}
										} else if let marks = result3!.object(forKey: markName) as? [String] {
											for (_, value) in marks.enumerated() {
												let valueInt = (value as NSString).integerValue
												let vObject = MarkValue.insertInManagedObjectContext(managedContext, mark: object, markValue: valueInt)
												vObject.mark = object
												object.addValue(vObject)
											}
										}
									}
								}
							}
						}
					}
				}
			}
			var failureReason = kDefaultFailureReason
			if (error != nil) {
				failureReason = error!
			}
			completion(success, failureReason)
		}
	}
	
	//MARK: Rankings
	
	func calculateLastWeekRankings(_ completion:@escaping dataManagerCompletionBlock) {
		studentLastWeekRankings.removeAll()
		DownloadManager().getCurentWeekRanking(self.currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) -> Void in
			if (success) {
				if (result != nil) {
					let lastWeekPoints = result!["last_week_points"] as? NSDictionary
					if (lastWeekPoints != nil) {
						let total = lastWeekPoints!["total"] as? NSDictionary
						if (total != nil) {
							self.studentLastWeekRankings = self.generateRankings(total!.allValues as NSArray)
						}
					}
				}
			}
			completion(true, "")
		})
	}
	
	func calculateOverallRankings(_ completion:@escaping dataManagerCompletionBlock) {
		studentOverallRankings.removeAll()
		DownloadManager().getOverallRanking(self.currentStudent!.id, alertAboutInternet: false, completion: { (success, result, results, error) -> Void in
			if (success) {
				if (result != nil) {
					let lastWeekPoints = result!["overall_points_till_date"] as? NSDictionary
					if (lastWeekPoints != nil) {
						let total = lastWeekPoints!["total"] as? NSDictionary
						if (total != nil) {
							self.studentOverallRankings = self.generateRankings(total!.allValues as NSArray)
						}
					}
				}
			}
			completion(true, "")
		})
	}
	
	func generateRankings(_ values:NSArray) -> [Int:Int] {
		var dictionary = [Int:Int]()
		let intValues:[Int]? = values as? [Int]
		if (intValues != nil) {
			let ordered = intValues!.sorted()
			let N:Double = (Double)(ordered.count)
			for (_, item) in ordered.enumerated() {
				var CL:Double = 0.0
				var FI:Double = 0.0
				for (_, otherItem) in ordered.enumerated() {
					if (otherItem < item) {
						CL += 1.0
					} else if (otherItem == item) {
						FI += 1.0
					}
				}
				
				let existing = dictionary[item]
				if (existing == nil) {
					let value = ((CL + 0.5 * FI) / N) * 100.0
					dictionary[item] = 100 - (Int)(value)
				}
			}
		}
		return dictionary
		
//		var sum = 0
//		var dictionary = [Int:Int]()
//		for (_, item) in values.enumerate() {
//			let integer = item.integerValue
//			if (integer != nil) {
//				let existing = dictionary[integer!]
//				if (existing == nil) {
//					sum += integer
//					dictionary[integer!] = 0
//				}
//			}
//		}
//		
//		let ordered = dictionary.keys.sort().reverse()
//		
//		for (index, item) in ordered.enumerate() {
//			dictionary[item] = (((index + 1) * 100) / (dictionary.count))
//		}
//		
//		return dictionary
	}
	
	func getStudentAssignmentRankings(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getAssignmentRanking(currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
			if (success) {
				if (result != nil) {
					self.myAssignmentRankings.removeAll()
					let keys = result!.allKeys
					for (_, moduleID) in keys.enumerated() {
						let result2 = result!.object(forKey: moduleID) as? NSDictionary
						if (result2 != nil) {
							let keys2 = result2!.allKeys
							for (_, moduleID2) in keys2.enumerated() {
								let result3 = result2!.object(forKey: moduleID2) as? NSDictionary
								if (result3 != nil) {
									let keys3 = result3!.allKeys
									for (_, assignmentName) in keys3.enumerated() {
										let result4 = result3!.object(forKey: assignmentName) as? NSDictionary
										if (result4 != nil) {
											let keys4 = result4!.allKeys
											var myGrade:Int = 0
											var allGrades:[Int] = [Int]()
											for (_, studentID) in keys4.enumerated() {
												if let array = result4!.object(forKey: studentID) as? [NSNumber] {
													if let currentGrade = array.first?.intValue {
														allGrades.append(currentGrade)
														if let stringID = studentID as? String {
															if (stringID == self.currentStudent!.id) {
																myGrade = currentGrade
															}
														}
													}
												} else if let array = result4!.object(forKey: studentID) as? [String] {
													if let string = array.first {
														let currentGrade = (string as NSString).integerValue
														allGrades.append(currentGrade)
														if let stringID = studentID as? String {
															if (stringID == self.currentStudent!.id) {
																myGrade = currentGrade
															}
														}
													}
												}
											}
											let rankings = self.generateRankings(allGrades as NSArray)
											let myRank = rankings[myGrade]
											if (myRank != nil) {
												var myRanking:(name:String, rank:Int)
//												myRanking.name = "\(moduleID2)_\(assignmentName)"
												myRanking.name = "\(assignmentName)"
												myRanking.rank = myRank!
												self.myAssignmentRankings.append(myRanking)
											}
										}
									}
								}
							}
						}
					}
				}
			}
			completion(true, "")
		}
	}
	
	//MARK: Trophies
	
	func getAvailableTrophies(_ completion:@escaping dataManagerCompletionBlock) {
		DownloadManager().getTrophies(false) { (success, result, results, error) -> Void in
			if (success) {
				let array = self.availableTrophies()
				for (_, item) in array.enumerated() {
					managedContext.delete(item)
				}
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						if let dictionary = item as? NSDictionary {
							_ = Trophy.insertInManagedObjectContext(managedContext, dictionary: dictionary)
						}
					}
				}
			}
			self.safelySaveContext()
			completion(success, "")
		}
	}
	
	var firstTrophyCheck = true
	
	func getStudentTrophies(_ completion:@escaping dataManagerCompletionBlock) {
		let array = myTrophies()
		var oldTrophies:[(id:String, total:Int, trophy:Trophy)] = [(id:String, total:Int, trophy:Trophy)]()
		for (_, item) in array.enumerated() {
			let oneItem:(id:String, total:Int, trophy:Trophy)
			oneItem.id = item.id
			oneItem.total = item.total.intValue
			oneItem.trophy = item.trophy
			oldTrophies.append(oneItem)
		}
		let mgr = DownloadManager()
		mgr.silent = true
		mgr.getStudentTrophies(currentStudent!.id, alertAboutInternet: false) { (success, result, results, error) -> Void in
			if (success) {
				let array = self.myTrophies()
				for (_, item) in array.enumerated() {
					managedContext.delete(item)
				}
				if (results != nil) {
					for (_, item) in results!.enumerated() {
						if let dictionary = item as? NSDictionary {
							let ID = stringFromDictionary(dictionary, key: "id")
							let total = intFromDictionary(dictionary, key: "total")
							_ = StudentTrophy.insertInManagedObjectContext(managedContext, ID: ID, trophyTotal: total, studentID: self.currentStudent!.id)
						}
					}
					if (!self.firstTrophyCheck) {
						let currentTrophies = self.myTrophies()
						for (_, currentTrophy) in currentTrophies.enumerated() {
							var found:Bool = false
							for (_, oldTrophy) in oldTrophies.enumerated() {
								if (oldTrophy.id == currentTrophy.id && oldTrophy.total == currentTrophy.total.intValue) {
									found = true
									break
								}
							}
							if (!found) {
								NewTrophyAlert.showNewTrophy(currentTrophy.trophy)
							}
						}
					}
					self.firstTrophyCheck = false
				}
			}
			self.safelySaveContext()
			completion(success, "")
		}
	}
	
	//MARK: Core Data
	
	func safelySaveContext() {
		do {
			try managedContext.save()
			if (LOG_ACTIVITY) {
				print("Context saved successfully.")
			}
		} catch let error as NSError {
			print("\n\nContext save error: \(error.localizedDescription).")
			let errors = error.userInfo[NSDetailedErrorsKey] as? [AnyObject]
			if (errors != nil) {
				print("Details:")
				for (_, item) in errors!.enumerated() {
					let oneError = item as? NSError
					if (oneError != nil) {
						print(oneError!.userInfo)
					}
				}
				print("\n\n")
			} else {
				print("User Info:")
				print(error.userInfo)
				print("\n\n")
			}
		}
	}
}
