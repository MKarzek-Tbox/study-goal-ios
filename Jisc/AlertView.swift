//
//  AlertView.swift
//  Jisc
//
//  Created by Therapy Box on 10/21/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//
//  This is the view used for almost all the notifications that the user receives inside the app

import UIKit

class AlertView: UIView {
    
    @IBOutlet weak var iconImage:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    
    class func showAlert(_ success:Bool, message:String, completion: ((Bool) -> Void)?) {
        var displayedMessage = message
        if !success && message.isEmpty {
            displayedMessage = kDefaultFailureReason
        }
        let view:AlertView = Bundle.main.loadNibNamed("AlertView", owner: nil, options: nil)!.first as! AlertView
        if (success) {
            view.iconImage.image = UIImage(named: "alertCheckmark")
        } else {
            view.iconImage.image = UIImage(named: "alertFailmark")
        }
        view.titleLabel.text = displayedMessage
        view.frame = UIScreen.main.bounds
        view.alpha = 0
        DELEGATE.window?.addSubview(view)
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            view.alpha = 1.0
        }, completion: { (done) -> Void in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                view.alpha = 0.0
            }) { (done) -> Void in
                view.removeFromSuperview()
                if (completion != nil) {
                    completion!(done)
                }
            }
        }) 
    }
}
