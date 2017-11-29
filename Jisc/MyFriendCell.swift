//
//  MyFriendCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/26/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kMyFriendCellNibName = "MyFriendCell"
let kMyFriendCellIdentifier = "MyFriendCellIdentifier"

class MyFriendCell: BasicSearchCell, UIAlertViewDelegate {
    
    @IBOutlet weak var hideButton:UIButton!
    
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
    
    func loadFriend(_ friend:Friend) {
        theFriend = friend
        nameLabel.text = "\(friend.firstName) \(friend.lastName)"
        loadProfilePicture("\(hostPath)\(friend.photo)")
        hideButton.isSelected = friend.hidden.boolValue
    }
    
    @IBAction func hideOrUnhideFriend(_ sender:UIButton) {
        if currentUserType() == .demo {
            sender.isSelected = !sender.isSelected
        } else {
            parent?.friendToTakeActionWith = theFriend
            iPadParent?.friendToTakeActionWith = theFriend
            if (sender.isSelected) {
                parent?.unhideFriend({ (success, result, results, error) -> Void in
                    self.parent?.refreshData()
                    AlertView.showAlert(true, message: localized("friend_unhidden_successfully"), completion: nil)
                })
                iPadParent?.unhideFriend({ (success, result, results, error) -> Void in
                    self.iPadParent?.refreshData()
                    AlertView.showAlert(true, message: localized("friend_unhidden_successfully"), completion: nil)
                })
            } else {
                parent?.hideFriend({ (success, result, results, error) -> Void in
                    self.parent?.refreshData()
                    AlertView.showAlert(true, message: localized("friend_hidden_successfully"), completion: nil)
                })
                iPadParent?.hideFriend({ (success, result, results, error) -> Void in
                    self.iPadParent?.refreshData()
                    AlertView.showAlert(true, message: localized("friend_hidden_successfully"), completion: nil)
                })
            }
        }
    }
    
    @IBAction func deleteFriend(_ sender:UIButton) {
        if demo() {
            let alert = UIAlertController(title: "", message: localized("demo_mode_deletefriend"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            parent?.navigationController?.present(alert, animated: true, completion: nil)
        } else {
            UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_friend"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
        }
    }
    
    //MARK: UIAlertView Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 1) {
            parent?.friendToTakeActionWith = theFriend
            parent?.deleteFriend({ (success, result, results, error) -> Void in
                if success {
                    self.parent?.refreshData()
                    AlertView.showAlert(true, message: localized("friend_deleted_successfully"), completion: nil)
                } else {
                    var failureReason = kDefaultFailureReason
                    if (error != nil) {
                        failureReason = error!
                    }
                    AlertView.showAlert(false, message: failureReason, completion: nil)
                }
            })
            
            iPadParent?.friendToTakeActionWith = theFriend
            iPadParent?.deleteFriend({ (success, result, results, error) -> Void in
                if success {
                    self.parent?.refreshData()
                    AlertView.showAlert(true, message: localized("friend_deleted_successfully"), completion: nil)
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
}
