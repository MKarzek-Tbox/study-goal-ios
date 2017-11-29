//
//  FoundStudentCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/26/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kFoundStudentCellNibName = "FoundStudentCell"
let kFoundStudentCellIdentifier = "FoundStudentCellIdentifier"

enum FriendshipStatus {
    case notFriends
    case friends
    case receivedRequest
    case pendingRequest
}

class FoundStudentCell: BasicSearchCell, UIAlertViewDelegate {
    
    @IBOutlet weak var friendRequestButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        friendRequestButton.isSelected = false
        loadProfilePicture("")
    }
    
    /**
     Initalises the cell for a friend.
     
     :colleague: friend to display
     :status: status of the friendship
     */
    func loadColleague(_ colleague:Colleague, status:FriendshipStatus) {
        theColleague = colleague
        nameLabel.text = "\(colleague.firstName) \(colleague.lastName)"
        loadProfilePicture("\(hostPath)\(colleague.photo)")
        
        switch (status) {
        case .notFriends:
            friendRequestButton.isSelected = false
            friendRequestButton.isUserInteractionEnabled = true
        case .friends:
            friendRequestButton.isSelected = true
            friendRequestButton.isUserInteractionEnabled = false
            friendRequestButton.setTitle(localized("friends"), for: .selected)
        case .receivedRequest:
            friendRequestButton.isSelected = true
            friendRequestButton.isUserInteractionEnabled = false
            friendRequestButton.setTitle(localized("received_request"), for: .selected)
        case .pendingRequest:
            friendRequestButton.isSelected = true
            friendRequestButton.isUserInteractionEnabled = true
            friendRequestButton.setTitle(localized("pending_request"), for: .selected)
        }
    }
    
    /**
     Sends a request to the displayed friend.
     
     :sender: button that triggered the action
     */
    @IBAction func sendRequest(_ sender:UIButton) {
        if (theColleague != nil) {
            if (sender.isSelected) {
                UIAlertView(title: localized("confirmation"), message: localized("cancel_pending_request"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
            } else {
                parent?.searchStudentsInputTextField.resignFirstResponder()
                parent?.sendFriendRequestToColleague(theColleague!)
                iPadParent?.searchStudentsInputTextField.resignFirstResponder()
                iPadParent?.sendFriendRequestToColleague(theColleague!)
            }
        }
    }
    
    //MARK: UIAlertView Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 1) {
            if (theColleague != nil) {
                parent?.searchStudentsInputTextField.resignFirstResponder()
                parent?.cancelPendingFriendRequestToColleague(theColleague!)
                iPadParent?.searchStudentsInputTextField.resignFirstResponder()
                iPadParent?.cancelPendingFriendRequestToColleague(theColleague!)
            }
        }
    }
}
