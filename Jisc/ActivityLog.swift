//
//  ActivityLog.swift
//  Jisc
//
//  Created by Therapy Box on 11/10/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import Foundation
import CoreData

let activityLogEntityName = "ActivityLog"

class ActivityLog: NSManagedObject {
    
    func loadDictionary(_ dictionary:NSDictionary) {
        id = stringFromDictionary(dictionary, key: "id")
        date = dateFromDictionary(dictionary, key: "activity_date", format: "yyyy-MM-dd")
        createdDate = dateFromDictionary(dictionary, key: "created_date", format: "yyyy-MM-dd HH:mm:ss")
        modifiedDate = dateFromDictionary(dictionary, key: "modified_date", format: "yyyy-MM-dd HH:mm:ss")
        timeSpent = intFromDictionary(dictionary, key: "time_spent") as NSNumber
        note = stringFromDictionary(dictionary, key: "note")
        isRunning = false
        isPaused = false
        pauseDate = Date(timeIntervalSince1970: 0)
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> ActivityLog {
        let fetchRequest:NSFetchRequest<ActivityLog> = NSFetchRequest(entityName:activityLogEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var activityLog:ActivityLog?
        do {
            try activityLog = managedContext.fetch(fetchRequest).first as ActivityLog?
            if (activityLog == nil) {
                activityLog = ActivityLog.newActivityLog(dictionary)
            } else {
                activityLog!.loadDictionary(dictionary)
            }
        } catch {
            activityLog = ActivityLog.newActivityLog(dictionary)
        }
        return activityLog!
    }
    
    fileprivate class func newActivityLog(_ dictionary:NSDictionary) -> ActivityLog {
        let entity = NSEntityDescription.entity(forEntityName: activityLogEntityName, in:managedContext)
        let activityLog:ActivityLog = NSManagedObject(entity: entity!, insertInto: managedContext) as! ActivityLog
        activityLog.loadDictionary(dictionary)
        return activityLog
    }
    
    func dictionaryRepresentation() -> [String:String] {
        var dictionary:[String:String] = [String:String]()
        dictionary["student_id"] = student.id
        if (module != nil) {
            //			dictionary["module_id"] = module!.id
            dictionary["module"] = module!.id
        }
        //		dictionary["activity_type"] = activityType.name
        //		dictionary["activity"] = activity.name
        dictionary["activity_type"] = activityType.englishName
        dictionary["activity"] = activity.englishName
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dictionary["activity_date"] = dateFormatter.string(from: date)
        dictionary["time_spent"] = "\(timeSpent)"
        if (!note.isEmpty) {
            dictionary["note"] = note
        }
        if (!id.isEmpty && !isRunning.boolValue) {
            dictionary["log_id"] = id
        }
        return dictionary
    }
    
    func hoursSpent() -> Int {
        let hours = Int(timeSpent) / 60
        return hours
    }
    
    func textForDisplay() -> String {
        let verb = activity.past
        if (isRunning.boolValue) {
            timeSpent = Int(abs(date.timeIntervalSinceNow) / 60) as NSNumber
        }
        var string = ""
        if (module != nil) {
            string = "\(verb) for \(ActivityLog.timeSpentForDisplay(Int(timeSpent))) for \(module!.name) Module"
        } else {
            string = "\(verb) for \(ActivityLog.timeSpentForDisplay(Int(timeSpent)))"
        }
        return string
    }
    
    class func timeSpentForDisplay(_ minutes:Int) -> String {
        let hours = minutes / 60
        let minutes = minutes - (hours * 60)
        var hourString = localized("hours")
        if (hours == 1) {
            hourString = localized("hour")
        }
        var minuteString = localized("minutes")
        if (minutes == 1) {
            minuteString = localized("minute")
        }
        var timeSpent = "\(hours) \(hourString) \(minutes) \(minuteString)"
        if (hours == 0) {
            timeSpent = "\(minutes) \(minuteString)"
        } else if (minutes == 0) {
            timeSpent = "\(hours) \(hourString)"
        }
        return timeSpent
    }
    
    func startBreatherNotificationAfter(_ minutes:Int) {
        let fireDate = date.addingTimeInterval(Double(minutes * 60))
        if (fireDate.compare(Date()) == .orderedDescending) {
            let breatherNotification = UILocalNotification()
            breatherNotification.fireDate = date.addingTimeInterval(Double(minutes * 60)) as Date
            var string = ""
            if (module != nil) {
                string = "You have \(activity.past.lowercased()) for \(minutes) minutes for \(module!.name) Module. Time for a break"
            } else {
                string = "You have \(activity.past.lowercased()) for \(minutes) minutes. Time for a break"
            }
            breatherNotification.alertBody = string
            saveLocalNotification(breatherNotification, notificationID: id, time: Double(minutes * 60))
            UIApplication.shared.scheduleLocalNotification(breatherNotification)
        }
    }
}

class RunningLogContainer: NSObject {
    
    var createdDate: Date
    var date: Date
    var id: String
    var isPaused: NSNumber
    var isRunning: NSNumber
    var modifiedDate: Date
    var note: String
    var pauseDate: Date
    var timeSpent: NSNumber
    var activityName: String
    var activityTypeName: String
    var moduleID: String
    var studentID: String
    
    required init(log:ActivityLog) {
        createdDate = log.createdDate as Date
        date = log.date as Date
        id = log.id
        isPaused = log.isPaused
        isRunning = log.isRunning
        modifiedDate = log.modifiedDate as Date
        note = log.note
        pauseDate = log.pauseDate as Date
        timeSpent = log.timeSpent
        activityName = log.activity.name
        activityTypeName = log.activityType.name
        if (log.module != nil) {
            moduleID = log.module!.id
        } else {
            moduleID = ""
        }
        studentID = log.student.id
    }
    
}
