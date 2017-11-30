//
//  CheckinVC.swift
//  Jisc
//
//  Created by Paul on 2/23/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit
import CoreLocation

class CheckinVC: BaseViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var entryField:UILabel!
    var currentPin = ""
    let locationManager = CLLocationManager()
    var didChangeLocationPermissions = false
    var checkingIn = false
    @IBOutlet weak var sendButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryField.adjustsFontSizeToFitWidth = true
        entryField.text = currentPin
        locationManager.delegate = self
        sendButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CLLocationManager.authorizationStatus()
        var locationOn = true
        if (!CLLocationManager.locationServicesEnabled()) {
            locationOn = false
        } else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        } else if ((CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.restricted)) {
            locationOn = false
        }
        if !locationOn {
            let alert = UIAlertController(title: "", message: localized("turn_location_on"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("not_now"), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: localized("take_me_to_settings"), style: .default, handler: { (action) in
                self.didChangeLocationPermissions = true
                UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
            }))
            navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     Adds selected digit to entry field and checks if the field is completed now.
     
     :sender: button that triggered the action
     */
    @IBAction func digit(_ sender:UIButton) {
        currentPin = currentPin + "\(sender.tag)"
        entryField.text = currentPin
        
        if let text = entryField.text {
            if text.characters.count > 0 {
                sendButton.isEnabled = true
                if(text.characters.count > 4) {
                    sendButton.isEnabled = false
                }
            }
        }
        
        view.layoutIfNeeded()
    }
    
    /**
     Deletes the last character from the entry field if there is one available.
     
     :sender: button that triggered the action
     */
    @IBAction func backspace(_ sender:UIButton?) {
        if let text = entryField.text {
            if text.characters.count > 0 {
                currentPin = currentPin.substring(to: currentPin.characters.index(before: currentPin.characters.endIndex))
                entryField.text = currentPin
                
                if(currentPin.characters.count < 5){
                    sendButton.isEnabled = true
                }
                if(currentPin.characters.count == 0) {
                    sendButton.isEnabled = false
                }
                
                view.layoutIfNeeded()
            }
        }
    }
    
    /**
     Sends the PIN to the server.
     
     :sender: button that triggered the action
     */
    @IBAction func sendPin(_ sender:UIButton?) {
        sendButton.isEnabled = false
        if currentUserType() == .staff {
            let alert = UIAlertController(title: "", message: localized("checkin_staff_message"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
            sendButton.isEnabled = true
        } else {
            if currentPin.isEmpty {
                let alert = UIAlertController(title: "", message: localized("enter_pin"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
                navigationController?.present(alert, animated: true, completion: nil)
            } else {
                checkingIn = true
                CLLocationManager.authorizationStatus()
                var locationOn = true
                if (!CLLocationManager.locationServicesEnabled()) {
                    locationOn = false
                } else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
                    locationManager.requestWhenInUseAuthorization()
                } else if ((CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.restricted)) {
                    locationOn = false
                } else {
                    locationManager.startUpdatingLocation()
                }
                if !locationOn {
                    let alert = UIAlertController(title: "", message: localized("turn_location_on"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: localized("not_now"), style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: localized("take_me_to_settings"), style: .default, handler: { (action) in
                        self.didChangeLocationPermissions = true
                        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                    }))
                    navigationController?.present(alert, animated: true, completion: nil)
                }
                sendButton.isEnabled = true
            }
        }
    }
    
    /**
     Opens the menu drawer.
     
     :sender: button that triggered the action
     */
    @IBAction func openMenu(_ sender: Any) {
        DELEGATE.menuView?.open()
    }
    
    //MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if checkingIn {
            checkingIn = false
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            let date = Date()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let part1 = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "HH:mm:ss"
            let part2 = dateFormatter.string(from: date)
            let timestamp = "\(part1)T\(part2)Z"
            xAPIManager().checkIn(pin: currentPin, location: "\(location.coordinate.latitude),\(location.coordinate.longitude)", timestamp: timestamp, completion: { (success, dictionary, array, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Server Error", message: "Our servers our currently experiencing difficulties", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
                        UIAlertAction in
                        NSLog("Ok Pressed")
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel){
                        UIAlertAction in
                        NSLog("Cancel Pressed")
                    }
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                if array != nil {
                    let alert = UIAlertController(title: "", message: localized("alert_valid_pin"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: { (action) in
                        if self.didChangeLocationPermissions {
                            self.didChangeLocationPermissions = false
                            let alert = UIAlertController(title: "", message: localized("turn_location_off"), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: localized("yes"), style: .default, handler: { (action) in
                                UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                            }))
                            alert.addAction(UIAlertAction(title: localized("not_now"), style: .cancel, handler: nil))
                            self.navigationController?.present(alert, animated: true, completion: nil)
                        }
                    }))
                    self.navigationController?.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "", message: localized("alert_invalid_pin"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: { (action) in
                        if self.didChangeLocationPermissions {
                            self.didChangeLocationPermissions = false
                            let alert = UIAlertController(title: "", message: localized("turn_location_off"), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: localized("yes"), style: .default, handler: { (action) in
                                UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                            }))
                            alert.addAction(UIAlertAction(title: localized("not_now"), style: .cancel, handler: nil))
                            self.navigationController?.present(alert, animated: true, completion: nil)
                        }
                    }))
                    self.navigationController?.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
}
