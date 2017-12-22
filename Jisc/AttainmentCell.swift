//
//  AttainmentCell.swift
//  Jisc
//
//  Created by therapy box on 12/10/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

let kAttainmentCellNibName = "AttainmentCell"
let kAttainmentCellIdentifier = "AttainmentCellIdentifier"

class AttainmentCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var moduleLabel:UILabel!
    @IBOutlet weak var markLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    /**
     Loads attainment data into the cell
     
     :object: attainment data object to be displayed
     */
    func loadAttainmentObject(_ object:AttainmentObject?) {
        if let object = object {
            dateFormatter.dateFormat = "dd/MM/yy"
            if object.dateString != "" {
                dateLabel.text = object.dateString
                moduleLabel.text = object.moduleName
                markLabel.text = object.grade
            } else {
                dateLabel.text = "\(dateFormatter.string(from: object.date))"
                moduleLabel.text = object.moduleName
                markLabel.text = object.grade
            }
        }
    }
}
