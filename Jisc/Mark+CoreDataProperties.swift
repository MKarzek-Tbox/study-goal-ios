//
//  Mark+CoreDataProperties.swift
//  Jisc
//
//  Created by Therapy Box on 12/3/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Mark {
    
    @NSManaged var name: String
    @NSManaged var module: Module
    @NSManaged var values: NSSet
    @NSManaged var student: Student
    
}
