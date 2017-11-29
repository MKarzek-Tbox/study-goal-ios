//
//  SentFriendRequest.swift
//  Jisc
//
//  Created by Therapy Box on 11/27/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let sentFriendRequestEntityName = "SentFriendRequest"

class SentFriendRequest: NSManagedObject {
    
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
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> SentFriendRequest {
        let fetchRequest:NSFetchRequest<SentFriendRequest> = NSFetchRequest(entityName: sentFriendRequestEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var sentFriendRequest:SentFriendRequest?
        do {
            try sentFriendRequest = managedContext.fetch(fetchRequest).first
            if (sentFriendRequest == nil) {
                sentFriendRequest = SentFriendRequest.newSentFriendRequest(dictionary)
            } else {
                sentFriendRequest!.loadDictionary(dictionary)
            }
        } catch {
            sentFriendRequest = SentFriendRequest.newSentFriendRequest(dictionary)
        }
        
        return sentFriendRequest!
    }
    
    fileprivate class func newSentFriendRequest(_ dictionary:NSDictionary) -> SentFriendRequest {
        let entity = NSEntityDescription.entity(forEntityName: sentFriendRequestEntityName, in:managedContext)
        let sentFriendRequest:SentFriendRequest = NSManagedObject(entity: entity!, insertInto: managedContext) as! SentFriendRequest
        sentFriendRequest.loadDictionary(dictionary)
        return sentFriendRequest
    }
}
