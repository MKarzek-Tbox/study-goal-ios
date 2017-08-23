//
//  TargetCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/28/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kSingleButtonsWidth:CGFloat = 236.0
let kSingleTargetCellNibName = "SingleTargetCell"
let kSingleTargetCellIdentifier = "SingleTargetCellIdentifier"
let kAnotherSingleTargetCellOpenedOptions = "kAnotherSingleTargetCellOpenedOptions"
let kChangeSingleTargetCellSelectedStyleOn = "kChangeSingleTargetCellSelectedStyleOn"
let kChangeSingleTargetCellSelectedStyleOff = "kChangeSingleTargetCellSelectedStyleOff"
let greenSingleTargetColor = UIColor(red: 0.1, green: 0.69, blue: 0.12, alpha: 1.0)
let orangeSingleTargetColor = UIColor(red: 0.99, green: 0.51, blue: 0.23, alpha: 1.0)
let redSingleTargetColor = UIColor(red: 0.99, green: 0.24, blue: 0.26, alpha: 1.0)

class SingleTargetCell: UITableViewCell, UIAlertViewDelegate {
    
    @IBOutlet weak var targetTypeIcon:UIImageView!
    @IBOutlet weak var completionColorView:UIView!
    @IBOutlet weak var titleLabel:UILabel!
    var indexPath:IndexPath?
    weak var tableView:UITableView?
    weak var navigationController:UINavigationController?
    @IBOutlet weak var optionsButtonsWidth:NSLayoutConstraint!
    @IBOutlet weak var optionsButtonsView:UIView!
    var optionsState:kOptionsState = .closed
    var panStartPoint:CGPoint = CGPoint.zero
    @IBOutlet weak var separator:UIView!
    weak var parent:TargetVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(TargetCell.panAction(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(TargetCell.anotherCellOpenedOptions(_:)), name: NSNotification.Name(rawValue: kAnotherSingleTargetCellOpenedOptions), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SingleTargetCell.changeSelectedStyleOn), name: NSNotification.Name(rawValue: kChangeSingleTargetCellSelectedStyleOn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SingleTargetCell.changeSelectedStyleOff), name: NSNotification.Name(rawValue: kChangeSingleTargetCellSelectedStyleOff), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            self.setSelected(false, animated: animated)
        }
    }
    
    func anotherCellOpenedOptions(_ notification:Notification) {
        let senderCell = notification.object as? SingleTargetCell
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
    
    override func prepareForReuse() {
        titleLabel.text = ""
        closeCellOptions()
        separator.alpha = 1.0
        targetTypeIcon.image = nil
        completionColorView.backgroundColor = redSingleTargetColor
        indexPath = nil
        tableView = nil
    }
    
    func loadTarget(_ target:Target, isLast:Bool) {
        titleLabel.text = target.textForDisplay()
        if (isLast) {
            separator.alpha = 0.0
        }
        let imageName = target.activity.iconName(big: true)
        targetTypeIcon.image = UIImage(named: imageName)
        let progress = target.calculateProgress(false)
        if (progress.completionPercentage >= 1.0) {
            completionColorView.backgroundColor = greenSingleTargetColor
        } else if (progress.completionPercentage >= 0.8) {
            completionColorView.backgroundColor = orangeSingleTargetColor
        } else {
            completionColorView.backgroundColor = redSingleTargetColor
        }
    }
    
    @IBAction func editTarget(_ sender:UIButton) {
        print("Ahmed suppose to be editing now")
        let vc = RecurringTargetVC()
        navigationController?.pushViewController(vc, animated: true)
        //DELEGATE.menuView?.open()
        print("Should have pushed to newtarget Ahmed")
        if demo() {
            let alert = UIAlertController(title: "", message: localized("demo_mode_edittarget"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
        } else {
//            print("Ahmed suppose to be editing now")
//            let vc = SettingsVC()
//            navigationController?.pushViewController(vc, animated: true)
//            print("Should have pushed to newtarget Ahmed")
           // closeCellOptions()
//            if (indexPath != nil) {
//            print("Ahmed suppose to be editing now")
//////                let target = dataManager.targets()[(indexPath! as NSIndexPath).row]
//                let vc = TermsViewController()
//                navigationController?.pushViewController(vc, animated: true)
//            }
        }
    }
    
    @IBAction func deleteTarget(_ sender:UIButton) {
        if demo() {
            let alert = UIAlertController(title: "", message: localized("demo_mode_deletetarget"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
        } else {
           // if (indexPath != nil) {
                UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_target"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
            //}
        }
    }
    
    //MARK: UIGestureRecognizer Delegate
    
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
                difference += kSingleButtonsWidth
            }
            if (difference < 0.0) {
                difference = 0.0
            } else if (difference > kSingleButtonsWidth) {
                difference = kSingleButtonsWidth
            }
            optionsButtonsWidth.constant = difference
            optionsButtonsView.setNeedsLayout()
            layoutIfNeeded()
        default:break
        }
    }
    
    func openCellOptions() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kAnotherSingleTargetCellOpenedOptions), object: self)
        optionsState = .open
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.optionsButtonsWidth.constant = kSingleButtonsWidth
            self.optionsButtonsView.setNeedsLayout()
            self.layoutIfNeeded()
        }, completion: { (done) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeSingleTargetCellSelectedStyleOff), object: nil)
            self.parent?.aCellIsOpen = true
        })
    }
    
    func closeCellOptions() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeSingleTargetCellSelectedStyleOn), object: nil)
        parent?.aCellIsOpen = false
        optionsState = .closed
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.optionsButtonsWidth.constant = 0.0
            self.optionsButtonsView.setNeedsLayout()
            self.layoutIfNeeded()
        }) 
    }
    
    //MARK: UIAlertView Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        closeCellOptions()
        if (buttonIndex > 0) {
            let target = dataManager.targets()[(indexPath! as NSIndexPath).row]
            dataManager.deleteTarget(target) { (success, failureReason) -> Void in
                if success {
                    dataManager.deleteObject(target)
                    AlertView.showAlert(true, message: localized("target_deleted_successfully"), completion: nil)
                    self.tableView?.deleteRows(at: [self.indexPath!], with: UITableViewRowAnimation.automatic)
                    self.tableView?.reloadData()
                } else {
                    AlertView.showAlert(false, message: failureReason, completion: nil)
                }
            }
        }
    }
}
