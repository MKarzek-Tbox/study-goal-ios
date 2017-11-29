//
//  BasicSearchCell.swift
//  Jisc
//
//  Created by Therapy Box on 11/4/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

class BasicSearchCell: LocalizableCell {
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var profileImage:UIImageDownload!
    @IBOutlet weak var courseLabel:UILabel!
    @IBOutlet weak var buttonsBottomSpace:NSLayoutConstraint!
    weak var parent:SearchVC?
    weak var iPadParent:MyFriendsView?
    var theFriendRequest:FriendRequest?
    var theFriend:Friend?
    var theColleague:Colleague?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (screenWidth == .small) {
            buttonsBottomSpace.constant = 8.0
            layoutIfNeeded()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        profileImage.image = nil
        nameLabel.text = ""
        theFriendRequest = nil
        theFriend = nil
        theColleague = nil
    }
    
    /**
     Loads the profile picture.
     
     :link: link providing the source of the image
     */
    func loadProfilePicture(_ link:String) {
        profileImage.loadImageWithLink(link, type: .profile, completion: nil)
    }
}
