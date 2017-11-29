//
//  Constants.swift
//  Jisc
//
//  Created by Therapy Box on 10/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import CoreData


var devicePushToken = ""

let xAPILoginCompleteNotification = "xAPILoginCompleteNotification"

let onSimulator = TARGET_IPHONE_SIMULATOR == 1
let demoXAPIToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE0ODgzNjU2NzcsImp0aSI6IjFtbjhnU3YrWk9mVzJlYXV1NmVrN0Rzbm1MUjA0dDRyT0V0SEQ5Z1BGdk09IiwiaXNzIjoiaHR0cDpcL1wvc3AuZGF0YVwvYXV0aCIsIm5iZiI6MTQ4ODM2NTY2NywiZXhwIjoxNjYyNTY0NTY2NywiZGF0YSI6eyJlcHBuIjoiIiwicGlkIjoiZGVtb3VzZXJAZGVtby5hYy51ayIsImFmZmlsaWF0aW9uIjoic3R1ZGVudEBkZW1vLmFjLnVrIn19.xM6KkBFvHW7vtf6dF-X4f_6G3t_KGPVNylN_rMJROsh1MXIg9sK5j77L0Jzg1JR8fhXZf-0jFMnZz6FMotAeig"

enum ScreenWidth:CGFloat {
    case small = 320.0
    case medium = 375.0
    case large = 414.0
    case iPad = 1024.0
}

var currentlyLoggedInStudentInstitute = ""
var currentlyLoggedInStudentEmail = ""
var currentlyLoggedInStudentPassword = ""

func weHaveACurrentUser() -> Bool {
    return (!currentlyLoggedInStudentInstitute.isEmpty && !currentlyLoggedInStudentEmail.isEmpty && !currentlyLoggedInStudentPassword.isEmpty)
}

let trophyDataArray:NSArray = NSArray(contentsOfFile: Bundle.main.path(forResource: "trophies", ofType: "plist")!)!

let screenWidth:ScreenWidth = iPad ? .iPad : ScreenWidth(rawValue: UIScreen.main.bounds.width)!

let DELEGATE = UIApplication.shared.delegate as! AppDelegate
let iPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
var supportedInterfaceOrientationsForIPad = UIInterfaceOrientationMask.landscape

let lightBlueColor = UIColor(red: 0.22, green: 0.57, blue: 0.94, alpha: 1.0)
let lilacColor = UIColor(red: 0.53, green: 0.39, blue: 0.78, alpha: 1.0)
let appPurpleColor = UIColor(red: 0.68, green: 0.4, blue: 0.82, alpha: 1.0)

func myriadProRegular(_ size:CGFloat) -> UIFont? {
    return UIFont(name: "MyriadPro-Regular", size: size)
}

func myriadProLight(_ size:CGFloat) -> UIFont? {
    return UIFont(name: "MyriadPro-Light", size: size)
}

let dateFormatter = DateFormatter()
var keyboardHeight:CGFloat = 0.0

func todayNumber() -> Int {
    dateFormatter.dateFormat = "e"
    let string = "\(dateFormatter.string(from: Date()))"
    var integer = Int(string)
    if (integer == nil) {
        integer = 0
    }
    return integer!
}

//MARK: Reachability

enum ReachabilityStatus {
    case reachable, notReachable, notInitialized
}

var internetAvailability:ReachabilityStatus = .notInitialized
let reachability = Reachability()

let documentsPath = "\(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!)/UserValues/"

func filePath(_ fileName:String) -> String {
    
    var isDir : ObjCBool = true
    if (!FileManager.default.fileExists(atPath: documentsPath, isDirectory: &isDir))
    {
        do {
            try FileManager.default.createDirectory(atPath: documentsPath, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print("create directory error: \(error)")
        }
    }
    return documentsPath + fileName
}

func deviceId() -> String {
    return md5(documentsPath)
}

func appVersion() -> String {
    var version = ""
    if let string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        version = string
    }
    return version
}

func buildVersion() -> String {
    var version = ""
    if let string = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
        version = string
    }
    return version
}

//MARK: HomeScreen

enum kHomeScreenTab: Int {
    case feed = 0
    case friends = 1
    case stats = 2
    case checkin = 3
    case log = 4
    case target = 5
}

func screenTabFromString(_ string:String) -> kHomeScreenTab {
    var screenTab:kHomeScreenTab? = nil
    if (string == "feed") {
        screenTab = .feed
    } else if (string == "friends") {
        screenTab = .friends
    } else if (string == "stats") {
        screenTab = .stats
    } else if (string == "checkin") {
        screenTab = .checkin
    } else if (string == "log") {
        screenTab = .log
    } else if (string == "target") {
        screenTab = .target
    }
    if (screenTab == nil) {
        screenTab = .feed
    }
    return screenTab!
}

var homeScreenTab:kHomeScreenTab? = nil

func getHomeScreenTab() -> kHomeScreenTab {
    if (homeScreenTab == nil) {
        homeScreenTab = kHomeScreenTab.feed
        if (FileManager.default.fileExists(atPath: filePath("homeScreenTab"))) {
            homeScreenTab = kHomeScreenTab(rawValue:NSKeyedUnarchiver.unarchiveObject(withFile: filePath("homeScreenTab")) as! Int)!
        }
    }
    return homeScreenTab!
}

func setHomeScreenTab(_ tab:kHomeScreenTab?) {
    if (tab != nil) {
        homeScreenTab = tab
    } else {
        homeScreenTab = kHomeScreenTab.feed
    }
    NSKeyedArchiver.archiveRootObject(homeScreenTab!.rawValue, toFile: filePath("homeScreenTab"))
}

//MARK: Current User

func getCurrentUser() -> [String:String]? {
    let dictionary:[String:String]? = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("currentUser")) as? [String:String]
    return dictionary
}

func saveCurrentUser(_ instituteID:String, email:String, password:String) {
    var dictionary:[String:String] = [String:String]()
    dictionary["instituteID"] = instituteID
    dictionary["email"] = email
    dictionary["password"] = password
    NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath("currentUser"))
}

func deleteCurrentUser() {
    currentlyLoggedInStudentInstitute = ""
    currentlyLoggedInStudentEmail = ""
    currentlyLoggedInStudentPassword = ""
    do {
        try FileManager.default.removeItem(atPath: filePath("currentUser"))
    } catch {
        print("delete user error: \(error)")
    }
}

func shouldRememberXAPIUser() -> Bool {
    let shouldRemember = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("shouldRememberXAPIUser")) as? Bool
    if (shouldRemember != nil) {
        return shouldRemember!
    } else {
        return false
    }
}

func setShouldRememberXAPIUser(_ save:Bool) {
    NSKeyedArchiver.archiveRootObject(save, toFile: filePath("shouldRememberXAPIUser"))
}

//MARK: xAPI Token

func xAPIToken() -> String? {
    let string = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("xAPIToken")) as? String
    return string
}

func setXAPIToken(_ sender:String) {
    NSKeyedArchiver.archiveRootObject(sender, toFile: filePath("xAPIToken"))
    if keepMeLoggedIn() {
        if let institutionId = dataManager.pickedInstitution?.id {
            NSKeyedArchiver.archiveRootObject(institutionId, toFile: filePath("institutionId"))
        }
    }
}

func clearXAPIToken() {
    do {
        try FileManager.default.removeItem(atPath: filePath("xAPIToken"))
    } catch {
        print("clear xAPI token error: \(error)")
    }
}

//MARK: IDPs

func getIDPForInstitution(_ name:String, dictionary:NSDictionary) -> String {
    var IDP = ""
    
    if let idpDict = dictionary[name] as? NSDictionary {
        if let idpFromDict = idpDict["url"] as? String {
            IDP = "\(idpFromDict)"
        }
    }
    
    return IDP
}

//MARK: Language

enum kLanguage:Int {
    case english = 0
    case welsh = 1
}

func languageFromString(_ string:String) -> kLanguage {
    var language:kLanguage? = nil
    if (string == "english") {
        language = .english
    } else if (string == "welsh") {
        language = .welsh
    }
    if (language == nil) {
        language = .english
    }
    return language!
}

var appLanguage:kLanguage? = nil

func getAppLanguage() -> kLanguage {
    if (appLanguage == nil) {
        appLanguage = kLanguage.english
        if (FileManager.default.fileExists(atPath: filePath("appLanguage"))) {
            appLanguage = kLanguage(rawValue:NSKeyedUnarchiver.unarchiveObject(withFile: filePath("appLanguage")) as! Int)!
        }
    }
    return appLanguage!
}

func setAppLanguage(_ language:kLanguage?) {
    if (language != nil) {
        appLanguage = language
    } else {
        appLanguage = kLanguage.english
    }
    
    switch (appLanguage!) {
    case .english:
        BundleLocalization.sharedInstance().language = kAppLanguage.English.rawValue
        break
    case .welsh:
        BundleLocalization.sharedInstance().language = kAppLanguage.Welsh.rawValue
        break
    }
    NSKeyedArchiver.archiveRootObject(appLanguage!.rawValue, toFile: filePath("appLanguage"))
}

//MARK: Local Notifications

func getLocalNotification(_ notificationID:String) -> UILocalNotification? {
    var notification:UILocalNotification? = nil
    if (FileManager.default.fileExists(atPath: filePath(notificationID))) {
        let object = NSKeyedUnarchiver.unarchiveObject(withFile: filePath(notificationID)) as? UILocalNotification
        if (object != nil) {
            notification = object
        }
    }
    return notification
}

func getLocalNotificationTime(_ notificationID:String) -> Foundation.TimeInterval? {
    var time:Foundation.TimeInterval? = nil
    if (FileManager.default.fileExists(atPath: filePath("time_\(notificationID)"))) {
        let object = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("time_\(notificationID)")) as? Foundation.TimeInterval
        if (object != nil) {
            time = object
        }
    }
    return time
}

func saveLocalNotification(_ notification:UILocalNotification, notificationID:String, time:Foundation.TimeInterval) {
    deleteLocalNotification(notificationID)
    if (!notificationID.isEmpty) {
        NSKeyedArchiver.archiveRootObject(notification, toFile: filePath(notificationID))
        NSKeyedArchiver.archiveRootObject(time, toFile: filePath("time_\(notificationID)"))
    } else {
        print("tried to save local notification with no id")
    }
}

func deleteLocalNotification(_ notificationID:String) {
    if (!notificationID.isEmpty) {
        let notification = getLocalNotification(notificationID)
        if (notification != nil) {
            UIApplication.shared.cancelLocalNotification(notification!)
        }
        do {
            try FileManager.default.removeItem(atPath: filePath(notificationID))
        } catch let error as NSError {
            print("delete local notification with id \(notificationID) failed: \(error.localizedDescription)")
        }
    }
}

//MARK: Safe Dictionary Getters

func stringFromDictionary(_ sender:NSDictionary, key:String) -> String {
    var value:String = ""
    let temp:AnyObject? = sender.object(forKey: key) as AnyObject?
    if let tempString = sender.object(forKey: key) as? String {
        value = tempString
    } else if (temp != nil) {
        value = "\(temp!)"
    }
    return value
}

func dateFromDictionary(_ sender:NSDictionary, key:String, format:String) -> Date {
    var value:Date = Date(timeIntervalSince1970: 0.0)
    let temp:AnyObject? = sender.object(forKey: key) as AnyObject?
    
    if ((temp != nil) && ((temp as? NSNull) != NSNull()) && ((temp as? String) != nil))
    {
        let options:NSString.CompareOptions = NSString.CompareOptions.caseInsensitive
        var string:String = temp as! String
        string = string.lowercased()
        string = string.components(separatedBy: ".")[0]
        string = string.replacingOccurrences(of: "t", with: " ", options: options, range: nil)
        
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format
        let date:Date? = dateFormatter.date(from: string)
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        if (date != nil)
        {
            value = date!
        }
        else
        {
            value = Date(timeIntervalSince1970: 0.0)
        }
    }
    
    return value
}

func intFromDictionary(_ sender:NSDictionary, key:String) -> Int {
    var value:Int = 0
    if let number = sender.object(forKey: key) as? NSNumber {
        value = number.intValue
    } else if let string = sender.object(forKey: key) as? String {
        value = (string as NSString).integerValue
    }
    return value
}

func floatFromDictionary(_ sender:NSDictionary, key:String) -> Float {
    var value:Float = 0.0
    if let number = sender.object(forKey: key) as? NSNumber {
        value = number.floatValue
    } else if let string = sender.object(forKey: key) as? String {
        value = (string as NSString).floatValue
    }
    return value
}

func doubleFromDictionary(_ sender:NSDictionary, key:String) -> Double {
    var value:Double = 0.0
    if let number = sender.object(forKey: key) as? NSNumber {
        value = number.doubleValue
    } else if let string = sender.object(forKey: key) as? String {
        value = (string as NSString).doubleValue
    }
    return value
}

func boolFromDictionary(_ sender:NSDictionary, key:String) -> Bool {
    var value:Bool = false
    if let number = sender.object(forKey: key) as? NSNumber {
        value = number.boolValue
    } else if let string = sender.object(forKey: key) as? String {
        value = (string as NSString).boolValue
    }
    return value
}

//MARK: Image Manipulation

func applyBlurEffect(_ image:UIImage?) -> UIImage? {
    var blurredImage:UIImage? = nil
    if (image != nil) {
        let imageToBlur = CIImage(image: image!)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.value(forKey: "outputImage") as! CIImage
        blurredImage = UIImage(ciImage: resultImage)
    }
    return blurredImage
}

func scaleImage(_ image:UIImage?, toSize:CGSize, keepScreenScale:Bool) -> UIImage? {
    var scaledImage:UIImage? = nil
    if (image != nil) {
        let imageAspectRatio = image!.size.width / image!.size.height
        let requiredAspectRatio = toSize.width / toSize.height
        var scale:CGFloat = 1.0
        if (imageAspectRatio > requiredAspectRatio) {
            scale = (toSize.height / image!.size.height)
        } else {
            scale = (toSize.width / image!.size.width)
        }
        if (keepScreenScale) {
            scale *= UIScreen.main.scale
        }
        let size = image!.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        image!.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    return scaledImage
}

//MARK: Text Height

func heightForText(_ text:String?, font:UIFont, width:CGFloat, caresAboutWords:Bool) -> CGFloat {
    var height:CGFloat = 0.0
    if (text != nil) {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        height = label.frame.size.height
        
        if (caresAboutWords) {
            let string = NSString(string: text!)
            var longestWordWidth:CGFloat = 0
            let words = string.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            for (_, item) in words.enumerated() {
                let word = NSString(string: item)
                let wordSize = word.size(attributes: [NSFontAttributeName:font])
                longestWordWidth = max(wordSize.width, longestWordWidth)
            }
            if (longestWordWidth > width) {
                height = CGFloat.greatestFiniteMagnitude
            }
        }
    }
    return height
}

//MARK: Unique ID

func uniqueID() -> String {
    return NSUUID().uuidString.lowercased()
}

//MARK: Constraints

func makeConstraint(_ item1:UIView, attribute1:NSLayoutAttribute, relation:NSLayoutRelation, item2:UIView?, attribute2:NSLayoutAttribute, multiplier:CGFloat, constant:CGFloat) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(item: item1, attribute: attribute1, relatedBy: relation, toItem: item2, attribute: attribute2, multiplier: multiplier, constant: constant)
    return constraint
}

func addMarginConstraintsWithView(_ view:UIView, toSuperView:UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    let top = makeConstraint(toSuperView, attribute1: .top, relation: .equal, item2: view, attribute2: .top, multiplier: 1.0, constant: 0.0)
    let left = makeConstraint(toSuperView, attribute1: .leading, relation: .equal, item2: view, attribute2: .leading, multiplier: 1.0, constant: 0.0)
    let bottom = makeConstraint(toSuperView, attribute1: .bottom, relation: .equal, item2: view, attribute2: .bottom, multiplier: 1.0, constant: 0.0)
    let right = makeConstraint(toSuperView, attribute1: .trailing, relation: .equal, item2: view, attribute2: .trailing, multiplier: 1.0, constant: 0.0)
    toSuperView.addConstraints([top, left, bottom, right])
    toSuperView.layoutIfNeeded()
}

//MARK: Validate Email

func isValidEmail(_ email:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: email)
    return result
}

//MARK: MD5

func md5(_ sender:String) -> String {
    //temp
    let str = sender.cString(using: String.Encoding.utf8)
    let strLen = CUnsignedInt(sender.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    
    CC_MD5(str!, strLen, result)
    
    let hash = NSMutableString()
    for i in 0..<digestLen {
        hash.appendFormat("%02x", result[i])
    }
    
    result.deinitialize()
    
    return String(format: hash as String)
}

//MARK: Localization

func localized(_ key:String?) -> String {
    var string = ""
    if (key != nil) {
        let bundle = BundleLocalization.sharedInstance().localizationBundle
        string = (bundle?.localizedString(forKey: key!, value: "", table: nil))!
    }
    return string
}

func localizedWith1Parameter(_ key:String?, parameter:String?) -> String {
    var string = ""
    if (key != nil && parameter != nil) {
        let bundle = BundleLocalization.sharedInstance().localizationBundle
        if let format = bundle?.localizedString(forKey: key!, value: "", table: nil) {
            string = NSString(format: NSString(string: format), parameter!) as String
        }
    }
    return string
}

func localizedWith2Parameters(_ key:String?, parameter1:String?, parameter2:String?) -> String {
    var string = ""
    if (key != nil && parameter1 != nil && parameter2 != nil) {
        let bundle = BundleLocalization.sharedInstance().localizationBundle
        if let format = bundle?.localizedString(forKey: key!, value: "", table: nil) {
            string = NSString(format: NSString(string: format), parameter1!, parameter2!) as String
        }
    }
    return string
}

//MARK: - Keep me logged in

func keepMeLoggedIn() -> Bool {
    var keepMeLoggenIn = false
    if let value = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("keepMeLoggedIn")) as? Bool {
        keepMeLoggenIn = value
    }
    return keepMeLoggenIn
}

func setKeepMeLoggenIn(_ value:Bool) {
    NSKeyedArchiver.archiveRootObject(value, toFile: filePath("keepMeLoggedIn"))
}

func JWTStillValid() -> Bool {
    var valid = false
    if let jwt = xAPIToken() {
        if let dictionary = decodeJWT(jwt) {
            if let expiryTimeStamp = dictionary["exp"] as? Double {
                let expiryDate = Date(timeIntervalSince1970: expiryTimeStamp)
                if expiryDate.compare(Date()) == .orderedDescending {
                    valid = true
                }
            }
        }
    }
    if valid {
        if let institutionId = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("institutionId")) as? String {
            let fetchRequest:NSFetchRequest<Institution> = NSFetchRequest(entityName: institutionEntityName)
            fetchRequest.predicate = NSPredicate(format: "id == %@", institutionId)
            var institution:Institution?
            do {
                try institution = managedContext.fetch(fetchRequest).first as Institution?
                if institution != nil {
                    dataManager.pickedInstitution = institution
                }
            } catch {}
        }
    }
    if dataManager.pickedInstitution == nil {
        valid = false
    }
    return valid
}

var staffChecked = false

func staff() -> Bool {
    var staff = staffChecked
    if let value = NSKeyedUnarchiver.unarchiveObject(withFile: filePath("staff")) as? Bool {
        staff = value
    }
    return staff
}

func setStaff(_ value:Bool) {
    NSKeyedArchiver.archiveRootObject(value, toFile: filePath("staff"))
}

func social() -> Bool {
    var social = false
    if let user = dataManager.currentStudent {
        social = user.social.boolValue
    }
    return social
}

func demo() -> Bool {
    var demo = false
    if let user = dataManager.currentStudent {
        demo = user.demo.boolValue
    }
    return demo
}

//MARK: - Decode JWT

func base64encode(_ input: Data) -> String {
    let data = input.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0))
    let string = String(data: data, encoding: .utf8)!
    return string
        .replacingOccurrences(of: "+", with: "-", options: NSString.CompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "/", with: "_", options: NSString.CompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "=", with: "", options: NSString.CompareOptions(rawValue: 0), range: nil)
}

func base64decode(_ input: String) -> Data? {
    let rem = input.characters.count % 4
    
    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(repeating: "=", count: amount)
    }
    
    let base64 = input.replacingOccurrences(of: "-", with: "+", options: NSString.CompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "_", with: "/", options: NSString.CompareOptions(rawValue: 0), range: nil) + ending
    
    return Data(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0))
}

func decodeJWT(_ jwt:String) -> NSDictionary? {
    var data:Data?
    let parts = jwt.components(separatedBy: ".")
    if parts.count > 1 {
        data = base64decode(parts[1])
    }
    var dictionary:NSDictionary?
    if let data = data {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            dictionary = jsonObject as? NSDictionary
        } catch {}
    }
    return dictionary
}
