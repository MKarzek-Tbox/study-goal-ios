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
        let url = URL(string: "https://github.com/jiscdev/learning-analytics/wiki/Privacy-Statement")
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToPreviousPage(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
