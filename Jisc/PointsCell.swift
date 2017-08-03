//
//  PointsCell.swift
//  Jisc
//
//  Created by Paul on 6/7/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

let kPointsCellNibName = "PointsCell"
let kPointsCellIdentifier = "PointsCell"

class PointsCell: UITableViewCell {

	@IBOutlet weak var activityLabel:UILabel!
	@IBOutlet weak var countLabel:UILabel!
	@IBOutlet weak var pointsLabel:UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
		activityLabel.text = ""
		countLabel.text = ""
		pointsLabel.text = ""
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	func loadPoints(points:PointsObject) {
		activityLabel.text = points.activity
		countLabel.text = "\(points.count)"
		pointsLabel.text = "\(points.points)"
	}
}
