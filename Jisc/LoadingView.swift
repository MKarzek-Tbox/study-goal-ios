//
//  LoadingView.swift
//  Jisc
//
//  Created by Therapy Box on 10/19/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

var loadingView:LoadingView?

// These 2 values assure that only one loading view will be present on the screen at a given time
var isLoadingViewPresent:Bool = false
var loadingViewsOnScreen:Int = 0

class LoadingView: UIView {
    
    var loadingActivity:UIActivityIndicatorView?
    
    class func show() {
        loadingViewsOnScreen += 1
        if (!isLoadingViewPresent)  {
            loadingView = Bundle.main.loadNibNamed("LoadingView", owner: nil, options: nil)?.first as? LoadingView
            loadingView?.alpha = 0.0
            loadingView?.frame = DELEGATE.window!.bounds
            if (loadingView != nil) {
                isLoadingViewPresent = true
                DELEGATE.window?.addSubview(loadingView!)
                loadingView?.alpha = 1.0
                loadingView!.layoutIfNeeded()
                
                loadingView!.loadingActivity = UIActivityIndicatorView()
                loadingView!.loadingActivity?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
                loadingView!.loadingActivity?.center = CGPoint(x: loadingView!.frame.size.width / 2, y: loadingView!.frame.size.height / 2)
                
                if (loadingView!.loadingActivity != nil) {
                    loadingView!.addSubview(loadingView!.loadingActivity!)
                    loadingView!.loadingActivity?.startAnimating()
                }
            }
        }
    }
    
    class func hide() {
        if (isLoadingViewPresent) {
            loadingViewsOnScreen -= 1
            if (loadingViewsOnScreen == 0) {
                isLoadingViewPresent = false
                
                if (loadingView != nil) {
                    loadingView!.loadingActivity?.stopAnimating()
                    loadingView!.removeFromSuperview()
                }
            }
        }
    }
}
