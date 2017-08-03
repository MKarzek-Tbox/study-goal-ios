//
//  Activity.swift
//  Jisc
//
//  Created by Therapy Box on 11/10/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let activityEntityName = "Activity"

class Activity: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

	func load(_ activityID:String, activityName:String, presentTense:String, pastTense:String, english:String) {
		id = activityID
		englishName = english
		name = activityName
		present = presentTense
		past = pastTense
	}
	
	class func insertInManagedObjectContext(_ model:(context:NSManagedObjectContext, id:String, name:String, present:String, past:String, english:String)) -> Activity {
		let fetchRequest:NSFetchRequest<Activity> = NSFetchRequest(entityName: activityEntityName)
		fetchRequest.predicate = NSPredicate(format: "id == %@", model.id)
		var activity:Activity?
		do {
			try activity = managedContext.fetch(fetchRequest).first
			if (activity == nil) {
				activity = Activity.newActivity(model.id, name:model.name, present: model.present, past: model.past, english: model.english)
			} else {
				activity!.load(model.id, activityName:model.name, presentTense: model.present, pastTense: model.past, english: model.english)
			}
		} catch {
			activity = Activity.newActivity(model.id, name:model.name, present: model.present, past: model.past, english: model.english)
		}
		return activity!
	}
	
	fileprivate class func newActivity(_ id:String, name:String, present:String, past:String, english:String) -> Activity {
		let entity = NSEntityDescription.entity(forEntityName: activityEntityName, in:managedContext)
		let activity:Activity = NSManagedObject(entity: entity!, insertInto: managedContext) as! Activity
		activity.load(id, activityName:name, presentTense: present, pastTense: past, english: english)
		return activity
	}
	
	func iconName(big:Bool) -> String {
		var iconName = ""
		if (big) {
			iconName = "activity_icon_big_\(id)"
		} else {
			iconName = "activity_icon_\(id)"
		}
		return iconName
	}
}
