//
//  FriendRequest+CoreDataProperties.swift
//  Jisc
//
//  Created by Therapy Box on 11/27/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FriendRequest {
    
    @NSManaged var accommodationCode: String
    @NSManaged var addressLine1: String
    @NSManaged var addressLine2: String
    @NSManaged var addressLine3: String
    @NSManaged var addressLine4: String
    @NSManaged var age: NSNumber
    @NSManaged var countryCode: String
    @NSManaged var disabilityCode: String
    @NSManaged var dob: Date
    @NSManaged var email: String
    @NSManaged var firstName: String
    @NSManaged var homePhone: String
    @NSManaged var id: String
    @NSManaged var jisc_id: String
    @NSManaged var lastName: String
    @NSManaged var learningDifficultyCode: String
    @NSManaged var mobilePhone: String
    @NSManaged var overseasCode: String
    @NSManaged var parentsQualification: String
    @NSManaged var password: String
    @NSManaged var photo: String
    @NSManaged var postalCode: String
    @NSManaged var raceCode: String
    @NSManaged var sexCode: String
    @NSManaged var requestedFriendshipOf: Student
    
}
