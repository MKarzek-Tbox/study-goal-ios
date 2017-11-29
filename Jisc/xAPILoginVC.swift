//
//  xAPILoginVC.swift
//  Jisc
//
//  Created by Therapy Box on 3/31/16.
//  Copyright © 2016 Therapy Box. All rights reserved.
//

import UIKit

class xAPILoginVC: BaseViewController, UIWebViewDelegate {
    
    @IBOutlet weak var loginWebView:UIWebView!
    
    var idp = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.string(forKey: "uuid") == nil) {
            UserDefaults.standard.set(UUID().uuidString, forKey: "uuid")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        login();
    }
    
    /**
     Closes the developer api login.
     
     :sender: button that triggered the action
     */
    @IBAction func close(_ sender:UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    /**
     logs in the developer account.
     */
    func login(){
        let UUID = UserDefaults.standard.string(forKey: "uuid")
        var urlString = "https://sp.data.alpha.jisc.ac.uk/Shibboleth.sso/Login?entityID=https://"
        urlString += idp
        urlString += "&target=https://sp.data.alpha.jisc.ac.uk/secure/auth.php?u="
        urlString += UUID!
        if shouldRememberMe() {
            urlString += "lt=true"
        }
        
        if let URL = URL(string: urlString) {
            let request = URLRequest(url: URL)
            loginWebView.loadRequest(request)
        }
    }
    
    //MARK: UIWebView Delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        let currentURL = webView.request?.url?.absoluteString
        let elements = currentURL!.components(separatedBy: "?")
        let host: String = elements[0]
        
        if (host == "https://sp.data.alpha.jisc.ac.uk/secure/auth2.php" && elements.count > 1) {
            let encjwt = elements[1]
            if let result = encjwt.removingPercentEncoding {
                let data = result.data(using: String.Encoding.utf8)
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                    
                    if let token = jsonResponse["jwt"] as? String {
                        setXAPIToken(token)
                        
                        webView.alpha = 0.0
                        
                        xAPIManager().getStudentDetails({ (success, result, results, error) in
                            var loginSuccessful = false
                            if let result = result {
                                if let shibID = result["APPSHIB_ID"] as? String {
                                    if (shibID != "null") {
                                        loginSuccessful = true
                                    }
                                }
                            }
                            if (loginSuccessful) {
                                if currentUserType() == .staff {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: result?["STAFF_ID"] as? String)
                                } else {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: xAPILoginCompleteNotification), object: result?["STUDENT_ID"] as? String)
                                }
                                var urlString = ""
                                if(!dataManager.developerMode){
                                    urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=loggedin"
                                } else {
                                    urlString = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/log?verb=loggedin"
                                }
                                xAPIManager().checkMod(testUrl:urlString)
                                var settingsAttendanceURL = ""
                                if(!dataManager.developerMode){
                                    settingsAttendanceURL = "https://api.datax.jisc.ac.uk/sg/setting?setting=attendanceData"
                                } else {
                                    settingsAttendanceURL = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/setting?setting=attendanceData"
                                }
                                var settingsCheckinURL = ""
                                if(!dataManager.developerMode){
                                    settingsCheckinURL = "https://api.datax.jisc.ac.uk/sg/setting?setting=studyGoalAttendance"
                                } else{
                                    settingsCheckinURL = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/setting?setting=studyGoalAttendance"
                                }
                                var settingsAttainmentURL = ""
                                if(!dataManager.developerMode){
                                    settingsAttainmentURL = "https://api.datax.jisc.ac.uk/sg/setting?setting=attainmentData"
                                } else {
                                    settingsAttainmentURL = "https://api.x-dev.data.alpha.jisc.ac.uk/sg/setting?setting=attainmentData"
                                }
                                
                                xAPIManager().settingsCall(testUrl: settingsAttendanceURL)
                                xAPIManager().settingsCall(testUrl: settingsCheckinURL)
                                xAPIManager().settingsCall(testUrl: settingsAttainmentURL)
                                
                                
                                self.dismiss(animated: true, completion: {})
                            } else {
                                self.dismiss(animated: true, completion: {
                                    if let nvc = DELEGATE.window?.rootViewController as? UINavigationController {
                                        let vc:xAPIRegisterVC = xAPIRegisterVC()
                                        vc.idp = self.idp
                                        nvc.present(vc, animated: true, completion: nil)
                                    }
                                })
                            }
                        })
                    }
                } catch {
                    print("json error: \(error)")
                }
            }
        }
    }
}
