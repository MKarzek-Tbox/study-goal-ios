//
//  TermsViewController.swift
//  Jisc
//
//  Created by Therapy Box on 16/08/2017.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {
    
    @IBOutlet weak var termsWebView: UIWebView!
    @IBOutlet weak var disagreeButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let authorizationURL = URL(string:"https://docs.analytics.alpha.jisc.ac.uk/docs/study-goal/App-service-terms-and-conditions")
        let request = URLRequest(url: authorizationURL!)
        termsWebView.loadRequest(request)
    }
    
    @IBAction func agreeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        DELEGATE.menuView = MenuView.createView()
        
    }
    
    @IBAction func disagreeAction(_ sender: Any) {
        let vc = LoginVC()
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}
