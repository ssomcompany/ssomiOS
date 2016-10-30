//
//  SSListTableViewCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 11..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import CoreLocation

@objc protocol SSListTableViewCellDelegate: NSObjectProtocol {
    func deleteCell(cell: UITableViewCell)
    optional func tapProfileImage(sender: AnyObject, imageUrl: String)
}

class SSListTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var updatedTimeLabel: UILabel!
    @IBOutlet var constUpdatedTimeLabelLeadingToMemberInfoLabel: NSLayoutConstraint!
    @IBOutlet var constUpdatedTimeLableTrailingToSuper: NSLayoutConstraint!
    @IBOutlet var memberInfoLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var constDistanceLabelTopToSuper: NSLayoutConstraint!
    @IBOutlet var imageTapButton: UIButton!
    
    @IBOutlet var viewCell: UIView!
    @IBOutlet var btnDeleteSsom: UIButton!
    @IBOutlet var constCellViewLeadingToSuper: NSLayoutConstraint!
    @IBOutlet var constCellViewTrailingToSuper: NSLayoutConstraint!

    weak var delegate: SSListTableViewCellDelegate?
    var profilImageUrl: String?

    var panGesture: UIPanGestureRecognizer!

    var isCellOpened: Bool {
        return self.constCellViewLeadingToSuper.constant < 0
    }

    var isCellClosed: Bool {
        return self.constCellViewLeadingToSuper.constant == 0
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .None

        self.viewCell.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).CGColor
        self.viewCell.layer.shadowRadius = 1.0
        self.viewCell.layer.shadowOffset = CGSizeMake(2, 0)
        self.viewCell.layer.shadowOpacity = 1.0
    }

    override func layoutSubviews() {
        if UIScreen.mainScreen().bounds.width == 320.0 {
            self.constUpdatedTimeLabelLeadingToMemberInfoLabel.active = false
            self.constUpdatedTimeLableTrailingToSuper.active = true
            self.constDistanceLabelTopToSuper.constant = 10
        }

        super.layoutSubviews()
    }

    func configView(model: SSViewModel, isMySsom: Bool, isSsom: Bool, withCoordinate coordinate: CLLocationCoordinate2D) {
        if let content = model.content {
            print("content is \(content.stringByRemovingPercentEncoding)")

            self.descriptionLabel.text = content.stringByRemovingPercentEncoding
        }

        if self.panGesture != nil {
            self.contentView.removeGestureRecognizer(self.panGesture)
            self.panGesture = nil
        }

        if isMySsom {
            self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCell))
            self.panGesture.delegate = self
            self.contentView.addGestureRecognizer(self.panGesture)
        }

        let maskOfProfileImage: UIImage = UIImage.resizeImage(UIImage.init(named: isSsom ? "bigGreen" : "bigRed")!, frame: CGRectMake(0, 0, 89.2, 77.2))
        self.profileImageView!.image = maskOfProfileImage

        if let imageUrl = model.imageUrl {
            if imageUrl.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
                print("imageUrl is \(imageUrl)")

                self.profileImageView?.sd_setImageWithURL(NSURL(string: imageUrl+"?thumbnail=200")
                    , placeholderImage: nil
                    , completed: { (image, error, cacheType, url) -> Void in

                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                        } else {
                            let croppedProfileImage: UIImage = UIImage.cropInCircle(image, frame: CGRectMake(0, 0, 72.2, 72.2))

                            self.profileImageView!.image = UIImage.mergeImages(firstImage: croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)

                            if model.meetRequestStatus == .Accepted {
                                if isSsom {
                                    self.profileImageView!.image = UIImage.mergeImages(firstImage: self.profileImageView!.image!, secondImage: UIImage(named: "ssomIngGreenBig")!, x: 2.3, y: 2.3, isFirstPoint: false)

                                } else {
                                    self.profileImageView!.image = UIImage.mergeImages(firstImage: self.profileImageView!.image!, secondImage: UIImage(named: "ssomIngRedBig")!, x: 2.3, y: 2.3, isFirstPoint: false)
                                }
                            }
                        }
                })

                self.profilImageUrl = imageUrl
            }
        }

        var memberInfoString:String = "";
        let ageArea: SSAgeAreaType = Util.getAgeArea(model.minAge)
        memberInfoString = memberInfoString.stringByAppendingFormat("\(ageArea.rawValue)")
//        if let maxAge = model.maxAge {
//            memberInfoString = memberInfoString.stringByAppendingFormat("~\(maxAge)살")
//        }
        if let userCount = model.userCount {
            memberInfoString = memberInfoString.stringByAppendingFormat(" \(userCount)명 있어요.")
        }
        self.memberInfoLabel.text = memberInfoString
        self.memberInfoLabel.textColor = isSsom ? UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1) : UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)

        if let distance = model.distance where distance != 0 {
            self.distanceLabel.text = Util.getDistanceString(distance)
        } else {
            let nowCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let ssomCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)

            let distance: Int = Int(Util.getDistance(locationFrom: nowCoordinate, locationTo: ssomCoordinate))
            model.distance = distance
            
            self.distanceLabel.text = Util.getDistanceString(distance)
        }
        
        self.updatedTimeLabel.text = Util.getDateString(model.createdDatetime)
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
        guard let _ = self.delegate?.deleteCell(self) else {
            return
        }
    }

// MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            if let view = gestureRecognizer.view {
                let translation: CGPoint = panGesture.translationInView(view.superview)

                return fabs(translation.x) > fabs(translation.y)
            }
        }
        return true;
    }
}
