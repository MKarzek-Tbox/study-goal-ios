//
//  AppDelegate.swift
//  Jisc
//
//  Created by Therapy Box on 10/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import FBSDKLoginKit
import Google
import TwitterKit
import Fabric
import Crashlytics

enum kAppLanguage:String {
    case English = "en"
    case Welsh = "cy"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {
    
    var window: UIWindow?
    var mainNavigationController:UINavigationController?
    var menuView:MenuView?
    var playerController:UIViewController?
    var recurringVC:RecurringTargetVC?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        window!.layer.addSublayer(CALayer())
        
        setAppLanguage(.english)
        
        initializeApp()
        
        reachability?.whenReachable = {
            _ in internetAvailability = .reachable
        }
        reachability?.whenUnreachable = {
            _ in internetAvailability = .notReachable
        }
        
        do {
            try reachability?.startNotifier()
        } catch {}
        
        if let reachability = reachability  {
            if reachability.isReachable  {
                internetAvailability = .reachable
            } else {
                internetAvailability = .notReachable
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let sampleTextField = UITextField()
        sampleTextField.autocorrectionType = .no
        DELEGATE.window?.addSubview(sampleTextField)
        sampleTextField.becomeFirstResponder()
        sampleTextField.resignFirstResponder()
        sampleTextField.removeFromSuperview()
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func initializeApp() {
        
        playerController = UIViewController()
        window?.rootViewController = playerController
        dataManager.initialize()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) { () -> Void in
            let vc = LoginVC()
            self.mainNavigationController = UINavigationController(rootViewController: vc)
            self.mainNavigationController?.isNavigationBarHidden = true
            self.window?.rootViewController = self.mainNavigationController
            self.playerController = nil
        }
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardFrame.size.height
            }
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let facebook = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        if !facebook {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        } else {
            return facebook
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) { }
    
    func applicationDidEnterBackground(_ application: UIApplication) { }
    
    func applicationWillEnterForeground(_ application: UIApplication) { }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if let userInfo = notification.userInfo {
            if let isPush = userInfo["push"] as? Bool {
                if isPush {
                    if let title = userInfo["title"] as? String {
                        UIAlertView(title: title, message: notification.alertBody, delegate: nil, cancelButtonTitle: "Ok").show()
                    } else {
                        UIAlertView(title: "Notification", message: notification.alertBody, delegate: nil, cancelButtonTitle: "Ok").show()
                    }
                } else {
                    UIAlertView(title: "Time to take a break", message: notification.alertBody, delegate: nil, cancelButtonTitle: "Ok").show()
                }
            } else {
                UIAlertView(title: "Time to take a break", message: notification.alertBody, delegate: nil, cancelButtonTitle: "Ok").show()
            }
        } else {
            UIAlertView(title: "Time to take a break", message: notification.alertBody, delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    //MARK: - Remote Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let dev = deviceToken as NSData
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        let deviceTokenString: String = (dev.description as NSString).trimmingCharacters(in: characterSet).replacingOccurrences(of: " ", with:"") as String
        devicePushToken = deviceTokenString
        if let user = dataManager.currentStudent {
            DownloadManager().registerForRemoteNotifications(studentId: user.id, isActive: 1, alertAboutInternet: false, completion: { (success, dictionary, array, error) in
                
            })
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let aps = userInfo["aps"] as? [AnyHashable:Any] {
            if let alert = aps["alert"] as? [AnyHashable:Any] {
                if let message = alert["body"] as? String {
                    let notification = UILocalNotification()
                    notification.alertAction = "Ok"
                    notification.alertBody = message
                    notification.fireDate = Date().addingTimeInterval(1.0)
                    notification.userInfo = ["push":true, "title":"Notification"]
                    application.scheduleLocalNotification(notification)
                }
            } else if let alert = aps["alert"] as? String {
                let notification = UILocalNotification()
                notification.alertAction = "Ok"
                notification.alertBody = alert
                notification.fireDate = Date().addingTimeInterval(1.0)
                notification.userInfo = ["push":true, "title":"Notification"]
                application.scheduleLocalNotification(notification)
            }
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Jisc" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Jisc", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true])
        } catch {
            // Report any errors
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () { }
    
    //MARK: Print Download Result
    
    func printDownloadResult(_ success:Bool, result:NSDictionary?, results:NSArray?, error:String?) {
        if (!success) {
            if let error = error {
                print("Download manager error:\n\(error)")
            } else {
                print("Download manager error: nil error")
            }
        } else if (result != nil) {
            print("response dictionary:\n\(result!)")
        } else if (results != nil) {
            print("response array:\n\(results!)")
        } else {
            print("all objects are nil")
        }
        print("")
    }
    
    //MARK: Orientation
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (iPad) {
            return supportedInterfaceOrientationsForIPad
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    //MARK: UIAlertView Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        internetAlertIsPresent = false
    }
}

