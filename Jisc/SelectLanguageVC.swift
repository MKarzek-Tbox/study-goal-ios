//
//  SelectLanguageVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/22/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

class SelectLanguageVC: BaseViewController {
    
    @IBOutlet weak var englishCheckmark:UIImageView!
    @IBOutlet weak var welshCheckmark:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        highlightSelectedItem()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    /**
     Highlights the selected item.
     */
    func highlightSelectedItem() {
        englishCheckmark.alpha = 0.0
        welshCheckmark.alpha = 0.0
        
        let selectedLanguage = getAppLanguage()
        
        switch (selectedLanguage) {
        case .english:
            englishCheckmark.alpha = 1.0
        case .welsh:
            welshCheckmark.alpha = 1.0
        }
    }
    
    /**
     Navigates back to settings.
     
     :sender: button that triggered the action
     */
    @IBAction func goBack(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /**
     Sets the selected item as language for the app.
     
     :sender: button that triggered the action
     */
    @IBAction func selectLanguage(_ sender:UIButton) {
        if currentUserType() == .demo {
            let alert = UIAlertController(title: "", message: localized("demo_mode_change_app_settings"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
        } else {
            var selectedLanguage = kLanguage(rawValue: sender.tag)
            if (getAppLanguage() != selectedLanguage) {
                setAppLanguage(selectedLanguage)
                if (selectedLanguage == nil) {
                    selectedLanguage = .english
                }
                runningActivititesTimer.invalidate()
                DELEGATE.menuView?.feedViewController.refreshTimer?.invalidate()
                dataManager.firstTrophyCheck = true
                switch (selectedLanguage!) {
                case .english:
                    DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "language", settingValue: "english", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
                        self.highlightSelectedItem()
                        BundleLocalization.sharedInstance().language = kAppLanguage.English.rawValue
                        let vc = SettingsVC()
                        DELEGATE.mainNavigationController?.pushViewController(vc, animated: true)
                    })
                    break
                case .welsh:
                    DownloadManager().changeAppSettings(dataManager.currentStudent!.id, settingType: "language", settingValue: "welsh", alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
                        self.highlightSelectedItem()
                        BundleLocalization.sharedInstance().language = kAppLanguage.Welsh.rawValue
                        let vc = SettingsVC()
                        DELEGATE.mainNavigationController?.pushViewController(vc, animated: true)
                    })
                    break
                }
            }
        }
    }
}
