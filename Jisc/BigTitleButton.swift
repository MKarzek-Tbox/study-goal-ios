//
//  BigTitleButton.swift
//  Jisc
//
//  Created by Therapy Box on 10/30/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kTitleLabelKeyPath = "self.titleLabel.text"

class BigTitleButton: LocalizableButton {
    var observer:NSObject?
    var defaultFontSize:CGFloat = 20.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (titleLabel != nil) {
            defaultFontSize = titleLabel!.font.pointSize
        }
    }
    
    func addObserver(_ sender:NSObject?) {
        observer = sender
        if (observer != nil) {
            self.addObserver(observer!, forKeyPath: kTitleLabelKeyPath, options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    deinit {
        if (observer != nil) {
            self.removeObserver(observer!, forKeyPath: kTitleLabelKeyPath)
        }
    }
}
