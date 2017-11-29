//
//  Target.swift
//  Jisc
//
//  Created by Therapy Box on 11/10/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


let targetEntityName = "Target"

enum kTargetTimeSpan:String {
    case Daily = "Daily"
    case Weekly = "Weekly"
    case Monthly = "Monthly"
}

enum kTargetTimeUnit {
    case minutes
    case hours
}

class TargetProgress: NSObject {
    
    var units:kTargetTimeUnit = .minutes
    var completionPercentage:Double = 0.0
    var completionValue:Double = 0
    var values:[Double] = [Double]()
    
}

class TargetTimeInterval: NSObject {
    var startDate:Date = Date(timeIntervalSince1970: 0.0)
    var endDate:Date = Date(timeIntervalSince1970: DBL_MAX)
    
    func containsDate(_ date:Date) -> Bool {
        var containsDate = false
        if ((date.compare(startDate) == ComparisonResult.orderedDescending) || (date.compare(startDate) == ComparisonResult.orderedSame)) {
            if ((date.compare(endDate) == ComparisonResult.orderedAscending) || (date.compare(endDate) == ComparisonResult.orderedSame)) {
                containsDate = true
            }
        }
        return containsDate
    }
}

class Target: NSManagedObject {
    
    func loadDictionary(_ dictionary:NSDictionary) {
        id = stringFromDictionary(dictionary, key:"id")
        createdDate = dateFromDictionary(dictionary, key:"created_date", format: "yyyy-MM-dd HH:mm:ss")
        modifiedDate = dateFromDictionary(dictionary, key:"modified_date", format: "yyyy-MM-dd HH:mm:ss")
        status = intFromDictionary(dictionary, key:"status") as NSNumber
        totalTime = intFromDictionary(dictionary, key:"total_time") as NSNumber
        timeSpan = stringFromDictionary(dictionary, key: "time_span").capitalized
        because = stringFromDictionary(dictionary, key:"because")
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> Target {
        let fetchRequest:NSFetchRequest<Target> = NSFetchRequest(entityName: targetEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var target:Target?
        do {
            try target = managedContext.fetch(fetchRequest).first
            if (target == nil) {
                target = Target.newTarget(dictionary)
            } else {
                target!.loadDictionary(dictionary)
            }
        } catch {
            target = Target.newTarget(dictionary)
        }
        return target!
    }
    
    fileprivate class func newTarget(_ dictionary:NSDictionary) -> Target {
        let entity = NSEntityDescription.entity(forEntityName: targetEntityName, in:managedContext)
        let target:Target = NSManagedObject(entity: entity!, insertInto: managedContext) as! Target
        target.loadDictionary(dictionary)
        return target
    }
    
    func dictionaryRepresentation() -> [String:String] {
        var dictionary = [String:String]()
        dictionary["activity_type"] = activityType.englishName
        dictionary["activity"] = activity.englishName
        dictionary["total_time"] = "\(totalTime)"
        dictionary["time_span"] = timeSpan
        if (module != nil) {
            dictionary["module"] = module!.id
        }
        if (!because.isEmpty) {
            dictionary["because"] = because
        }
        return dictionary
    }
    
    func textForDisplay() -> String {
        var textForDisplay = "\(activity.present) \(localized("for")) \(ActivityLog.timeSpentForDisplay(Int(totalTime)))"
        if let timeSpanValue = kTargetTimeSpan(rawValue: timeSpan) {
            textForDisplay = "\(activity.present) \(localized("for")) \(ActivityLog.timeSpentForDisplay(Int(totalTime))) \(localized("every")) \(timeSpanString(timeSpanValue))"
        }
        if (module != nil) {
            if let timeSpanValue = kTargetTimeSpan(rawValue: timeSpan) {
                textForDisplay = "\(activity.present) \(localized("for")) \(ActivityLog.timeSpentForDisplay(Int(totalTime))) \(localized("every")) \(timeSpanString(timeSpanValue)) \(localized("for")) \(module!.name)"
            } else {
                textForDisplay = "\(activity.present) \(localized("for")) \(ActivityLog.timeSpentForDisplay(Int(totalTime))) \(localized("for")) \(module!.name)"
            }
        }
        if (!because.isEmpty) {
            textForDisplay += " because \(because)"
        }
        return textForDisplay
    }
    
    func timeSpanString(_ span:kTargetTimeSpan) -> String {
        var timeInterval = ""
        switch (span) {
        case .Daily:
            timeInterval = localized("day")
        case .Weekly:
            timeInterval = localized("week")
        case .Monthly:
            timeInterval = localized("month")
        }
        
        return timeInterval
    }
    
    func activityLogs() -> [ActivityLog] {
        let timeInterval = timeIntervalForTimeSpan(kTargetTimeSpan(rawValue: timeSpan))
        let fetchRequest:NSFetchRequest<ActivityLog> = NSFetchRequest(entityName: activityLogEntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        var predicateFormat = "student.id == %@ AND activityType.englishName == %@ AND activity.englishName == %@ AND date >= %@ AND date <= %@"
        var arguments:[Any] = [dataManager.currentStudent!.id, activityType.englishName, activity.englishName, timeInterval.startDate, timeInterval.endDate]
        if (module != nil) {
            predicateFormat = "student.id == %@ AND module.id == %@ AND activityType.englishName == %@ AND activity.englishName == %@ AND date >= %@ AND date <= %@"
            arguments = [dataManager.currentStudent!.id, module!.id, activityType.englishName, activity.englishName, timeInterval.startDate, timeInterval.endDate]
        }
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: arguments)
        var array:[ActivityLog] = [ActivityLog]()
        do {
            array = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("get activities for target failed: \(error.localizedDescription)")
        }
        return array
    }
    
    //MARK: Progress Calculations
    
    func calculateProgress(_ ignoreOverflow:Bool) -> TargetProgress {
        let progress = TargetProgress()
        var values = progressValuesForTimeSpan(kTargetTimeSpan(rawValue: timeSpan))
        var totalMinutes = 0
        
        let array = activityLogs()
        
        dateFormatter.dateFormat = "d"
        let todayNumber = Int(dateFormatter.string(from: Date()))
        if (todayNumber != nil) {
            let targetCount = todayNumber!
            while (values.count < targetCount) {
                values.append(0.0)
            }
        }
        
        for (_, item) in array.enumerated() {
            totalMinutes += Int(item.timeSpent)
            if let span = kTargetTimeSpan(rawValue: timeSpan) {
                switch (span) {
                case .Daily:
                    dateFormatter.dateFormat = "HH"
                    let hour = Int(dateFormatter.string(from: item.date))
                    if (hour < 9) {
                        values[0] = values[0] + Double(item.timeSpent)
                    } else if (hour < 13) {
                        values[1] = values[1] + Double(item.timeSpent)
                    } else if (hour < 17) {
                        values[2] = values[2] + Double(item.timeSpent)
                    } else {
                        values[3] = values[3] + Double(item.timeSpent)
                    }
                    break
                case .Weekly:
                    dateFormatter.dateFormat = "e"
                    let weekday = Int(dateFormatter.string(from: item.date))
                    values[weekday! - 1] = values[weekday! - 1] + Double(item.timeSpent)
                    break
                case .Monthly:
                    dateFormatter.dateFormat = "d"
                    let monthday = Int(dateFormatter.string(from: item.date))
                    if (monthday != nil) {
                        let index = monthday! - 1
                        if (index < values.count) {
                            values[index] = values[index] + Double(item.timeSpent)
                        } else {
                            values.append(Double(item.timeSpent))
                        }
                    }
                    break
                }
            }
        }
        
        if (Int(totalTime) < 60) {
            progress.units = .minutes
            if (ignoreOverflow) {
                progress.completionValue = Double(totalMinutes)
            } else {
                progress.completionValue = min(Double(totalMinutes), Double(totalTime))
            }
        } else {
            progress.units = .hours
            let totalHours = Double(totalMinutes) / 60.0
            let timeTargetInHours = Double(totalTime) / 60.0
            if (ignoreOverflow) {
                progress.completionValue = totalHours
            } else {
                progress.completionValue = min(totalHours, timeTargetInHours)
            }
        }
        progress.completionPercentage = Double(totalMinutes) / Double(totalTime)
        progress.values = values
        return progress
    }
    
    func progressText(_ progress:TargetProgress) -> String {
        var text = ""
        if (progress.units == .minutes) {
            text = "\(Int(progress.completionValue))/\(totalTime)"
        } else {
            var completionValue = NSString(format: "%.1f", progress.completionValue)
            if ((progress.completionValue.truncatingRemainder(dividingBy: 60)) == 0) {
                completionValue = NSString(string: "\(Int(progress.completionValue / 60.0))")
            }
            var totalValue = NSString(format: "%.1f", Double(totalTime) / 60.0)
            if ((Int(totalTime) % 60) == 0) {
                totalValue = NSString(string: "\(Int(totalTime) / 60)")
            }
            text = "\(completionValue)/\(totalValue)"
        }
        return text
    }
    
    //MARK: Calculate Time Interval
    
    func timeIntervalForTimeSpan(_ span:kTargetTimeSpan?) -> TargetTimeInterval {
        let timeInterval = TargetTimeInterval()
        if let span = span {
            switch (span) {
            case .Daily:
                let startAndEndDates = startAndEndDatesForDaily()
                timeInterval.startDate = startAndEndDates.startDate
                timeInterval.endDate = startAndEndDates.endDate
                break
            case .Weekly:
                let startAndEndDates = startAndEndDatesForWeekly()
                timeInterval.startDate = startAndEndDates.startDate
                timeInterval.endDate = startAndEndDates.endDate
                break
            case .Monthly:
                let startAndEndDates = startAndEndDatesForMonthly()
                timeInterval.startDate = startAndEndDates.startDate
                timeInterval.endDate = startAndEndDates.endDate
                break
            }
        }
        return timeInterval
    }
    
    func startAndEndDatesForDaily() -> (startDate:Date, endDate:Date) {
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let string = dateFormatter.string(from: Date())
        let startDateString = "\(string) 00:00:00"
        let endDateString = "\(string) 23:59:59"
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        var startDate = Date(timeIntervalSince1970: 0.0)
        var endDate = Date(timeIntervalSince1970: DBL_MAX)
        if let start = dateFormatter.date(from: startDateString) {
            startDate = start
        }
        if let end = dateFormatter.date(from: endDateString) {
            endDate = end
        }
        return (startDate, endDate)
    }
    
    func startAndEndDatesForWeekly() -> (startDate:Date, endDate:Date) {
        let today = todayNumber()
        var components = DateComponents()
        components.day = -(today - 1)
        let calendar = Calendar.current
        let firstDayOfTheWeek = (calendar as NSCalendar).date(byAdding: components, to: Date(), options: NSCalendar.Options.matchStrictly)!
        components.day = 7 - today
        let lastDayOfTheWeek = (calendar as NSCalendar).date(byAdding: components, to: Date(), options: NSCalendar.Options.matchStrictly)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        var string = dateFormatter.string(from: firstDayOfTheWeek)
        let startDateString = "\(string) 00:00:00"
        string = dateFormatter.string(from: lastDayOfTheWeek)
        let endDateString = "\(string) 23:59:59"
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        var startDate = Date(timeIntervalSince1970: 0.0)
        var endDate = Date(timeIntervalSince1970: DBL_MAX)
        if let start = dateFormatter.date(from: startDateString) {
            startDate = start
        }
        if let end = dateFormatter.date(from: endDateString) {
            endDate = end
        }
        return (startDate, endDate)
    }
    
    func startAndEndDatesForMonthly() -> (startDate:Date, endDate:Date) {
        let calendar = Calendar.current
        let lastDayOfTheMonth = (calendar as NSCalendar).range(of: .day, in: .month, for: Date()).length
        dateFormatter.dateFormat = "MM-yyyy"
        let string = dateFormatter.string(from: Date())
        let startDateString = "01-\(string) 00:00:00"
        let endDateString = "\(lastDayOfTheMonth)-\(string) 23:59:59"
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        var startDate = Date(timeIntervalSince1970: 0.0)
        var endDate = Date(timeIntervalSince1970: DBL_MAX)
        if let start = dateFormatter.date(from: startDateString) {
            startDate = start
        }
        if let end = dateFormatter.date(from: endDateString) {
            endDate = end
        }
        return (startDate, endDate)
    }
    
    func progressValuesForTimeSpan(_ span:kTargetTimeSpan?) -> [Double] {
        var intervals = [Double]()
        if let span = span {
            switch (span) {
            case .Daily:
                intervals = [0.0, 0.0, 0.0, 0.0]
                break
            case .Weekly:
                intervals = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
                break
            case .Monthly:
                intervals = [Double]()
                break
            }
        }
        return intervals
    }
    
    func eligibleForStretch() -> Bool {
        var eligible = false
        if let span = kTargetTimeSpan(rawValue: timeSpan) {
            switch (span) {
            case .Daily:
                break
            case .Weekly:
                let intervalDates = startAndEndDatesForWeekly()
                let spareTime = intervalDates.endDate.timeIntervalSince(Date()) / 3600
                if (spareTime > 24) {
                    eligible = true
                }
                break
            case .Monthly:
                let intervalDates = startAndEndDatesForMonthly()
                let spareTime = intervalDates.endDate.timeIntervalSince(Date()) / 3600
                if (spareTime > 96) {
                    eligible = true
                }
                break
            }
        }
        return eligible
    }
}
