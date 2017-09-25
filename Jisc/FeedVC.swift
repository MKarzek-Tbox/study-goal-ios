//
//  FeedVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
import CoreData

let openPostMessageTopSpace:CGFloat = -60.0
let emptyFeedPageMessage = localized("empty_feed_page_message")

class FeedVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
	
	@IBOutlet weak var feedsTableView:UITableView!
	@IBOutlet weak var postsViewTopSpace:NSLayoutConstraint!
	@IBOutlet weak var postsViewHeight:NSLayoutConstraint!
	@IBOutlet weak var postButtonView:UIView!
	@IBOutlet weak var blockView:UIView!
	@IBOutlet weak var newPostTextView:UITextView!
	@IBOutlet weak var toolbarBottomSpace:NSLayoutConstraint!
	var refreshTimer:Timer?
    var aCellIsOpen:Bool = false

	@IBOutlet weak var emptyScreenMessage:UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		feedsTableView.register(UINib(nibName: kOneFeedItemCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kOneFeedItemCellIdentifier)
		feedsTableView.contentInset = UIEdgeInsetsMake(20.0, 0, 20.0, 0)
		//refreshTimer = Timer(timeInterval: 30, target: self, selector: #selector(FeedVC.refreshFeeds(_:)), userInfo:nil, repeats: true)
		//RunLoop.current.add(refreshTimer!, forMode: RunLoopMode.commonModes)
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(FeedVC.manuallyRefreshFeeds(_:)), for: UIControlEvents.valueChanged)
		feedsTableView.addSubview(refreshControl)
        
        //London Developer July 24,2017
        let urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=feed-main&contentName=MainFeed"
        xAPIManager().checkMod(testUrl:urlString)
        
        let statsClass = StatsVC()
//        statsClass.getEventsAttended {
//            print("requested events attended from feed")
//        }
        //statsClass.viewDidLoad()
        
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		/*if (dataManager.friendRequests().count > 0) {
            //London Developer July 24,2017
            let urlString = "https://api.datax.jisc.ac.uk/sg/log?verb=viewed&contentID=feed-friends&contentName=friends"
            xAPIManager().checkMod(testUrl:urlString)
		}*/
	}
	
	@IBAction func openMenu(_ sender:UIButton?) {
        //DELEGATE.menuView = MenuView.createView()
        DELEGATE.menuView?.open()
		//print("open menu: \(DELEGATE.menuView)")
	}
	
	func refreshFeeds(_ sender:Timer) {
		dataManager.silentStudentFeedsRefresh(false) { (success, failureReason) -> Void in
			self.feedsTableView.reloadData()
		}
	}
	
	func manuallyRefreshFeeds(_ sender:UIRefreshControl) {
		dataManager.silentStudentFeedsRefresh(true) { (success, failureReason) -> Void in
			self.feedsTableView.reloadData()
			sender.endRefreshing()
		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func search(_ sender:UIButton) {
		let vc = SearchVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	func openPostMessageHeight() -> CGFloat {
		return postButtonView.frame.origin.y + postButtonView.frame.size.height
	}
	
	@IBAction func showPostMessageView(_ sender:UIButton) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.blockView.alpha = 1.0
			self.postsViewTopSpace.constant = openPostMessageTopSpace
			self.postsViewHeight.constant = self.openPostMessageHeight()
			self.view.layoutIfNeeded()
			}, completion: { (done) -> Void in 
				self.newPostTextView.becomeFirstResponder()
		}) 
	}
	
	@IBAction func hidePostMessageView(_ sender:UIButton) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.blockView.alpha = 0.0
			self.postsViewTopSpace.constant = 0.0
			self.postsViewHeight.constant = 0.0
			self.view.layoutIfNeeded()
		}, completion: { (done) -> Void in 
			self.newPostTextView.resignFirstResponder()
		}) 
	}
	
	@IBAction func postMessage(_ sender:UIButton) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.blockView.alpha = 0.0
			self.postsViewTopSpace.constant = 0.0
			self.postsViewHeight.constant = 0.0
			self.view.layoutIfNeeded()
		}, completion: { (done) -> Void in
			self.newPostTextView.resignFirstResponder()
			if (!self.newPostTextView.text.replacingOccurrences(of: " ", with: "").isEmpty) {
				if (!self.newPostTextView.text.isEmpty) {
					DownloadManager().postFeedMessage(dataManager.currentStudent!.id, message: self.newPostTextView.text, alertAboutInternet: true, completion: { (success, result, results, error) -> Void in
						if (success) {
							AlertView.showAlert(true, message: localized("message_posted_successfully"), completion: nil)
						} else {
							var failureReason = kDefaultFailureReason
							if (error != nil) {
								failureReason = error!
							}
							AlertView.showAlert(false, message: failureReason, completion: nil)
						}
						self.newPostTextView.text = ""
						dataManager.getStudentFeeds({ (success, failureReason) -> Void in
							self.feedsTableView.reloadData()
						})
					})
				}
			}
		})
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let nrRows = dataManager.myFeeds().count
		if (nrRows == 0) {
			emptyScreenMessage.alpha = 1.0
		} else {
			emptyScreenMessage.alpha = 0.0
		}
		return nrRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var theCell = tableView.dequeueReusableCell(withIdentifier: kOneFeedItemCellIdentifier)
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 108.0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let theCell:OneFeedItemCell? = cell as? OneFeedItemCell
		if (theCell != nil) {
			theCell!.tableView = tableView
			theCell!.navigationController = self.navigationController
			theCell!.loadFeedPost(dataManager.myFeeds()[indexPath.row])
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let feed = dataManager.myFeeds()[indexPath.row]
		if (feed.activityType == "friend_request") {
			if (!feed.isMine()) {
				let message = localized("do_you_want_to_respond")
				let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: localized("yes"), style: .default, handler: { (action) in
					let vc = SearchVC()
					vc.newRequests(UIButton())
					self.navigationController?.pushViewController(vc, animated: true)
				}))
				alert.addAction(UIAlertAction(title: localized("no"), style: .cancel, handler: { (action) in }))
				self.navigationController?.present(alert, animated: true, completion: nil)
			}
		} else if feed.activityType == "temp_push_notification" {
			if let studentId = dataManager.currentStudent?.id {
				DownloadManager().markNotificationAsRead(studentdId: studentId, notificationId: feed.id, alertAboutInternet: false, completion: { (success, dictionary, array, error) in
					dataManager.silentStudentFeedsRefresh(true) { (success, failureReason) -> Void in
						self.feedsTableView.reloadData()
					}
				})
			}
		}
        if (aCellIsOpen) {
            tableView.reloadData()
        } else {
          
        }
	}
	
    func deleteThis(indexPath: IndexPath){
        print("attempting delete");
        let alert = UIAlertController(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("yes"), style: .destructive, handler: { (action) in
            let feed = dataManager.myFeeds()[indexPath.row]
            DownloadManager().deleteFeed(feed.id, myID: dataManager.currentStudent!.id, alertAboutInternet: true, completion: { (success, dictionary, array, error) in
                if success {
                    dataManager.getStudentFeeds({ (success, error) in
                        self.feedsTableView.reloadData()
                    })
                } else {
                    var failureReason = kDefaultFailureReason
                    if (error != nil) {
                        failureReason = error!
                    }
                    AlertView.showAlert(false, message: failureReason, completion: nil)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: localized("no"), style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
/*	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		var style = UITableViewCellEditingStyle.none
		if dataManager.myFeeds()[indexPath.row].isMine() {
			style = .delete
		}
		return style
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let alert = UIAlertController(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_message"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("yes"), style: .destructive, handler: { (action) in
				let feed = dataManager.myFeeds()[indexPath.row]
				DownloadManager().deleteFeed(feed.id, myID: dataManager.currentStudent!.id, alertAboutInternet: true, completion: { (success, dictionary, array, error) in
					if success {
						dataManager.getStudentFeeds({ (success, error) in
							tableView.reloadData()
						})
					} else {
						var failureReason = kDefaultFailureReason
						if (error != nil) {
							failureReason = error!
						}
						AlertView.showAlert(false, message: failureReason, completion: nil)
					}
				})
			}))
			alert.addAction(UIAlertAction(title: localized("no"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		}
	}*/
	
	//MARK: UITextView Delegate
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.toolbarBottomSpace.constant = keyboardHeight - 49
			self.view.layoutIfNeeded()
		}) 
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.toolbarBottomSpace.constant = -44.0
			self.view.layoutIfNeeded()
		}) 
	}
	
	@IBAction func closeTextView(_ sender:UIBarButtonItem) {
		newPostTextView.resignFirstResponder()
		if (!newPostTextView.text.isEmpty) {
			postMessage(UIButton())
		}
	}
}
