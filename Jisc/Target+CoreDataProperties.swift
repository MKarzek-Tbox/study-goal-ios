//
//  Target+CoreDataProperties.swift
//  Jisc
//
//  Created by Therapy Box on 11/17/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Target {
    
    @NSManaged var because: String
    @NSManaged var createdDate: Date
    @NSManaged var id: String
    @NSManaged var modifiedDate: Date
    @NSManaged var status: NSNumber
    @NSManaged var timeSpan: String
    @NSManaged var totalTime: NSNumber
    @NSManaged var activity: Activity
    @NSManaged var activityType: ActivityType
    @NSManaged var module: Module?
    @NSManaged var student: Student
    @NSManaged var stretchTargets: NSSet
    
}
