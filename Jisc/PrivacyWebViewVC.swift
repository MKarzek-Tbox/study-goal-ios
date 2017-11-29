//
//  PrivacyWebViewVC.swift
//  Jisc
//
//  Created by 王適緣 on 2017/7/18.
//  Copyright © 2017年 XGRoup. All rights reserved.
//

import UIKit

class PrivacyWebViewVC: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let language = getAppLanguage()
        var url:URL
        
        if (language.rawValue==0){
            url = URL(string: "https://docs.analytics.alpha.jisc.ac.uk/docs/learning-analytics/Privacy-Statement")!
        } else {
            url = URL(string: "https://docs.analytics.alpha.jisc.ac.uk/docs/learning-analytics/Privacy-Statement")!
        }
        
        let requestObj = URLRequest(url: url)
        webView.loadRequest(requestObj)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backToPreviousPage(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
}
