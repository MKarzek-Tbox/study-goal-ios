//
//  NewRequestCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/26/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kNewRequestCellNibName = "NewRequestCell"
let kNewRequestCellIdentifier = "NewRequestCellIdentifier"

class NewRequestCell: BasicSearchCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadProfilePicture("")
    }
    
    /**
     Initalises the cell to display the request.
     
     :request: request to be displayed
     */
    func loadFriendRequest(_ request:FriendRequest) {
        theFriendRequest = request
        nameLabel.text = "\(request.firstName) \(request.lastName)"
        loadProfilePicture("\(hostPath)\(request.photo)")
    }
    
    /**
     Confirms the selected request.
     
     :sender: button that triggered the action
     */
    @IBAction func confirmRequest(_ sender:UIButton) {
        if (theFriendRequest != nil) {
            parent?.friendRequestToTakeActionWith = theFriendRequest
            parent?.acceptThisFriendRequest(theFriendRequest!)
            iPadParent?.friendRequestToTakeActionWith = theFriendRequest
            iPadParent?.acceptThisFriendRequest(theFriendRequest!)
        }
    }
    
    /**
     Removes the selected request.
     
     :sender: button that triggered the action
     */
    @IBAction func deleteRequest(_ sender:UIButton) {
        parent?.friendRequestToTakeActionWith = theFriendRequest
        parent?.deleteFriendRequest({ (success, result, results, error) -> Void in
            if success {
                self.parent?.refreshData()
                AlertView.showAlert(true, message: localized("deleted_successfully"), completion: nil)
            } else {
                var failureReason = kDefaultFailureReason
                if (error != nil) {
                    failureReason = error!
                }
                AlertView.showAlert(false, message: failureReason, completion: nil)
            }
        })
        
        iPadParent?.friendRequestToTakeActionWith = theFriendRequest
        iPadParent?.deleteFriendRequest({ (success, result, results, error) -> Void in
            if success {
                self.parent?.refreshData()
                AlertView.showAlert(true, message: localized("deleted_successfully"), completion: nil)
            } else {
                var failureReason = kDefaultFailureReason
                if (error != nil) {
                    failureReason = error!
                }
                AlertView.showAlert(false, message: failureReason, completion: nil)
            }
        })
    }
}
