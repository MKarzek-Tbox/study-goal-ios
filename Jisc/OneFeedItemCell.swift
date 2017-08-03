//
//  OneFeedItemCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/22/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kOneFeedItemCellNibName = "OneFeedItemCell"
let kOneFeedItemCellIdentifier = "OneFeedItemCellIdentifier"

class OneFeedItemCell: LocalizableCell {
    
    weak var navigationController:UINavigationController?
    weak var tableView:UITableView?
    
    @IBOutlet weak var userImage:UIImageDownload!
    @IBOutlet weak var contentText:UILabel!
    @IBOutlet weak var timeStamp:UILabel!
    @IBOutlet weak var shareButton:UIButton!
    @IBOutlet weak var shareView:UIView!
    @IBOutlet weak var optionsButton:UIButton!
    @IBOutlet weak var optionsView:UIView!
    @IBOutlet weak var userOptionsImage:UIImageDownload!
    @IBOutlet weak var hidePostButton:UIButton!
    @IBOutlet weak var hideFriendButton:UIButton!
    @IBOutlet weak var deleteFriendButton:UIButton!
    var theFeed:Feed?
    @IBOutlet var buttonsWithLargeTitles:[BigTitleButton] = []
    @IBOutlet weak var cellBG:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (screenWidth == .small) {
            hidePostButton.titleLabel?.font = myriadProRegular(13)
            hideFriendButton.titleLabel?.font = myriadProRegular(13)
            deleteFriendButton.titleLabel?.font = myriadProRegular(13)
        }
        shareButton.alpha = 0.0
        optionsButton.alpha = 0.0
        optionsView.alpha = 0.0
        shareView.alpha = 0.0
        
        if (buttonsWithLargeTitles.count > 0) {
            for (_, item) in buttonsWithLargeTitles.enumerated() {
                changeFontSizeToFit(item)
            }
        }
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
    
    func resetFontSize(_ sender:BigTitleButton) {
        sender.titleLabel!.font = sender.titleLabel!.font.withSize(sender.defaultFontSize)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        shareView.alpha = 0.0
        shareButton.alpha = 0.0
        optionsButton.alpha = 0.0
        optionsView.alpha = 0.0
        loadProfilePicture("")
    }
    
    func loadProfilePicture(_ link:String) {
        userImage.loadImageWithLink(link, type: .profile, completion: nil)
        userOptionsImage.loadImageWithLink(link, type: .profile, completion: nil)
    }
    
    func loadFeedPost(_ feed:Feed) {
        theFeed = feed
        if feed.activityType == "temp_push_notification" {
            cellBG.backgroundColor = UIColor(red: 186.0/255.0, green: 216.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        } else {
            cellBG.backgroundColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        }
        if (feed.isMine()) {
            shareButton.alpha = 1.0
            loadProfilePicture("\(hostPath)\(dataManager.currentStudent!.photo)")
        } else {
            optionsButton.alpha = 1.0
            let fromFriend = feed.fromFriend()
            if (fromFriend != nil) {
                loadProfilePicture("\(hostPath)\(fromFriend!.photo)")
            } else {
                let fromColleague = feed.fromColleague()
                if (fromColleague != nil) {
                    loadProfilePicture("\(hostPath)\(fromColleague!.photo)")
                } else {
                    loadProfilePicture("")
                }
            }
        }
        let attributedText = NSMutableAttributedString(string: feed.message)
        attributedText.addAttribute(NSFontAttributeName, value: myriadProRegular(14)!, range: NSMakeRange(0, feed.message.characters.count))
        if (feed.isMine()) {
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGray, range: NSMakeRange(0, feed.message.characters.count))
        } else {
            //			attributedText.addAttribute(NSForegroundColorAttributeName, value: lilacColor, range: NSMakeRange(0, 8))
            //			attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: NSMakeRange(8, text.characters.count - 8))
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGray, range: NSMakeRange(0, feed.message.characters.count))
        }
        contentText.attributedText = attributedText
        let seconds = abs(feed.createdDate.timeIntervalSinceNow)
        var timeStampText = ""
        if (seconds < 60) {
            timeStampText = localized("just_a_moment_ago")
        } else if (seconds < 3600) {
            timeStampText = "\(Int(seconds / 60)) \(localized("min_ago"))"
        } else if (seconds < 86400) {
            let hours = Int(seconds / 3600)
            if (hours == 1) {
                timeStampText = "\(hours) \(localized("hours_ago"))"
            } else {
                timeStampText = "\(hours) \(localized("hours_ago"))"
            }
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy"
            timeStampText = "\(localized("on")) \(dateFormatter.string(from: feed.createdDate))"
        }
        timeStamp.text = timeStampText
    }
    
    @IBAction func share(_ sender:UIButton) {
        showShareButtons()
    }
    
    func showShareButtons() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.shareButton.alpha = 0.0
            self.shareView.alpha = 1.0
        })
    }
    
    func hideShareButtons() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.shareButton.alpha = 1.0
            self.shareView.alpha = 0.0
        })
    }
    
    @IBAction func facebook(_ sender:UIButton) {
        hideShareButtons()
        if (theFeed != nil) {
            sharingManager.shareText(theFeed!.shareText(), on: .facebook, nvc: navigationController, successText: localized("post_shared_successfully"))
        }
    }
    
    @IBAction func twitter(_ sender:UIButton) {
        hideShareButtons()
        if (theFeed != nil) {
            sharingManager.shareText(theFeed!.shareText(), on: .twitter, nvc: navigationController, successText: localized("post_shared_successfully"))
        }
    }
    
    @IBAction func mail(_ sender:UIButton) {
        hideShareButtons()
        if (theFeed != nil) {
            sharingManager.shareText(theFeed!.shareText(), on: .mail, nvc: navigationController, successText: localized("post_shared_successfully"))
        }
    }
    
    @IBAction func options(_ sender:UIButton) {
        showOptions()
    }
    
    func showOptions() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.optionsView.alpha = 1.0
        })
    }
    
    func hideOptions() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.optionsView.alpha = 0.0
        })
    }
    
    @IBAction func closeOptions(_ sender:UIButton) {
        hideOptions()
    }
    
    @IBAction func hidePost(_ sender:UIButton) {
        if demo() {
            let alert = UIAlertController(title: "", message: localized("demo_mode_postfeed"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
        } else {
            hideOptions()
            if (theFeed != nil) {
                DownloadManager().hideFeed(theFeed!.id, myID: dataManager.currentStudent!.id, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
                    if (success) {
                        if (result != nil) {
                            let message = result!["message"] as? String
                            if (message != nil) {
                                AlertView.showAlert(true, message: message!, completion: nil)
                            }
                        }
                    } else {
                        AlertView.showAlert(false, message: kDefaultFailureReason, completion: nil)
                    }
                    dataManager.getStudentFeeds({ (success, failureReason) -> Void in
                        self.tableView?.reloadData()
                    })
                })
            } else {
                AlertView.showAlert(false, message: kDefaultFailureReason, completion: nil)
            }
        }
    }
    
    @IBAction func hideFriend(_ sender:UIButton) {
        hideOptions()
        if (theFeed != nil) {
            DownloadManager().hideFriend(dataManager.currentStudent!.id, friendToHideID: theFeed!.from, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
                if (success) {
                    if (result != nil) {
                        let message = result!["message"] as? String
                        if (message != nil) {
                            AlertView.showAlert(true, message: message!, completion: nil)
                        }
                    }
                } else {
                    AlertView.showAlert(false, message: kDefaultFailureReason, completion: nil)
                }
                dataManager.getStudentFeeds({ (success, failureReason) -> Void in
                    dataManager.getStudentFriendsData({ (success, failureReason) -> Void in
                        self.tableView?.reloadData()
                    })
                })
            })
        } else {
            AlertView.showAlert(false, message: kDefaultFailureReason, completion: nil)
        }
    }
    
    @IBAction func deleteFriend(_ sender:UIButton) {
        hideOptions()
        if (theFeed != nil) {
            DownloadManager().deleteFriend(dataManager.currentStudent!.id, friendToDeleteID: theFeed!.from, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
                if (success) {
                    if (result != nil) {
                        let message = result!["message"] as? String
                        if (message != nil) {
                            AlertView.showAlert(true, message: message!, completion: nil)
                        }
                    }
                } else {
                    AlertView.showAlert(false, message: kDefaultFailureReason, completion: nil)
                }
                dataManager.getStudentFeeds({ (success, failureReason) -> Void in
                    dataManager.getStudentFriendsData({ (success, failureReason) -> Void in
                        self.tableView?.reloadData()
                    })
                })
            })
        } else {
            AlertView.showAlert(false, message: kDefaultFailureReason, completion: nil)
        }
    }
}
