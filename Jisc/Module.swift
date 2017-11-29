//
//  Module.swift
//  Jisc
//
//  Created by Therapy Box on 11/10/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let moduleEntityName = "Module"

class Module: NSManagedObject {
    
    func loadDictionary(_ dictionary:NSDictionary) {
        if let keys = dictionary.allKeys as? [String] {
            if keys.count > 0 {
                id = keys[0]
                if let string = dictionary[id] as? String {
                    name = string
                }
            }
        }
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> Module {
        let fetchRequest:NSFetchRequest<Module> = NSFetchRequest(entityName: moduleEntityName)
        var moduleId = ""
        if let keys = dictionary.allKeys as? [String] {
            if keys.count > 0 {
                moduleId = keys[0]
            }
        }
        fetchRequest.predicate = NSPredicate(format: "id == %@", moduleId)
        var module:Module?
        do {
            try module = managedContext.fetch(fetchRequest).first
            if (module == nil) {
                module = Module.newModule(dictionary)
            } else {
                module!.loadDictionary(dictionary)
            }
        } catch {
            module = Module.newModule(dictionary)
        }
        return module!
    }
    
    fileprivate class func newModule(_ dictionary:NSDictionary) -> Module {
        let entity = NSEntityDescription.entity(forEntityName: moduleEntityName, in:managedContext)
        let module:Module = NSManagedObject(entity: entity!, insertInto: managedContext) as! Module
        module.loadDictionary(dictionary)
        return module
    }
    
    //	func loadArray(array:NSArray) {
    //		if (array.count > 0) {
    //			if let string = array.objectAtIndex(0) as? String {
    //				name = string
    //			}
    //		}
    //		if (array.count > 1) {
    //			if let string = array.objectAtIndex(1) as? String {
    //				id = string
    //			}
    //		}
    //	}
    //
    //	class func insertInManagedObjectContext(context:NSManagedObjectContext, array:NSArray) -> Module {
    //		let module = Module.newModule(array)
    //		return module
    //	}
    //	
    //	private class func newModule(array:NSArray) -> Module {
    //		let entity = NSEntityDescription.entityForName(moduleEntityName, inManagedObjectContext:managedContext)
    //		let module:Module = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Module
    //		module.loadArray(array)
    //		return module
    //	}
    
}
