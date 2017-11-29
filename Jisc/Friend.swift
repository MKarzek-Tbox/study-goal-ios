//
//  Friend.swift
//  Jisc
//
//  Created by Therapy Box on 11/12/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let friendEntityName = "Friend"

class Friend: NSManagedObject {
    
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
        hidden = boolFromDictionary(dictionary, key: "hidden") as NSNumber
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
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> Friend {
        let fetchRequest:NSFetchRequest<Friend> = NSFetchRequest(entityName: friendEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var friend:Friend?
        do {
            try friend = managedContext.fetch(fetchRequest).first
            if (friend == nil) {
                friend = Friend.newFriend(dictionary)
            } else {
                friend!.loadDictionary(dictionary)
            }
        } catch {
            friend = Friend.newFriend(dictionary)
        }
        
        return friend!
    }
    
    fileprivate class func newFriend(_ dictionary:NSDictionary) -> Friend {
        let entity = NSEntityDescription.entity(forEntityName: friendEntityName, in:managedContext)
        let friend:Friend = NSManagedObject(entity: entity!, insertInto: managedContext) as! Friend
        friend.loadDictionary(dictionary)
        return friend
    }
}
