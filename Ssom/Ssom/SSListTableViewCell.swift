//
//  SSListTableViewCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 11..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

@objc protocol SSListTableViewCellDelegate: NSObjectProtocol {
    func deleteCell(cell: UITableViewCell)
    optional func tapProfileImage(sender: AnyObject, imageUrl: String)
}

class SSListTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var updatedTimeLabel: UILabel!
    @IBOutlet var memberInfoLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var imageTapButton: UIButton!
    
    @IBOutlet var viewCell: UIView!
    @IBOutlet var btnDeleteSsom: UIButton!
    @IBOutlet var constCellViewLeadingToSuper: NSLayoutConstraint!
    @IBOutlet var constCellViewTrailingToSuper: NSLayoutConstraint!

    weak var delegate: SSListTableViewCellDelegate?
    var profilImageUrl: String?

    var isCellOpened: Bool {
        return self.constCellViewLeadingToSuper.constant < 0
    }

    var isCellClosed: Bool {
        return self.constCellViewLeadingToSuper.constant == 0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panCell))
        panGesture.delegate = self
        self.contentView.addGestureRecognizer(panGesture)

        self.selectionStyle = .None

        self.viewCell.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).CGColor
        self.viewCell.layer.shadowRadius = 1.0
        self.viewCell.layer.shadowOffset = CGSizeMake(2, 0)
        self.viewCell.layer.shadowOpacity = 1.0
    }

    @IBAction func tapProfileImage(sender: AnyObject) {
        if (self.delegate?.respondsToSelector(#selector(tapProfileImage(_:))) != nil) {
            self.delegate?.tapProfileImage!(sender, imageUrl:self.profilImageUrl!)
        }
    }

    private var panStartPoint: CGPoint = CGPointZero
    private var startingRightLayoutConstraintConstant: CGFloat = 0.0

    func panCell(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            self.panStartPoint = gesture.translationInView(self.contentView)
            self.startingRightLayoutConstraintConstant = self.constCellViewLeadingToSuper.constant
        case .Changed:
            let currentPoint: CGPoint = gesture.translationInView(self.contentView)
            let deltaX: CGFloat = currentPoint.x - self.panStartPoint.x

            var panToLeft: Bool = false
            if deltaX < 0 {
                panToLeft = true
            }

            if panToLeft {
                if self.constCellViewTrailingToSuper.constant >= self.btnDeleteSsom.bounds.size.width {
                    self.constCellViewLeadingToSuper.constant = -self.btnDeleteSsom.bounds.size.width
                    self.constCellViewTrailingToSuper.constant = self.btnDeleteSsom.bounds.size.width
                } else {
                    if self.startingRightLayoutConstraintConstant == 0 {
                        self.constCellViewLeadingToSuper.constant = deltaX
                        self.constCellViewTrailingToSuper.constant = -deltaX
                    } else {
                        self.constCellViewLeadingToSuper.constant = self.startingRightLayoutConstraintConstant + deltaX
                        self.constCellViewTrailingToSuper.constant = -(self.startingRightLayoutConstraintConstant + deltaX)
                    }
                }
            } else {
                if self.constCellViewTrailingToSuper.constant <= 0 {
                    self.constCellViewLeadingToSuper.constant = 0
                    self.constCellViewTrailingToSuper.constant = 0
                } else {
                    if self.startingRightLayoutConstraintConstant == 0 {
                        self.constCellViewLeadingToSuper.constant = deltaX
                        self.constCellViewTrailingToSuper.constant = -deltaX
                    } else {
                        self.constCellViewLeadingToSuper.constant = self.startingRightLayoutConstraintConstant + deltaX
                        self.constCellViewTrailingToSuper.constant = -(self.startingRightLayoutConstraintConstant + deltaX)
                    }
                }
            }
        case .Ended:
            let halfOfButtonWidth: CGFloat = self.btnDeleteSsom.bounds.size.width / 2
            if self.constCellViewTrailingToSuper.constant > halfOfButtonWidth {
                self.openCell(true)
            } else {
                self.closeCell(true)
            }
        case .Cancelled, .Failed:
            print("cell pan gesture is cancelled!!")
            self.closeCell(true)
        default:
            break
        }
    }

    func openCell(animated: Bool) {
        var duration: NSTimeInterval = 0.0
        if animated {
            duration = 0.5
        }

        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: {

            self.constCellViewLeadingToSuper.constant = -self.btnDeleteSsom.bounds.size.width
            self.constCellViewTrailingToSuper.constant = self.btnDeleteSsom.bounds.size.width

            self.layoutIfNeeded()
            }, completion: nil)
    }

    func closeCell(animated: Bool) {
        var duration: NSTimeInterval = 0.0
        if animated {
            duration = 0.5
        }

        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: {

            self.constCellViewLeadingToSuper.constant = 0
            self.constCellViewTrailingToSuper.constant = 0

            self.layoutIfNeeded()
            }, completion: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.closeCell(false)
    }

    @IBAction func tapDeleteSsom(sender: AnyObject) {
        SSAlertController.showAlertConfirm(title: "알림", message: "성공적으로 삭제되었쏨!") { [unowned self] (action) in
            guard let _ = self.delegate?.deleteCell(self) else {
                return
            }
        }
    }
}
