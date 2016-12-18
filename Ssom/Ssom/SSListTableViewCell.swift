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
    func deleteCell(_ cell: UITableViewCell)
    @objc optional func tapProfileImage(_ sender: AnyObject, imageUrl: String)
}

class SSListTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var imgViewSsomIcon: UIImageView!
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

        self.selectionStyle = .none

        self.viewCell.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        self.viewCell.layer.shadowRadius = 1.0
        self.viewCell.layer.shadowOffset = CGSize(width: 2, height: 0)
        self.viewCell.layer.shadowOpacity = 1.0
    }

    override func layoutSubviews() {
        if UIScreen.main.bounds.width == 320.0 {
            self.constUpdatedTimeLabelLeadingToMemberInfoLabel.isActive = false
            self.constUpdatedTimeLableTrailingToSuper.isActive = true
            self.constDistanceLabelTopToSuper.constant = 10
        }

        super.layoutSubviews()
    }

    func configView(_ model: SSViewModel, isMySsom: Bool, isSsom: Bool, withCoordinate coordinate: CLLocationCoordinate2D) {
        if let content = model.content {
            print("content is \(content.removingPercentEncoding)")

            self.descriptionLabel.text = content.removingPercentEncoding
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

        if isSsom {
            self.imgViewSsomIcon.image = #imageLiteral(resourceName: "listMarkGreen")
        } else {
            self.imgViewSsomIcon.image = #imageLiteral(resourceName: "listMarkRed")
        }

//        let maskOfProfileImage: UIImage = UIImage.resizeImage(UIImage.init(named: isSsom ? "bigGreen" : "bigRed")!, frame: CGRect(x: 0, y: 0, width: 89.2, height: 77.2))
//        self.profileImageView!.image = maskOfProfileImage

        if let imageUrl = model.imageUrl {
            if imageUrl.lengthOfBytes(using: String.Encoding.utf8) != 0 {
                print("imageUrl is \(imageUrl)")

                self.profileImageView?.sd_setImage(with: URL(string: imageUrl+"?thumbnail=200")
                    , placeholderImage: nil
                    , options: []
                    , completed: { (image, error, cacheType, url) -> Void in

                        self.viewCell.layoutIfNeeded()
                        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2.0
                        self.profileImageView.layer.borderColor = isSsom ? UIColor(red: 0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1.0).cgColor : UIColor(red: 237.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0).cgColor
                        self.profileImageView.layer.borderWidth = 1.7

                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                        } else {
                            let croppedProfileImage: UIImage = UIImage.cropInCircle(image!, frame: CGRect(x: 0, y: 0, width: 70, height: 70))

                            self.profileImageView.image = croppedProfileImage
//                            self.profileImageView!.image = UIImage.mergeImages(firstImage: croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)

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
        memberInfoString = memberInfoString.appendingFormat("\(ageArea.rawValue)")
//        if let maxAge = model.maxAge {
//            memberInfoString = memberInfoString.stringByAppendingFormat("~\(maxAge)살")
//        }
        if let userCount = model.userCount {
            memberInfoString = memberInfoString.appendingFormat(" \(userCount)명 있어요.")
        }
        self.memberInfoLabel.text = memberInfoString
        self.memberInfoLabel.textColor = isSsom ? UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1) : UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)

        if let distance = model.distance, distance != 0 {
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

    @IBAction func tapProfileImage(_ sender: AnyObject) {
        if (self.delegate?.responds(to: #selector(tapProfileImage(_:))) != nil) {
            self.delegate?.tapProfileImage!(sender, imageUrl:self.profilImageUrl!)
        }
    }

    fileprivate var panStartPoint: CGPoint = CGPoint.zero
    fileprivate var startingRightLayoutConstraintConstant: CGFloat = 0.0

    func panCell(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.panStartPoint = gesture.translation(in: self.contentView)
            self.startingRightLayoutConstraintConstant = self.constCellViewLeadingToSuper.constant
        case .changed:
            let currentPoint: CGPoint = gesture.translation(in: self.contentView)
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
        case .ended:
            let halfOfButtonWidth: CGFloat = self.btnDeleteSsom.bounds.size.width / 2
            if self.constCellViewTrailingToSuper.constant > halfOfButtonWidth {
                self.openCell(true)
            } else {
                self.closeCell(true)
            }
        case .cancelled, .failed:
            print("cell pan gesture is cancelled!!")
            self.closeCell(true)
        default:
            break
        }
    }

    func openCell(_ animated: Bool) {
        var duration: TimeInterval = 0.0
        if animated {
            duration = 0.5
        }

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {

            self.constCellViewLeadingToSuper.constant = -self.btnDeleteSsom.bounds.size.width
            self.constCellViewTrailingToSuper.constant = self.btnDeleteSsom.bounds.size.width

            self.layoutIfNeeded()
            }, completion: nil)
    }

    func closeCell(_ animated: Bool) {
        var duration: TimeInterval = 0.0
        if animated {
            duration = 0.5
        }

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {

            self.constCellViewLeadingToSuper.constant = 0
            self.constCellViewTrailingToSuper.constant = 0

            self.layoutIfNeeded()
            }, completion: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.closeCell(false)
    }

    @IBAction func tapDeleteSsom(_ sender: AnyObject) {
        guard let _ = self.delegate?.deleteCell(self) else {
            return
        }
    }

// MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            if let view = gestureRecognizer.view {
                let translation: CGPoint = panGesture.translation(in: view.superview)

                return fabs(translation.x) > fabs(translation.y)
            }
        }
        return true;
    }
}
