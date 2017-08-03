//
//  InstituteCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/19/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kInstituteCellNibName = "InstituteCell"
let kInstituteCellIdentifier = "InstituteCellIdentifier"

class InstituteCell: UITableViewCell {
	
	var institute:Institution?
	@IBOutlet weak var instituteName:UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		if (selected) {
			setSelected(false, animated: animated)
		}
	}
	
	func loadInstitute(_ institute:Institution) {
		self.institute = institute
		instituteName.textAlignment = .left
        if (self.institute?.name == "Gloucestershire"){
            instituteName.text = "University of Gloucestershire"
        } else if(self.institute?.name == "Oxford Brookes"){
            instituteName.text = "Oxford Brookes University"
        } else if(self.institute?.name == "South Wales"){
            instituteName.text = "University of South Wales | Prifysgol De Cymru"
        } else if (self.institute?.name == "Strathclyde"){
            instituteName.text = "University of Strathclyde"
        } else {
            instituteName.text = self.institute?.name
        }
		layoutIfNeeded()
	}
	
	func noInstitute() {
		instituteName.textAlignment = .center
		instituteName.text = localized("institution_not_listed")
		layoutIfNeeded()
	}
	
	func demoInstitute() {
		instituteName.textAlignment = .center
		instituteName.text = localized("demo")
		layoutIfNeeded()
	}
}
