//
//  Student.swift
//  Jisc
//
//  Created by Therapy Box on 11/9/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import CoreData

let studentEntityName = "Student"
let kModulesKey = "modules"
let kFriendsKey = "friends"
let kStudentsInTheSameCourseKey = "studentsInTheSameCourse"
let kFriendRequestsKey = "friendRequests"
let kSentFriendRequestsKey = "sentFriendRequests"
let kActivityLogsKey = "activityLogs"
let kTargetsKey = "targets"
let kStretchTargetsKey = "stretchTargets"
let kMarksKey = "marks"
let kTrophiesKey = "trophies"

class Student: NSManagedObject {
    
    func loadDictionary(_ dictionary:NSDictionary) {
        if let institutionData = dictionary["institution_data"] as? NSDictionary {
            institution = Institution.insertInManagedObjectContext(managedContext, dictionary: institutionData)
        }
        var userData:NSDictionary = dictionary
        if let data = dictionary["user_data"] as? NSDictionary {
            userData = data
        }
        let myFirstTime = stringFromDictionary(userData, key: "first_time")//Adding in the first_time parameter?
        print("printing the first time key value", myFirstTime)
        let defaults = UserDefaults.standard
        defaults.set(myFirstTime, forKey: "FirstTime")
        
        accommodationCode = stringFromDictionary(userData, key: "accommodation_code")
        addressLine1 = stringFromDictionary(userData, key: "address_line_1")
        addressLine2 = stringFromDictionary(userData, key: "address_line_2")
        addressLine3 = stringFromDictionary(userData, key: "address_line_3")
        addressLine4 = stringFromDictionary(userData, key: "address_line_4")
        affiliation = stringFromDictionary(userData, key: "affiliation")
        age = intFromDictionary(userData, key: "age") as NSNumber
        countryCode = stringFromDictionary(userData, key: "country_code")
        disabilityCode = stringFromDictionary(userData, key: "disability_code")
        dob = dateFromDictionary(userData, key: "dob", format:"yyyy-MM-dd")
        email = stringFromDictionary(userData, key: "email")
        firstName = stringFromDictionary(userData, key: "first_name")
        lastName = stringFromDictionary(userData, key: "last_name")
        homePhone = stringFromDictionary(userData, key: "home_phone")
        id = stringFromDictionary(userData, key: "id")
        learningDifficultyCode = stringFromDictionary(userData, key: "learning_difficulty_code")
        mobilePhone = stringFromDictionary(userData, key: "mobile_phone")
        overseasCode = stringFromDictionary(userData, key: "overseas_code")
        parentsQualification = stringFromDictionary(userData, key: "parents_qualification")
        password = stringFromDictionary(userData, key: "password")
        photo = stringFromDictionary(userData, key: "photo")
        postalCode = stringFromDictionary(userData, key: "postal_code")
        raceCode = stringFromDictionary(userData, key: "race_code")
        sexCode = stringFromDictionary(userData, key: "sex_code")
        jisc_id = stringFromDictionary(dictionary, key: "jisc_student_id")
        social = boolFromDictionary(userData, key: "is_social_login") as NSNumber
        staff = boolFromDictionary(userData, key: "is_staff") as NSNumber
        demo = (jisc_id == "demouser") as NSNumber
        
        defaults.set(id, forKey: "StudentId")
        defaults.synchronize()
        
        let name = stringFromDictionary(userData, key: "name")
        if (!name.isEmpty) {
            let components = name.components(separatedBy: " ")
            firstName = components.first!
            if (components.count > 1) {
                lastName = components.last!
            }
        }
        
        let profile_pic = stringFromDictionary(userData, key: "profile_pic")
        if (!profile_pic.isEmpty) {
            photo = profile_pic
        }
    }
    
    class func insertInManagedObjectContext(_ context:NSManagedObjectContext, dictionary:NSDictionary) -> Student {
        let fetchRequest:NSFetchRequest<Student> = NSFetchRequest(entityName: studentEntityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", stringFromDictionary(dictionary, key: "id"))
        var student:Student?
        do {
            try student = managedContext.fetch(fetchRequest).first
            if (student == nil) {
                student = Student.newStudent(dictionary)
            } else {
                student!.loadDictionary(dictionary)
            }
        } catch {
            student = Student.newStudent(dictionary)
        }
        
        return student!
    }
    
    fileprivate class func newStudent(_ dictionary:NSDictionary) -> Student {
        let entity = NSEntityDescription.entity(forEntityName: studentEntityName, in:managedContext)
        let student:Student = NSManagedObject(entity: entity!, insertInto: managedContext) as! Student
        student.loadDictionary(dictionary)
        return student
    }
    
    //MARK: Modules
    
    func addModule(_ module:Module) {
        let modules = self.mutableSetValue(forKey: kModulesKey)
        modules.add(module)
    }
    
    //MARK: Friends
    
    func addFriend(_ friend:Friend) {
        let friends = self.mutableSetValue(forKey: kFriendsKey)
        friends.add(friend)
    }
    
    //MARK: Friend Requests
    
    func addFriendRequest(_ friendRequest:FriendRequest) {
        let friendRequests = self.mutableSetValue(forKey: kFriendRequestsKey)
        friendRequests.add(friendRequest)
    }
    
    //MARK: Sent Friend Requests
    
    func addSentFriendRequest(_ sentFriendRequest:SentFriendRequest) {
        let sentFriendRequests = self.mutableSetValue(forKey: kSentFriendRequestsKey)
        sentFriendRequests.add(sentFriendRequest)
    }
    
    //MARK: Students In The Same Course
    
    func addStudentInTheSameCourse(_ colleague:Colleague) {
        let studentsInTheSameCourse = self.mutableSetValue(forKey: kStudentsInTheSameCourseKey)
        studentsInTheSameCourse.add(colleague)
    }
    
    //MARK: Activity Logs
    
    func addActivityLog(_ activityLog:ActivityLog) {
        let activityLogs = self.mutableSetValue(forKey: kActivityLogsKey)
        activityLogs.add(activityLog)
    }
    
    //MARK: Targets
    
    func addTarget(_ target:Target) {
        let targets = self.mutableSetValue(forKey: kTargetsKey)
        targets.add(target)
    }
    
    //MARK: Stretch Targets
    
    func addStretchTarget(_ stretchTarget:StretchTarget) {
        let stretchTargets = self.mutableSetValue(forKey: kStretchTargetsKey)
        stretchTargets.add(stretchTarget)
    }
    
    //MARK: Marks
    
    func addMark(_ mark:Mark) {
        let marks = self.mutableSetValue(forKey: kMarksKey)
        marks.add(mark)
    }
    
    //MARK: Trophies
    
    func addTrophy(_ trophy:StudentTrophy) {
        let trophies = self.mutableSetValue(forKey: kTrophiesKey)
        trophies.add(trophy)
    }
}
