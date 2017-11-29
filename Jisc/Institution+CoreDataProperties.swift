//
//  Institution+CoreDataProperties.swift
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

extension Institution {
    
    @NSManaged var accessKey: String
    @NSManaged var id: String
    @NSManaged var isLearningAnalytics: NSNumber
    @NSManaged var name: String
    @NSManaged var secret: String
    @NSManaged var students: NSSet
    
}
