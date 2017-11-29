//
//  Institution.swift
//  Jisc
//
//  Created by Therapy Box on 11/10/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let institutionEntityName = "Institution"

class Institution: NSManagedObject {
    
    func loadDictionary(_ dictionary:NSDictionary) {
        id = stringFromDictionary(dictionary, key: "id")
        isLearningAnalytics = boolFromDictionary(dictionary, key: "is_learning_analytics") as NSNumber
        name = stringFromDictionary(dictionary, key: "name")
        accessKey = stringFromDictionary(dictionary, key: "accesskey")
        secret = stringFromDictionary(dictionary, key: "secret")
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> Institution {
        let fetchRequest:NSFetchRequest<Institution> = NSFetchRequest(entityName: institutionEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var institution:Institution?
        do {
            try institution = managedContext.fetch(fetchRequest).first as Institution?
            if (institution == nil) {
                institution = Institution.newInstitution(dictionary)
            } else {
                institution!.loadDictionary(dictionary)
            }
        } catch {
            institution = Institution.newInstitution(dictionary)
        }
        return institution!
    }
    
    fileprivate class func newInstitution(_ dictionary:NSDictionary) -> Institution {
        let entity = NSEntityDescription.entity(forEntityName: institutionEntityName, in:managedContext)
        let institution:Institution = NSManagedObject(entity: entity!, insertInto: managedContext) as! Institution
        institution.loadDictionary(dictionary)
        return institution
    }
}
