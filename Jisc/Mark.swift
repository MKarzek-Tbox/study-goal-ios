//
//  Mark.swift
//  Jisc
//
//  Created by Therapy Box on 12/3/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let markEntityName = "Mark"
let kValuesKey = "values"

class Mark: NSManagedObject {
    
    func loadValues(_ moduleID:String, markName:String) {
        let moduleWithID = dataManager.moduleWithID(moduleID)
        if (moduleWithID != nil) {
            module = moduleWithID!
        }
        name = markName
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, studentID:String, moduleID:String, markName:String) -> Mark {
        let fetchRequest:NSFetchRequest<Mark> = NSFetchRequest(entityName: markEntityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND module.id == %@ AND student.id == %@", markName, moduleID, studentID)
        var mark:Mark?
        do {
            try mark = managedContext.fetch(fetchRequest).first
            if (mark == nil) {
                mark = Mark.newMark(moduleID, markName: markName)
            } else {
                mark!.loadValues(moduleID, markName: markName)
            }
        } catch {
            mark = Mark.newMark(moduleID, markName: markName)
        }
        return mark!
    }
    
    fileprivate class func newMark(_ moduleID:String, markName:String) -> Mark {
        let entity = NSEntityDescription.entity(forEntityName: markEntityName, in:managedContext)
        let mark:Mark = NSManagedObject(entity: entity!, insertInto: managedContext) as! Mark
        mark.loadValues(moduleID, markName: markName)
        return mark
    }
    
    //MARK: Values
    
    func addValue(_ value:MarkValue) {
        let values = self.mutableSetValue(forKey: kValuesKey)
        values.add(value)
    }
}
