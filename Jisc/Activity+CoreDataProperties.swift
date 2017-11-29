//
//  Activity+CoreDataProperties.swift
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

extension Activity {
    
    @NSManaged var id: String
    @NSManaged var englishName: String
    @NSManaged var name: String
    @NSManaged var past: String
    @NSManaged var present: String
    @NSManaged var activityLogs: NSSet
    @NSManaged var activityTypes: NSSet
    @NSManaged var targets: NSSet
    
}
