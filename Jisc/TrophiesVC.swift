//
//  TrophiesVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/22/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let goldBorderColor = UIColor(red: 0.99, green: 0.7, blue: 0.29, alpha: 1.0)
let silverBorderColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1.0)

class TrophiesVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var trophiesWonButton:UIButton!
	@IBOutlet weak var trophiesAvailableButton:UIButton!
	@IBOutlet weak var wonTrophiesTable:UITableView!
	@IBOutlet weak var availableTrophiesTable:UITableView!
    @IBOutlet weak var noTrophiesWon:UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		wonTrophiesTable.register(UINib(nibName: kTrophiesCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kTrophiesCellIdentifier)
		availableTrophiesTable.register(UINib(nibName: kTrophiesCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kTrophiesCellIdentifier)
		availableTrophiesTable.alpha = 0.0
        if(dataManager.myTrophies().count == 0){
            self.noTrophiesWon.isHidden = false
        } else {
            self.noTrophiesWon.isHidden = true
        }
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func trophiesWon(_ sender:UIButton) {
		trophiesWonButton.isSelected = true
		trophiesAvailableButton.isSelected = false
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.wonTrophiesTable.alpha = 1.0
			self.availableTrophiesTable.alpha = 0.0
            if(dataManager.myTrophies().count == 0){
                self.noTrophiesWon.isHidden = false
            } else {
                self.noTrophiesWon.isHidden = true
            }
		}) 
	}
	
	@IBAction func trophiesAvailable(_ sender:UIButton) {
		trophiesWonButton.isSelected = false
		trophiesAvailableButton.isSelected = true
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.wonTrophiesTable.alpha = 0.0
			self.availableTrophiesTable.alpha = 1.0
            self.noTrophiesWon.isHidden = true
		}) 
	}
	
	func showDetailsForTrophy(_ trophy:Trophy?) {
		if (trophy != nil) {
			let details = TrophyDetailsView.create(trophy)
			details.alpha = 0.0
			view.addSubview(details)
			addMarginConstraintsWithView(details, toSuperView: view)
			UIView.animate(withDuration: 0.25, animations: { () -> Void in
				details.alpha = 1.0
			}) 
		}
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var trophiesCount:Int = 0
		switch (tableView) {
		case wonTrophiesTable:
			trophiesCount = dataManager.myTrophies().count
			break
		case availableTrophiesTable:
			trophiesCount = dataManager.availableTrophies().count
			break
		default:break
		}
		var nrRows:Int = trophiesCount / 3
		if (trophiesCount % 3 > 0) {
			nrRows += 1
		}
		return nrRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var theCell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: kTrophiesCellIdentifier)
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let height = (screenWidth.rawValue - 6.0) / 3.0
		return height
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let theCell:TrophiesCell? = cell as? TrophiesCell
		if (theCell != nil) {
			theCell?.parent = self
			let leftIndex = indexPath.row * 3
			let middleIndex = leftIndex + 1
			let rightIndex = middleIndex + 1
			var leftTrophy:Trophy? = nil
			var leftTotal:Int = 0
			var middleTrophy:Trophy? = nil
			var middleTotal:Int = 0
			var rightTrophy:Trophy? = nil
			var rightTotal:Int = 0
			var trophies:[AnyObject] = [AnyObject]()
			switch (tableView) {
			case wonTrophiesTable:
				trophies = dataManager.myTrophies()
				if (leftIndex < trophies.count) {
					let trophy = trophies[leftIndex] as? StudentTrophy
					if (trophy != nil) {
						leftTrophy = trophy!.trophy
						leftTotal = trophy!.total.intValue
					}
				}
				if (middleIndex < trophies.count) {
					let trophy = trophies[middleIndex] as? StudentTrophy
					if (trophy != nil) {
						middleTrophy = trophy!.trophy
						middleTotal = trophy!.total.intValue
					}
				}
				if (rightIndex < trophies.count) {
					let trophy = trophies[rightIndex] as? StudentTrophy
					if (trophy != nil) {
						rightTrophy = trophy!.trophy
						rightTotal = trophy!.total.intValue
					}
				}
				break
			case availableTrophiesTable:
				trophies = dataManager.availableTrophies()
				if (leftIndex < trophies.count) {
					let trophy = trophies[leftIndex] as? Trophy
					if (trophy != nil) {
						leftTrophy = trophy
					}
				}
				if (middleIndex < trophies.count) {
					let trophy = trophies[middleIndex] as? Trophy
					if (trophy != nil) {
						middleTrophy = trophy
					}
				}
				if (rightIndex < trophies.count) {
					let trophy = trophies[rightIndex] as? Trophy
					if (trophy != nil) {
						rightTrophy = trophy
					}
				}
				break
			default:break
			}
			theCell?.loadTrophies((trophy: leftTrophy, total: leftTotal), middle: (trophy: middleTrophy, total: middleTotal), right: (trophy: rightTrophy, total: rightTotal))
		}
	}
}
