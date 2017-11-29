//
//  ActivityType.swift
//  Jisc
//
//  Created by Therapy Box on 11/10/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let activityTypeEntityName = "ActivityType"

let kActivitiesKey = "activities"

class ActivityType: NSManagedObject {
    
    func setTypeName(_ typeName:String, english: String) {
        englishName = english
        name = typeName
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, name:String, english: String) -> ActivityType {
        let fetchRequest:NSFetchRequest<ActivityType> = NSFetchRequest(entityName: activityTypeEntityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        var activityType:ActivityType?
        do {
            try activityType = managedContext.fetch(fetchRequest).first
            if (activityType == nil) {
                activityType = ActivityType.newActivityType(name, english: english)
            } else {
                activityType!.setTypeName(name, english: english)
            }
        } catch {
            activityType = ActivityType.newActivityType(name, english: english)
        }
        return activityType!
    }
    
    fileprivate class func newActivityType(_ name:String, english: String) -> ActivityType {
        let entity = NSEntityDescription.entity(forEntityName: activityTypeEntityName, in:managedContext)
        let activityType:ActivityType = NSManagedObject(entity: entity!, insertInto: managedContext) as! ActivityType
        activityType.setTypeName(name, english: english)
        return activityType
    }
    
    //MARK: Activities
    
    func addActivities(_ array:[Activity]) {
        let activities = self.mutableSetValue(forKey: kActivitiesKey)
        activities.addObjects(from: array)
    }
}
