//
//  StretchTarget.swift
//  Jisc
//
//  Created by Therapy Box on 11/17/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let stretchTargetEntityName = "StretchTarget"

class StretchTarget: NSManagedObject {
    
    func loadDictionary(_ dictionary:NSDictionary) {
        id = stringFromDictionary(dictionary, key:"id")
        createdDate = dateFromDictionary(dictionary, key:"created_date", format: "yyyy-MM-dd HH:mm:ss")
        status = intFromDictionary(dictionary, key:"status") as NSNumber
        stretchTime = intFromDictionary(dictionary, key:"stretch_time") as NSNumber
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> StretchTarget {
        let fetchRequest:NSFetchRequest<StretchTarget> = NSFetchRequest(entityName: stretchTargetEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var stretchTarget:StretchTarget?
        do {
            try stretchTarget = managedContext.fetch(fetchRequest).first
            if (stretchTarget == nil) {
                stretchTarget = StretchTarget.newStretchTarget(dictionary)
            } else {
                stretchTarget!.loadDictionary(dictionary)
            }
        } catch {
            stretchTarget = StretchTarget.newStretchTarget(dictionary)
        }
        return stretchTarget!
    }
    
    fileprivate class func newStretchTarget(_ dictionary:NSDictionary) -> StretchTarget {
        let entity = NSEntityDescription.entity(forEntityName: stretchTargetEntityName, in:managedContext)
        let stretchTarget:StretchTarget = NSManagedObject(entity: entity!, insertInto: managedContext) as! StretchTarget
        stretchTarget.loadDictionary(dictionary)
        return stretchTarget
    }
    
    func calculateProgress() -> Double {
        let progress = target.calculateProgress(false)
        let overflowCompletion = (progress.completionPercentage - 1.0) * target.totalTime.doubleValue
        let completion = overflowCompletion / stretchTime.doubleValue
        return completion
    }
    
    func displayText() -> String {
        var time = "\(stretchTime.intValue) \(localized("minutes"))"
        if (stretchTime.intValue >= 60) {
            if (stretchTime.intValue % 60 != 0) {
                time = "\(stretchTime.intValue / 60) \(localized("hours")) \(localized("and")) \(stretchTime.intValue % 60) \(localized("minutes"))"
                if (stretchTime.intValue / 60 == 1) {
                    time = "\(stretchTime.intValue / 60) \(localized("hour")) \(localized("and")) \(stretchTime.intValue % 60) \(localized("minutes"))"
                }
            } else {
                time = "\(stretchTime.intValue / 60) \(localized("hours"))"
                if (stretchTime.intValue / 60 == 1) {
                    time = "\(stretchTime.intValue / 60) \(localized("hour"))"
                }
            }
        }
        var startAndEndDays:(startDate:Date, endDate:Date) = (Date(timeIntervalSince1970: 0.0), Date(timeIntervalSince1970: 0.0))
        let activityString = target.activity.present
        var displayText = "\(activityString.capitalized) for another \(time) to meet your stretch target"
        if let timeSpan = kTargetTimeSpan(rawValue: target.timeSpan) {
            switch (timeSpan) {
            case .Daily:
                break
            case .Weekly:
                startAndEndDays = target.startAndEndDatesForWeekly()
                break
            case .Monthly:
                startAndEndDays = target.startAndEndDatesForMonthly()
                break
            }
            let interval = Int(startAndEndDays.endDate.timeIntervalSinceNow)
            let days = interval / 86400
            let hours = interval / 3600
            let minutes = interval / 60
            if (days > 0) {
                displayText = "\(activityString.capitalized) for another \(time) in the next \(days) days to meet your stretch target"
            } else if (hours > 0) {
                displayText = "\(activityString.capitalized) for another \(time) in the next \(hours) hours to meet your stretch target"
            } else if (minutes > 0) {
                displayText = "\(activityString.capitalized) for another \(time) in the next \(minutes) minutes to meet your stretch target"
            }
        }
        return displayText
    }
}
