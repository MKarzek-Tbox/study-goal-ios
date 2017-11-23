//
//  xAPIManager.swift
//  Jisc
//
//  Created by Therapy Box on 3/15/16.
//  Copyright © 2016 Therapy Box. All rights reserved.
//

import Foundation
import UIKit

let xAPIHostPath = "https://app.analytics.alpha.jisc.ac.uk/"
let xAPIHostName = NSURL(string: hostPath)?.host

let xAPIGetIDPSPath = "idps"
let xAPIGetActivityPointsPath = "v2/activity/points"
let xAPIGetEngagementDataPath = "v2/engagement"
let xAPIGetModulesPath = "v2/filter"
let xAPIGetAttainmentPath = "v2/attainment"
let xAPIGetComparisonToTop10PercentPath = "v2/engagement"
var xAPIGetEventsAttendedPath = "https://api.datax.jisc.ac.uk/sg/attendance?"
let xAPIGetAppUsagePath = "https://stuapp.analytics.alpha.jisc.ac.uk/fn_get_appusage"
let xAPIEditToDoPath = "fn_edit_todo_task?"

typealias xAPICompletionBlock = ((_ success:Bool, _ result:NSDictionary?, _ results:NSArray?, _ error:String?) -> Void)

enum kXAPIEngagementScope: String {
    case Overall = "overall"
    case SevenDays = "7d"
    case ThirtyDays = "28d"
}

enum kXAPIEngagementFilterType: String {
    case Course = "course"
    case Module = "module"
}

enum kXAPIEngagementCompareType: String {
    case Average = "average"
    case Friend = "friend"
    case Top = "top"
}

enum kXAPIActivityPointsPeriod: String {
    case Overall = "overall"
    case SevenDays = "7d"
}

struct EngagementGraphOptions {
    var scope:kXAPIEngagementScope?
    var filterType:kXAPIEngagementFilterType?
    var filterValue:String?
    var compareType:kXAPIEngagementCompareType?
    var compareValue:String?
}

class xAPIManager: NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {

    var rawData:NSMutableData = NSMutableData()
    var completionBlock:downloadCompletionBlock?
    var silent:Bool = inheritSilent
    var connectionSuccessfull:Bool = false
    var code:kRequestStatusCode?
    var shouldNotifyAboutInternetConnection:Bool = true
    
    override init(){
        super.init()
        if(dataManager.developerMode){
            xAPIGetEventsAttendedPath = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/attendance?"
        }
    }
    
    //MARK: NSURLConnection Data Delegate

    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        rawData.append(data)
    }
    //    func getEventsAttended(skip:Int, limit:Int, completion:@escaping xAPICompletionBlock) {
    //        completionBlock = completion
    //        var request:URLRequest?
    //        if let url = urlWithHost(xAPIGetEventsAttendedPath, path: "skip=\(skip)&limit=\(limit)") {
    //            request = URLRequest(url: url)
    //        }
    //        if let token = xAPIToken() {
    //            request?.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    //            print("\(token)")
    //        }
    //        startConnectionWithRequest(request)
    //        print()
    //    }
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        let httpResponse = response as? HTTPURLResponse;
        if (httpResponse != nil) {
            code = kRequestStatusCode(rawValue:httpResponse!.statusCode)
            if (code != nil) {
                if (LOG_ACTIVITY && connection.originalRequest.url?.absoluteString != nil) {
                    print("\(connection.originalRequest.url!.absoluteString) - code: \(code!)")
                }
                if (code == .ok || code == .noContent) {
                    connectionSuccessfull = true
                }

                //				if (code == .unauthorized) {
                //					completionBlock = nil
                //
                //					dataManager.logout()
                //					UIAlertView(title: localized("session_expired_title"), message: localized("session_expired_message"), delegate: nil, cancelButtonTitle: localized("ok")).show()
                //				}
            }
        }
    }

    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        if (!silent) {
            LoadingView.hide()
        }
        if (completionBlock != nil) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: rawData as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                let dictionary:NSDictionary? = jsonObject as? NSDictionary
                if (dictionary != nil) {
                    if (LOG_ACTIVITY) {
                        DELEGATE.printDownloadResult(true, result: dictionary, results: nil, error: nil)
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        if (self.code == .noContent) {
                            self.completionBlock!(true, nil, nil, nil)
                        } else {
                            self.completionBlock!(true, dictionary, nil, nil)
                        }
                    })
                } else {
                    let array:NSArray? = jsonObject as? NSArray
                    if (array != nil) {
                        if (LOG_ACTIVITY) {
                            DELEGATE.printDownloadResult(true, result: nil, results: array, error: nil)
                        }
                        DispatchQueue.main.async(execute: { () -> Void in
                            if (self.code == .noContent) {
                                self.completionBlock!(true, nil, nil, nil)
                            } else {
                                self.completionBlock!(true, nil, array, nil)
                            }
                        })
                    }
                }
            } catch {
                let string = String(data: rawData as Data, encoding: String.Encoding.utf8)

                if (string != nil) {
                    if (connection.originalRequest.url?.absoluteString != nil) {
                        print("\(connection.originalRequest.url!.absoluteString) - Received data to string: |\(string!)|")
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        if (self.connectionSuccessfull) {
                            if (LOG_ACTIVITY) {
                                DELEGATE.printDownloadResult(true, result: ["message":string!], results: nil, error: nil)
                            }
                            if (self.code == .noContent) {
                                self.completionBlock!(true, nil, nil, nil)
                            } else {
                                self.completionBlock!(true, ["message":string!], nil, string!)
                            }
                        } else {
                            self.completionBlock!(false, nil, nil, string!)
                            if (LOG_ACTIVITY) {
                                DELEGATE.printDownloadResult(false, result: nil, results: nil, error: string!)
                            }
                        }
                    })
                } else {
                    print("Could not convert received data to string. Data length = \(rawData.length)")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.completionBlock!(false, nil, nil, "Unknown connection error.")
                        if (LOG_ACTIVITY) {
                            DELEGATE.printDownloadResult(false, result: nil, results: nil, error: "Unknown connection error.")
                        }
                    })
                }
            }
        }
    }

    //MARK: NSURLConnection Delegate

    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        if (!silent) {
            LoadingView.hide()
        }
        if (completionBlock != nil) {
            if (LOG_ACTIVITY) {
                DELEGATE.printDownloadResult(false, result: nil, results: nil, error: error.localizedDescription)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.completionBlock!(false, nil, nil, error.localizedDescription)
            })
        }
    }

    //MARK: Helpful Functions

    func urlWithHost(_ host:String, path:String) -> URL? {
        let fullPath = "\(host)\(path)"
        let theURL:URL? = URL(string: fullPath)
        return theURL
    }

    func urlWithPath(_ path:String) -> URL? {
        let fullPath = "\(xAPIHostPath)\(path)"
        var theURL = URL(string: "")
        if let escapedString = fullPath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let url = URL(string: escapedString) {
                theURL = url
            } else {
                print("URL failed: \(fullPath)")
            }
        }
        return theURL
    }
    
    func urlWithoutPath(_ path:String) -> URL? {
        let fullPath = "\(path)"
        var theURL = URL(string: "")
        if let escapedString = fullPath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let url = URL(string: escapedString) {
                theURL = url
            } else {
                print("URL failed: \(fullPath)")
            }
        }
        return theURL
    }

    func createGetRequest(_ path:String, withJWT:Bool) -> URLRequest? {
        var request:URLRequest?
        if let url = urlWithPath(path) {
            request = URLRequest(url: url)
            print("url is \(url)")
            if (withJWT) {
                if let token = xAPIToken() {
                    request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
                }
            }
        }
        return request
    }
    func createGetRequestWithFullPath(_ path:String, withJWT:Bool) -> URLRequest? {
        var request:URLRequest?
        if let url = urlWithoutPath(path) {
            request = URLRequest(url: url)
            if (withJWT) {
                if let token = xAPIToken() {
                    request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
                }
            }
        }
        return request
    }

    func bodyStringFromDictionary(_ dictionary:[String:String]) -> String {
        var string:String = ""
        let elements:NSMutableArray = NSMutableArray()
        let newDictionary:NSMutableDictionary = NSMutableDictionary(dictionary: dictionary)

        for key in newDictionary.allKeys
        {
            let argumentString:String? = key as? String
            let objectString:String? = newDictionary.object(forKey: key) as? String

            if (argumentString == nil) {
                print("key is nil")
                continue
            }

            if (objectString == nil) {
                print("object is nil")
                continue
            }

            elements.add("\(argumentString!)=\(objectString!)")
        }

        string = elements.componentsJoined(by: "&")

        let escapedString:String? = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        if (escapedString != nil) {
            string = escapedString!
        }

        if (LOG_ACTIVITY) {
            print("body string:\n\(string)")
        }

        if (LOG_ACTIVITY) {
            let separator = "&"
            let array:[String] = string.components(separatedBy: separator)
            print("\(array)")
        }

        return string
    }

    func createPostRequest(_ path:String, bodyString:String)  -> URLRequest? {
        let postData:Data? = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        var request:URLRequest?
        if let url = urlWithPath(path) {
            request = URLRequest(url: url)
        }
        if let token = xAPIToken() {
            request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
        }
        request?.httpMethod = "POST"
        if (postData != nil) {
            request?.setValue("\(postData!.count)", forHTTPHeaderField: "Content-Length")
            request?.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
        request?.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }

    func createPutRequest(_ path:String, bodyString:String)  -> URLRequest? {
        let postData:Data? = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        var request:URLRequest?
        if let url = urlWithPath(path) {
            request = URLRequest(url: url)
        }
        if let token = xAPIToken() {
            request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
        }
        request?.httpMethod = "PUT"
        if (postData != nil) {
            request?.setValue("\(postData!.count)", forHTTPHeaderField: "Content-Length")
            request?.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
        request?.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }

    func createDeleteRequest(_ path:String)  -> URLRequest? {
        var request:URLRequest?
        if let url = urlWithPath(path) {
            request = URLRequest(url: url)
        }
        if let token = xAPIToken() {
            request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
        }
        request?.httpMethod = "DELETE"
        return request
    }

    func createProfileImageUploadRequest(_ path: String, myID:String, image:UIImage) -> URLRequest?
    {
        var request:URLRequest?
        if let url = urlWithPath(path) {
            request = URLRequest(url: url)
        }
        if let token = xAPIToken() {
            request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
        }
        request?.httpMethod = "POST"

        let boundary = "---------------------------14737809831466499882746641449"

        let contentType = NSString(format: "multipart/form-data; boundary=%@", boundary)
        request?.addValue(contentType as String, forHTTPHeaderField: "Content-Type")

        let body = NSMutableData()

        var data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
        body.append(data!)
        data = (NSString(format: "Content-Disposition: form-data; name=\"student_id\"\r\n\r\n%@", myID)).data(using: String.Encoding.utf8.rawValue)
        body.append(data!)

        data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
        body.append(data!)
        var language = "en"
        if let newLanguage = BundleLocalization.sharedInstance().language {
            language = newLanguage
        }
        data = (NSString(format: "Content-Disposition: form-data; name=\"language\"\r\n\r\n%@", language)).data(using: String.Encoding.utf8.rawValue)
        body.append(data!)

        data = (NSString(format: "\r\n--%@\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
        body.append(data!)
        let fileName = "\(myID)_\(Date().timeIntervalSince1970)"
        let string = NSString(format: "Content-Disposition: attachment; name=\"profile_photo\"; filename=\"%@.png\"\r\nContent-Type: image/png\r\n\r\n", fileName)
        data = NSString(string: string).data(using: String.Encoding.utf8.rawValue)
        body.append(data!)
        var imageData = UIImageJPEGRepresentation(image, 1.0)!
        var newImage = image
        while (imageData.count >= maximumImageSizeInBytes) {
            newImage = UIImage.scaleImage(newImage, toSize: CGSize(width: newImage.size.width * 0.9, height: newImage.size.height * 0.9))
            imageData = UIImageJPEGRepresentation(newImage, 1.0)!
        }
        body.append(imageData)

        data = (NSString(format: "\r\n--%@--\r\n", boundary)).data(using: String.Encoding.utf8.rawValue)
        body.append(data!)

        request?.httpBody = body as Data

        return request
    }

    func startConnectionWithRequest(_ request:URLRequest?) {
        if let request = request {
            if (internetAvailability == ReachabilityStatus.notInitialized) {
                let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(xAPIManager.delayedConnection(_:)), userInfo: request, repeats: false)
                RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
            } else if (internetAvailability == ReachabilityStatus.notReachable) {
                if (shouldNotifyAboutInternetConnection && !internetAlertIsPresent) {
                    internetAlertIsPresent = true
                    UIAlertView(title: localized("connection_problem"), message: localized("check_internet"), delegate: DELEGATE, cancelButtonTitle: localized("ok")).show()
                }
                completionBlock?(false, nil, nil, nil)
            } else {
                if (!silent) {
                    LoadingView.show()
                }
                let connection:NSURLConnection? = NSURLConnection(request: request, delegate: self, startImmediately: false)
                connection?.start()

                if (request.url?.absoluteString != nil && LOG_ACTIVITY) {
                    let method:String? = request.httpMethod
                    if (method != nil) {
                        print(method!)
                    }
                    print("Request URL:\n\(request.url!.absoluteString)")
                }
            }
        } else {
            completionBlock?(false, nil, nil, "Error creating the url request")
        }
    }

    func delayedConnection(_ timer:Timer) {
        startConnectionWithRequest(timer.userInfo as? URLRequest)
    }

    //MARK: Download Functions

    func getStudentDetails(_ completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        var request:URLRequest?
        if currentUserType() == .staff {
            if let url = urlWithHost("https://sp.data.alpha.jisc.ac.uk/", path: "staff/") {
                request = URLRequest(url: url)
            }
        } else {
            if let url = urlWithHost("https://sp.data.alpha.jisc.ac.uk/", path: "student/") {
                request = URLRequest(url: url)
            }
        }
        if let token = xAPIToken() {
            request?.addValue("Bearer \(token)\"}", forHTTPHeaderField: "Authorization")
        }
        startConnectionWithRequest(request)
    }

    func getIDPS(_ completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        startConnectionWithRequest(createGetRequest(xAPIGetIDPSPath, withJWT: false))
    }

    func getActivityPoints(_ period:kXAPIActivityPointsPeriod, completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        if(!demo()) {
            startConnectionWithRequest(createGetRequestWithFullPath("https://app.analytics.alpha.jisc.ac.uk/v2/activity/points?scope=\(period.rawValue)", withJWT: true))
        } else {
            if(period.rawValue == "7d"){
                startConnectionWithRequest(createGetRequestWithFullPath("https://stuapp.analytics.alpha.jisc.ac.uk/fn_fake_activity_7d", withJWT: true))
            } else {
                startConnectionWithRequest(createGetRequestWithFullPath("https://stuapp.analytics.alpha.jisc.ac.uk/fn_fake_activity_28d", withJWT: true))
            }
        }
    }
    func getEventsAttended(skip:Int, limit:Int, completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        var request:URLRequest?
        if(!demo()){
            if let url = urlWithHost(xAPIGetEventsAttendedPath, path: "skip=\(skip)&limit=\(limit)") {
                request = URLRequest(url: url)
            }
        } else {
            if let url = urlWithoutPath("https://stuapp.analytics.alpha.jisc.ac.uk/fn_fake_attendance") {
                request = URLRequest(url: url)
            }
        }
        if let token = xAPIToken() {
            request?.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        startConnectionWithRequest(request)
        print()
    }
    func getModules(_ completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        startConnectionWithRequest(createGetRequest(xAPIGetModulesPath, withJWT: true))
    }

    func getModuleTest(_ completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        startConnectionWithRequest(createGetRequest("module/test?scope=overall", withJWT: true))
    }

    func getAttainment(_ completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        if(demo()){
            startConnectionWithRequest(createGetRequestWithFullPath("https://stuapp.analytics.alpha.jisc.ac.uk/fn_fake_attainment", withJWT: true))
        } else {
           startConnectionWithRequest(createGetRequestWithFullPath("https://app.analytics.alpha.jisc.ac.uk/v2/attainment", withJWT: true))
        }
    }

    func callEventsAttended(){
        print("This is from XAPI Manager Events attended")
        //        let statsClass = StatsVC()
        //        statsClass.getEventsAttended {
        //            print("requested events attended")
        //        }
    }

    func getEngagementData(_ options:EngagementGraphOptions, completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        var path = xAPIGetEngagementDataPath

        var parameters = [String]()
        if let scope = options.scope {
            parameters.append("scope=\(scope.rawValue)")
        }
        if let filterType = options.filterType {
            parameters.append("filterType=\(filterType.rawValue)")
        }
        if let filterValue = options.filterValue {
            parameters.append("filterValue=\(filterValue)")
        }
        if let compareType = options.compareType {
            parameters.append("compareType=\(compareType.rawValue)")
        }
        if let compareValue = options.compareValue {
            parameters.append("compareValue=\(compareValue)")
        }
        if parameters.count > 0 {
            path = "\(path)?\((parameters as NSArray).componentsJoined(by: "&"))"
        }
        if(demo()){
            startConnectionWithRequest(createGetRequestWithFullPath("https://stuapp.analytics.alpha.jisc.ac.uk/fn_fake_vle_activity", withJWT: true))
        } else {
            startConnectionWithRequest(createGetRequestWithFullPath("https://app.analytics.alpha.jisc.ac.uk/\(path)", withJWT: true))
        }
    }
    func checkMod(testUrl:String){
        var request:URLRequest?
        if let urlString = testUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
        }
        if var request = request {
            if let token = xAPIToken() {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
                print("the url used in making the call", testUrl)
            }
            //startConnectionWithRequest(request)
        } else {
            completionBlock?(false, nil, nil, "Error creating the url request")
        }
    }
    func getWithResult(testUrl:String){
        var request:URLRequest?
        if let urlString = testUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
        }
        if var request = request {
            if let token = xAPIToken() {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
                do {
                    if let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                        print("This is the JSON", json)
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
            }
            //startConnectionWithRequest(request)
        } else {
            completionBlock?(false, nil, nil, "Error creating the url request")
        }
    }
    func postRequest(testUrl:String, body:String) -> Bool{
        var request:URLRequest?
        var somethingWentWrong = false
        if let urlString = testUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
        }
        if var request = request {
            if let token = xAPIToken() {
                request.addValue("\(token)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"

                request.httpBody = body.data(using: .utf8)
            }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(error!)")
                    somethingWentWrong = true
                    return
                }

                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response!)")
                    somethingWentWrong = true
                }

                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString!)")
                somethingWentWrong = false
            }
            task.resume()
        }
        return somethingWentWrong
    }

    func settingsCall(testUrl:String){
        var request:URLRequest?
        var returnedString:String = ""
        if let urlString = testUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
        }
        if var request = request {
            if let token = xAPIToken() {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
                returnedString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                print("returned String is: \(returnedString)")
                print("response from server \(String(describing: response))")

                if (testUrl=="https://api.datax.jisc.ac.uk/sg/setting?setting=studyGoalAttendance"){
                    let defaults = UserDefaults.standard
                    defaults.set(returnedString, forKey: "SettingsReturn")
                } else if (testUrl=="https://api.datax.jisc.ac.uk/sg/setting?setting=attendanceData") {
                    let defaults = UserDefaults.standard
                    defaults.set(returnedString, forKey: "SettingsReturnAttendance")
                }
            }
            //startConnectionWithRequest(request)
        } else {
            completionBlock?(false, nil, nil, "Error creating the url request")
        }
    }
    func checkIn(pin:String, location:String, timestamp:String, completion:@escaping xAPICompletionBlock) {
        completionBlock = completion
        var request:URLRequest?
        if let urlString = "https://api.datax.jisc.ac.uk/att/checkin?checkinpin=\(pin)&geo_tag=\(location)&timestamp=\(timestamp)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
        }
        if var request = request {
            if let token = xAPIToken() {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            startConnectionWithRequest(request)
        } else {
            completionBlock?(false, nil, nil, "Error creating the url request")
        }
    }

    func getAppUsage(studentId:String, startDate:String, endDate:String) {
        //print("made it to the call")
        var urlPath = ""
        if(startDate == "null" && endDate == "null"){
            urlPath = xAPIGetAppUsagePath + "?student_id=" + studentId
        }
        else{
            urlPath = xAPIGetAppUsagePath + "?student_id=" + studentId + "&start_date=" + startDate + "&end_date=" + endDate
        }

        if let url = URL(string: urlPath){
            print("calling for app usage data")
            print("url " + urlPath)

            //let session = URLSession.shared
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "GET"
            if let token = xAPIToken() {
                request.addValue("\(token)", forHTTPHeaderField: "Authorization")
            } else {
                print("error with token")
                return
            }

            let dataCallTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if error != nil {
                    print("error on getting data from url")
                } else {
                    if let jsondata = data{
                        print("\(jsondata)")
                        do {
                            let json = try JSONSerialization.jsonObject(with: jsondata) as! [String: Any]
                            print("json found")
                            print("json for app usage \(json)")
                            let defaults = UserDefaults.standard

                            let met_targets_number = json["met_targets_number"] as! [String: Any]
                            let metRecurringTargets = met_targets_number["recurring targets"] as! Int
                            let metSingleTargets = met_targets_number["todo tasks"] as! Int

                            let metTargets = metRecurringTargets + metSingleTargets

                            print("metTargets \(metTargets)")
                            defaults.set(metTargets, forKey: "AppUsage_targets_met")


                            let failed_targets_number = json["failed_targets_number"] as! [String: Any]
                            let failedRecurringTargets = failed_targets_number["recurring targets"] as! Int
                            let failedSingleTargets = failed_targets_number["todo tasks"] as! Int

                            let failedTargets = failedRecurringTargets + failedSingleTargets

                            print("failedTargets \(failedTargets)")
                            defaults.set(failedTargets, forKey: "AppUsage_targets_failed")


                            let set_targets_number = json["set_targets_number"] as! [String: Any]
                            let setRecurringTargets = set_targets_number["recurring targets"] as! Int
                            let setSingleTargets = set_targets_number["todo tasks"] as! Int
                            let setTargets = setRecurringTargets + setSingleTargets
                            print("setTargets \(setTargets)")

                            defaults.set(setTargets, forKey: "AppUsage_targets_set")

                            let activityHours = (json["activity_logged_hours"] as! Int)/60
                            defaults.set(activityHours, forKey: "AppUsage_activities")
                            var sessions = json["number_of_sessions"]!
                            defaults.set(sessions, forKey: "AppUsage_sessions")

                            print("app usage set values \(metTargets) \(failedTargets) \(setTargets) \(activityHours) \(json["number_of_sessions"]!)")
                        } catch {
                            print("error on JSONSerialization")
                        }
                    }
                }
            }
            dataCallTask.resume()
        }
    }

    func editSingleTarget(body: String) -> URLRequest? {
        print("made it to the call")
        var urlPath = xAPIEditToDoPath

        let postData:Data? = body.data(using: String.Encoding.utf8, allowLossyConversion: true)
        var request:URLRequest?

        if let url = urlWithPath(urlPath) {
            print("edittodo calling for edit todo target")
            print("edittodo url " + urlPath)
            request = URLRequest(url: url)
        } else {
            print("edittodo url not created")
        }

        if let token = xAPIToken() {
            request?.addValue("\(token)\"}", forHTTPHeaderField: "Authorization")
        } else {
            print("edittodo token not found")
        }

        request?.httpMethod = "POST"
        if (postData != nil) {
            request?.setValue("\(postData!.count)", forHTTPHeaderField: "Content-Length")
            request?.httpBody = body.data(using: String.Encoding.utf8, allowLossyConversion: true)
            print("edittodo \(request?.url)")
            print("edittodo \(request?.httpBody)")
            print("edittodo \(request?.allHTTPHeaderFields)")
        } else {
            print("edittodo post data nil")
        }

        request?.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }
}
