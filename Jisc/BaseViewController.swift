//
//  BaseViewController.swift
//  Jisc
//
//  Created by Therapy Box on 10/15/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet var viewsWithShadow:[UIView] = []
    @IBOutlet var viewsWithRoundedCorners:[ViewWithRoundedCorners] = []
    @IBOutlet var buttonsWithLargeTitles:[BigTitleButton] = []
    @IBOutlet var localizableLabels:[LocalizableLabel] = []
    @IBOutlet var localizableButtons:[LocalizableButton] = []
    @IBOutlet var localizableTextFields:[LocalizableTextField] = []
    @IBOutlet var localizableTextViews:[LocalizableTextView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        setShadows()
        setRoundedCorners()
        setLargeButtonTitles()
        localizeLabels()
        localizeButtons()
        localizeTextFields()
        localizeTextViews()
    }
    
    //MARK: Set Shadows
    
    func setShadows() {
        if (viewsWithShadow.count > 0) {
            for (_, item) in viewsWithShadow.enumerated() {
                setShadow(item)
            }
        }
    }
    
    func setShadow(_ view:UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 1.5
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.rasterizationScale = UIScreen.main.scale
        view.layer.shouldRasterize = true
    }
    
    //MARK: Set Rounded Corners
    
    func setRoundedCorners() {
        if (viewsWithRoundedCorners.count > 0) {
            for (_, item) in viewsWithRoundedCorners.enumerated() {
                setCornerRadius(item)
            }
        }
    }
    
    //MARK: Set Large Button Titles
    
    func setLargeButtonTitles() {
        if (buttonsWithLargeTitles.count > 0) {
            for (_, item) in buttonsWithLargeTitles.enumerated() {
                changeFontSizeToFit(item)
                item.addObserver(self)
            }
        }
    }
    
    func setCornerRadius(_ view:ViewWithRoundedCorners) {
        view.layer.cornerRadius = view.cornerRadius
        view.layer.masksToBounds = true
    }
    
    func resetFontSize(_ sender:BigTitleButton) {
        sender.titleLabel!.font = sender.titleLabel!.font.withSize(sender.defaultFontSize)
    }
    
    func changeFontSizeToFit(_ button:BigTitleButton) {
        if (button.titleLabel != nil) {
            resetFontSize(button)
            button.titleLabel!.numberOfLines = 2
            var height = heightForText(button.titleLabel!.text, font: button.titleLabel!.font, width: button.frame.size.width, caresAboutWords: true)
            if (height >= button.frame.size.height) {
                repeat {
                    button.titleLabel!.font = button.titleLabel!.font.withSize(button.titleLabel!.font.pointSize - 1)
                    height = heightForText(button.titleLabel!.text, font: button.titleLabel!.font, width: button.frame.size.width, caresAboutWords: true)
                } while (height >= button.frame.size.height && button.titleLabel!.font.pointSize > 5)
            }
        }
    }
    
    //MARK: Localization
    
    func localizeLabels() {
        if (localizableLabels.count > 0) {
            for (_, item) in localizableLabels.enumerated() {
                item.localize()
            }
        }
    }
    
    func localizeButtons() {
        if (localizableButtons.count > 0) {
            for (_, item) in localizableButtons.enumerated() {
                item.localize()
            }
        }
    }
    
    func localizeTextFields() {
        if (localizableTextFields.count > 0) {
            for (_, item) in localizableTextFields.enumerated() {
                item.localize()
            }
        }
    }
    
    func localizeTextViews() {
        if (localizableTextViews.count > 0) {
            for (_, item) in localizableTextViews.enumerated() {
                item.localize()
            }
        }
    }
    
    //MARK: Key/Value Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == kTitleLabelKeyPath) {
            let button = object as? BigTitleButton
            if (button != nil) {
                changeFontSizeToFit(button!)
            }
        }
    }
    
    //MARK: Orientation
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if (iPad) {
            return UIInterfaceOrientationMask.landscape
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
}
