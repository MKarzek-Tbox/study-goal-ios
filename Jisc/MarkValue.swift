//
//  MarkValue.swift
//  Jisc
//
//  Created by Therapy Box on 12/3/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let markValueEntityName = "MarkValue"

class MarkValue: NSManagedObject {
    
    func loadValue(_ markValue:Int) {
        value = markValue as NSNumber
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, mark:Mark, markValue:Int) -> MarkValue {
        let fetchRequest:NSFetchRequest<MarkValue> = NSFetchRequest(entityName: markValueEntityName)
        fetchRequest.predicate = NSPredicate(format: "mark.name == %@ AND mark.module.id == %@ AND value == %d", mark.name, mark.module.id, markValue)
        var markV:MarkValue?
        do {
            try markV = managedContext.fetch(fetchRequest).first
            if (markV == nil) {
                markV = MarkValue.newMarkValue(markValue)
            } else {
                markV!.loadValue(markValue)
            }
        } catch {
            markV = MarkValue.newMarkValue(markValue)
        }
        return markV!
    }
    
    fileprivate class func newMarkValue(_ markValue:Int) -> MarkValue {
        let entity = NSEntityDescription.entity(forEntityName: markValueEntityName, in:managedContext)
        let value:MarkValue = NSManagedObject(entity: entity!, insertInto: managedContext) as! MarkValue
        value.loadValue(markValue)
        return value
    }
}
