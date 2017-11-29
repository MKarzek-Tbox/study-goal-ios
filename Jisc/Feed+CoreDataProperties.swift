//
//  Feed+CoreDataProperties.swift
//  Jisc
//
//  Created by Therapy Box on 12/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Feed {
    
    @NSManaged var activityType: String
    @NSManaged var createdDate: Date
    @NSManaged var from: String
    @NSManaged var id: String
    @NSManaged var message: String
    @NSManaged var to: String
    @NSManaged var isHidden: NSNumber
    
}
