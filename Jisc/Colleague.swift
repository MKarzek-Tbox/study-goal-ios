//
//  Colleague.swift
//  Jisc
//
//  Created by Therapy Box on 11/12/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let colleagueEntityName = "Colleague"

class Colleague: NSManagedObject {
    
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
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> Colleague {
        let fetchRequest:NSFetchRequest<Colleague> = NSFetchRequest(entityName: colleagueEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var colleague:Colleague?
        do {
            try colleague = managedContext.fetch(fetchRequest).first
            if (colleague == nil) {
                colleague = Colleague.newColleague(dictionary)
            } else {
                colleague!.loadDictionary(dictionary)
            }
        } catch {
            colleague = Colleague.newColleague(dictionary)
        }
        
        return colleague!
    }
    
    fileprivate class func newColleague(_ dictionary:NSDictionary) -> Colleague {
        let entity = NSEntityDescription.entity(forEntityName: colleagueEntityName, in:managedContext)
        let colleague:Colleague = NSManagedObject(entity: entity!, insertInto: managedContext) as! Colleague
        colleague.loadDictionary(dictionary)
        return colleague
    }
}
