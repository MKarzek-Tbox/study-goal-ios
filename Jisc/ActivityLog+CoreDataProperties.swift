//
//  ActivityLog+CoreDataProperties.swift
//  Jisc
//
//  Created by Therapy Box on 11/10/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ActivityLog {
    
    @NSManaged var createdDate: Date
    @NSManaged var date: Date
    @NSManaged var id: String
    @NSManaged var isPaused: NSNumber
    @NSManaged var isRunning: NSNumber
    @NSManaged var modifiedDate: Date
    @NSManaged var note: String
    @NSManaged var pauseDate: Date
    @NSManaged var timeSpent: NSNumber
    @NSManaged var activity: Activity
    @NSManaged var activityType: ActivityType
    @NSManaged var module: Module?
    @NSManaged var student: Student
    
}
