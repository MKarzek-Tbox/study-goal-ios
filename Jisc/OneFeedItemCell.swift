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
    var panStartPoint:CGPoint = CGPoint.zero
    var optionsState:kOptionsState = .closed
    @IBOutlet weak var contentTrailingConstraint:NSLayoutConstraint!
    @IBOutlet weak var optionsButtonsView:UIView!
    @IBOutlet weak var userImage:UIImageDownload!
    @IBOutlet weak var contentText:UILabel!
    @IBOutlet weak var timeStamp:UILabel!
    @IBOutlet weak var shareButton:UIButton!
    @IBOutlet weak var shareView:UIView!
    @IBOutlet weak var optionsView:UIView!
    
    var theFeed:Feed?
    weak var parent:FeedVC?

    @IBOutlet var buttonsWithLargeTitles:[BigTitleButton] = []
    @IBOutlet weak var cellBG:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(OneFeedItemCell.panAction(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(OneFeedItemCell.anotherCellOpenedOptions(_:)), name: NSNotification.Name(rawValue: kAnotherActivityCellOpenedOptions), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OneFeedItemCell.changeSelectedStyleOn), name: NSNotification.Name(rawValue: kChangeActivityCellSelectedStyleOn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OneFeedItemCell.changeSelectedStyleOff), name: NSNotification.Name(rawValue: kChangeActivityCellSelectedStyleOff), object: nil)
        shareButton.alpha = 0.0
        shareView.alpha = 0.0
        
        if (buttonsWithLargeTitles.count > 0) {
            for (_, item) in buttonsWithLargeTitles.enumerated() {
                changeFontSizeToFit(item)
            }
        }
    }
    func anotherCellOpenedOptions(_ notification:Notification) {
        let senderCell = notification.object as? OneFeedItemCell
        if (senderCell != nil) {
            if (self != senderCell!) {
                closeCellOptions()
            }
        }
    }
    
    func changeSelectedStyleOn() {
        selectionStyle = .gray
    }
    
    func changeSelectedStyleOff() {
        selectionStyle = .none
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
        loadProfilePicture("")
    }
    
    func loadProfilePicture(_ link:String) {
        userImage.loadImageWithLink(link, type: .profile, completion: nil)
        //userOptionsImage.loadImageWithLink(link, type: .profile, completion: nil)
    }
    
    func loadFeedPost(_ feed:Feed) {
        theFeed = feed
        if feed.activityType == "temp_push_notification" {
            print("\(feed.description) is a push notification ")
            self.cellBG.backgroundColor = UIColor(red: 186.0/255.0, green: 216.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        } else {
            print("\(feed.description) is a post ")
            self.cellBG.backgroundColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        }
        if feed.activityType == "temp_push_notification"{
            userImage.image = UIImage(named: "notification_image")
        } else {
            if (feed.isMine()) {
                shareButton.alpha = 1.0
                loadProfilePicture("\(hostPath)\(dataManager.currentStudent!.photo)")
            } else {
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
        }
        let attributedText = NSMutableAttributedString(string: feed.message)
        attributedText.addAttribute(NSFontAttributeName, value: myriadProRegular(18
            )!, range: NSMakeRange(0, feed.message.characters.count))
        if (feed.isMine()) {
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0), range: NSMakeRange(0, feed.message.characters.count))
        } else {
            //			attributedText.addAttribute(NSForegroundColorAttributeName, value: lilacColor, range: NSMakeRange(0, 8))
            //			attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: NSMakeRange(8, text.characters.count - 8))
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0), range: NSMakeRange(0, feed.message.characters.count))
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
        let activityViewController = UIActivityViewController(activityItems: [theFeed!.shareText() as NSString], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.popoverPresentationController?.sourceRect = sender.frame
        

        navigationController?.present(activityViewController, animated: true, completion: nil)
        

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
    @IBAction func deleteTarget(_ sender:UIButton) {
        let alert = UIAlertController(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("yes"), style: .destructive, handler: { (action) in
            DownloadManager().deleteFeed((self.theFeed?.id)!, myID: dataManager.currentStudent!.id, alertAboutInternet: true, completion: { (success, dictionary, array, error) in
                if success {
                    dataManager.getStudentFeeds({ (success, error) in
                        self.tableView?.reloadData()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeActivityCellSelectedStyleOn), object: nil)
                        self.parent?.aCellIsOpen = false
                        self.optionsState = .closed
                        self.closeCellOptions()

                    })
                } else {
                    var failureReason = kDefaultFailureReason
                    if (error != nil) {
                        failureReason = error!
                    }
                    self.tableView?.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeActivityCellSelectedStyleOn), object: nil)
                    self.parent?.aCellIsOpen = false
                    self.optionsState = .closed
                    if(self.theFeed?.activityType == "temp_push_notification"){
                        AlertView.showAlert(false, message: localized("Tap on a notification to mark it as read. Unread notifications can't be deleted."), completion: nil)
                    } else {
                        AlertView.showAlert(false, message: failureReason, completion: nil)
                    }
                    self.closeCellOptions()

                }
            })
        }))
        alert.addAction(UIAlertAction(title: localized("no"), style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
        
        
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
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var shouldBegin = true
        let panGesture = gestureRecognizer as? UIPanGestureRecognizer
        if (panGesture != nil) {
            let horizontalVelocity = abs(panGesture!.velocity(in: self).x)
            let verticalVelocity = abs(panGesture!.velocity(in: self).y)
            if (verticalVelocity > horizontalVelocity) {
                shouldBegin = false
            }
        }
        return shouldBegin
    }
    
    func panAction(_ sender:UIPanGestureRecognizer) {
        switch (sender.state) {
        case .began:
            panStartPoint = sender.location(in: self)
        case .ended:
            let velocity = sender.velocity(in: self).x
            if (velocity < 0) {
                openCellOptions()
            } else {
                closeCellOptions()
            }
        case .changed:
            let currentPoint = sender.location(in: self)
            var difference = panStartPoint.x - currentPoint.x
            if (optionsState == .open) {
                difference += kButtonsWidth
            }
            if (difference < 0.0) {
                difference = 0.0
            } else if (difference > kButtonsWidth) {
                difference = kButtonsWidth
            }
            contentTrailingConstraint.constant = difference
            layoutIfNeeded()
        default:break
        }
    }
    
    func openCellOptions() {
        if(theFeed?.activityType != "temp_push_notification"){
            NotificationCenter.default.post(name: Notification.Name(rawValue: kAnotherActivityCellOpenedOptions), object: self)
            optionsState = .open
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.contentTrailingConstraint.constant = kButtonsWidth
                self.layoutIfNeeded()
            }, completion: { (done) -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeActivityCellSelectedStyleOff), object: nil)
                self.parent?.aCellIsOpen = true
            })
        }
    }
    
    func closeCellOptions() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeActivityCellSelectedStyleOn), object: nil)
        parent?.aCellIsOpen = false
        optionsState = .closed
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.contentTrailingConstraint.constant = 0.0
            self.layoutIfNeeded()
        }) 
    }

}
