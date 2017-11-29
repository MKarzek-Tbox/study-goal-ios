//
//  Feed.swift
//  Jisc
//
//  Created by Therapy Box on 11/20/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let feedEntityName = "Feed"

class Feed: NSManagedObject {
    
    func loadDictionary(_ dictionary:NSDictionary) {
        id = stringFromDictionary(dictionary, key:"id")
        createdDate = dateFromDictionary(dictionary, key:"created_date", format: "yyyy-MM-dd HH:mm:ss")
        message = stringFromDictionary(dictionary, key:"message")
        from = stringFromDictionary(dictionary, key:"message_from")
        to = stringFromDictionary(dictionary, key:"message_to")
        isHidden = boolFromDictionary(dictionary, key: "is_hidden") as NSNumber
        activityType = stringFromDictionary(dictionary, key: "activity_type")
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> Feed {
        let fetchRequest:NSFetchRequest<Feed> = NSFetchRequest(entityName: feedEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var feed:Feed?
        do {
            try feed = managedContext.fetch(fetchRequest).first
            if (feed == nil) {
                feed = Feed.newFeed(dictionary)
            } else {
                feed!.loadDictionary(dictionary)
            }
        } catch {
            feed = Feed.newFeed(dictionary)
        }
        return feed!
    }
    
    fileprivate class func newFeed(_ dictionary:NSDictionary) -> Feed {
        let entity = NSEntityDescription.entity(forEntityName: feedEntityName, in:managedContext)
        let feed:Feed = NSManagedObject(entity: entity!, insertInto: managedContext) as! Feed
        feed.loadDictionary(dictionary)
        return feed
    }
    
    func isMine() -> Bool {
        var isMine = false
        if let student = dataManager.currentStudent{
            isMine = (from == student.id)
        }
        return isMine
    }
    
    func fromFriend() -> Friend? {
        let fetchRequest:NSFetchRequest<Friend> = NSFetchRequest(entityName: friendEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", from)
        var friend:Friend?
        do {
            try friend = managedContext.fetch(fetchRequest).first
        } catch let error as NSError {
            print("from friend not found: \(error.localizedDescription)")
        }
        return friend
    }
    
    func fromColleague() -> Colleague? {
        let fetchRequest:NSFetchRequest<Colleague> = NSFetchRequest(entityName: colleagueEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", from)
        var colleague:Colleague?
        do {
            try colleague = managedContext.fetch(fetchRequest).first
        } catch let error as NSError {
            print("colleague friend not found: \(error.localizedDescription)")
        }
        return colleague
    }
    
    func shareText() -> String {
        var text = message.replacingOccurrences(of: "You", with: "I")
        text = text.replacingOccurrences(of: "you", with: "I")
        text = "\(text)\n\n\(localized("sent_from"))"
        return text
    }
}
