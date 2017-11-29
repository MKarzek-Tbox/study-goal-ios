//
//  FriendRequest.swift
//  Jisc
//
//  Created by Therapy Box on 11/12/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let friendRequestEntityName = "FriendRequest"

class FriendRequest: NSManagedObject {
    
    func loadDictionary(_ dictionary:NSDictionary) {
        accommodationCode = stringFromDictionary(dictionary, key: "accommodation_code")
        addressLine1 = stringFromDictionary(dictionary, key: "address_line_1")
        addressLine2 = stringFromDictionary(dictionary, key: "address_line_2")
        addressLine3 = stringFromDictionary(dictionary, key: "address_line_3")
        addressLine4 = stringFromDictionary(dictionary, key: "address_line_4")
        age = intFromDictionary(dictionary, key: "age") as NSNumber
        countryCode = stringFromDictionary(dictionary, key: "country_code")
        disabilityCode = stringFromDictionary(dictionary, key: "disability_code")
        dob = dateFromDictionary(dictionary, key: "dob", format:"yyyy-MM-dd")
        email = stringFromDictionary(dictionary, key: "email")
        firstName = stringFromDictionary(dictionary, key: "first_name")
        lastName = stringFromDictionary(dictionary, key: "last_name")
        homePhone = stringFromDictionary(dictionary, key: "home_phone")
        id = stringFromDictionary(dictionary, key: "id")
        learningDifficultyCode = stringFromDictionary(dictionary, key: "learning_difficulty_code")
        mobilePhone = stringFromDictionary(dictionary, key: "mobile_phone")
        overseasCode = stringFromDictionary(dictionary, key: "overseas_code")
        parentsQualification = stringFromDictionary(dictionary, key: "parents_qualification")
        password = stringFromDictionary(dictionary, key: "password")
        photo = stringFromDictionary(dictionary, key: "photo")
        postalCode = stringFromDictionary(dictionary, key: "postal_code")
        raceCode = stringFromDictionary(dictionary, key: "race_code")
        sexCode = stringFromDictionary(dictionary, key: "sex_code")
        jisc_id = stringFromDictionary(dictionary, key: "jisc_student_id")
        
        let name = stringFromDictionary(dictionary, key: "name")
        if (!name.isEmpty) {
            let components = name.components(separatedBy: " ")
            firstName = components.first!
            if (components.count > 1) {
                lastName = components.last!
            }
        }
        
        let profile_pic = stringFromDictionary(dictionary, key: "profile_pic")
        if (!profile_pic.isEmpty) {
            photo = profile_pic
        }
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> FriendRequest {
        let fetchRequest:NSFetchRequest<FriendRequest> = NSFetchRequest(entityName: friendRequestEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var friendRequest:FriendRequest?
        do {
            try friendRequest = managedContext.fetch(fetchRequest).first
            if (friendRequest == nil) {
                friendRequest = FriendRequest.newFriendRequest(dictionary)
            } else {
                friendRequest!.loadDictionary(dictionary)
            }
        } catch {
            friendRequest = FriendRequest.newFriendRequest(dictionary)
        }
        
        return friendRequest!
    }
    
    fileprivate class func newFriendRequest(_ dictionary:NSDictionary) -> FriendRequest {
        let entity = NSEntityDescription.entity(forEntityName: friendRequestEntityName, in:managedContext)
        let friendRequest:FriendRequest = NSManagedObject(entity: entity!, insertInto: managedContext) as! FriendRequest
        friendRequest.loadDictionary(dictionary)
        return friendRequest
    }
}
