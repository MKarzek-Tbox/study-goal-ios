//
//  ActivityType+CoreDataProperties.swift
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

extension ActivityType {
    
    @NSManaged var englishName: String
    @NSManaged var name: String
    @NSManaged var activities: NSSet
    @NSManaged var activityLogs: NSSet
    @NSManaged var targets: NSSet
    
}
