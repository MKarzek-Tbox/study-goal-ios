//
//  EventsAttendedCell.swift
//  Jisc
//
//  Created by Marjana on 17.08.17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

let kEventsAttendedCellNibName = "EventsAttendedCell"
let kEventsAttendedCellIdentifier = "EventsAttendedCell"

class EventsAttendedCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var moduleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = ""
        timeLabel.text = ""
        activityLabel.text = ""
        moduleLabel.text = ""
    }
    
    /**
     Loads the event data into the cell.
     
     :events: event object to be displayed
     */
    func loadEvents(events:EventsAttendedObject){
        dateLabel.text = events.date
        timeLabel.text = events.time
        activityLabel.text = events.activity
        moduleLabel.text = events.module
    }
}
