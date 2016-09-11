//
//  SSChatListTableCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 29..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import CoreLocation

protocol SSChatListTableCellDelegate: class {
    func deleteCell(cell: UITableViewCell)
    func tapProfileImage(imageUrl: String)
}

class SSChatListTableCell: UITableViewCell {
    @IBOutlet var viewBackground: UIView!
    @IBOutlet var constViewBackgroundLeadingToSuper: NSLayoutConstraint!
    @IBOutlet var constViewBackgroundTrailingToSuper: NSLayoutConstraint!

    @IBOutlet var btnChatDelete: UIButton!

    @IBOutlet var imgViewProfile: UIImageView!
    @IBOutlet var imgViewProfileBorder: UIImageView!
    @IBOutlet var lbSsomAgePeople: UILabel!
    @IBOutlet var lbLastMessage: UILabel!
    @IBOutlet var viewCountBackground: UIView!
    @IBOutlet var lbNewMessageCount: UILabel!
    @IBOutlet var lbDistance: UILabel!
    @IBOutlet var lbCreatedDate: UILabel!

    weak var delegate: SSChatListTableCellDelegate?
    var profilImageUrl: String?

    var isCellOpened: Bool {
        return self.constViewBackgroundLeadingToSuper.constant < 0
    }

    var isCellClosed: Bool {
        return self.constViewBackgroundLeadingToSuper.constant == 0
    }

    var isOwnerUser: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panCell))
        panGesture.delegate = self
        self.contentView.addGestureRecognizer(panGesture)

        self.selectionStyle = .None

        self.viewCountBackground.layer.cornerRadius = self.viewCountBackground.bounds.size.height / 2

        self.viewBackground.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).CGColor
        self.viewBackground.layer.shadowRadius = 1.0
        self.viewBackground.layer.shadowOffset = CGSizeMake(2, 0)
        self.viewBackground.layer.shadowOpacity = 1.0
    }

    func configView(model: SSChatroomViewModel, withCoordinate coordinate: CLLocationCoordinate2D) {
        switch model.ssomViewModel.ssomType {
        case .SSOM:
            self.imgViewProfileBorder.image = UIImage(named: "profileBorderGreen")
            self.viewCountBackground.backgroundColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1.0)
        case .SSOSEYO:
            self.imgViewProfileBorder.image = UIImage(named: "profileBorderRed")
            self.viewCountBackground.backgroundColor = UIColor(red: 237.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        }

        if let imageUrl = model.ssomViewModel.imageUrl {
            // check if the login user is the owner of the chatting
            if model.ownerUserId == SSAccountManager.sharedInstance.userModel?.userId {
                self.isOwnerUser = true
            } else {
                self.isOwnerUser = false
                if imageUrl.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
                    self.imgViewProfile.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: nil, completed: { [unowned self] (image, error, _, _) in
                        if error != nil {
                        } else {
                            let croppedProfileImage: UIImage = UIImage.cropInCircle(image, frame: CGRectMake(0, 0, self.imgViewProfile.bounds.size.width, self.imgViewProfile.bounds.size.height))

                            self.imgViewProfile.image = croppedProfileImage
                        }
                        })

                    self.profilImageUrl = imageUrl
                }
            }
        }

        var memberInfoString:String = "";
        let ageArea: SSAgeAreaType = Util.getAgeArea(model.ssomViewModel.minAge)
        memberInfoString = memberInfoString.stringByAppendingFormat("\(ageArea.rawValue)")
        if let userCount = model.ssomViewModel.userCount {
            memberInfoString = memberInfoString.stringByAppendingFormat(", \(userCount)명 있어요.")
        }
        self.lbSsomAgePeople.text = memberInfoString

        if model.lastMessage.characters.count > 0 {
            self.lbLastMessage.text = model.lastMessage
        }

        self.lbNewMessageCount.text = "\(model.unreadCount)"

        if let distance = model.ssomViewModel.distance where distance != 0 {
            self.lbDistance.text = Util.getDistanceString(distance)
        } else {
            let nowCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let ssomCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: model.ssomViewModel.latitude, longitude: model.ssomViewModel.longitude)

            let distance: Int = Int(Util.getDistance(locationFrom: nowCoordinate, locationTo: ssomCoordinate))
            model.ssomViewModel.distance = distance

            self.lbDistance.text = Util.getDistanceString(distance)
        }

        self.lbCreatedDate.text = Util.getDateString(model.createdDateTime)
    }

    private var panStartPoint: CGPoint = CGPointZero
    private var startingRightLayoutConstraintConstant: CGFloat = 0.0

    func panCell(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            self.panStartPoint = gesture.translationInView(self.contentView)
            self.startingRightLayoutConstraintConstant = self.constViewBackgroundLeadingToSuper.constant
        case .Changed:
            let currentPoint: CGPoint = gesture.translationInView(self.contentView)
            let deltaX: CGFloat = currentPoint.x - self.panStartPoint.x

            var panToLeft: Bool = false
            if deltaX < 0 {
                panToLeft = true
            }

            if panToLeft {
                if self.constViewBackgroundTrailingToSuper.constant >= self.btnChatDelete.bounds.size.width {
                    self.constViewBackgroundLeadingToSuper.constant = -self.btnChatDelete.bounds.size.width
                    self.constViewBackgroundTrailingToSuper.constant = self.btnChatDelete.bounds.size.width
                } else {
                    if self.startingRightLayoutConstraintConstant == 0 {
                        self.constViewBackgroundLeadingToSuper.constant = deltaX
                        self.constViewBackgroundTrailingToSuper.constant = -deltaX
                    } else {
                        self.constViewBackgroundLeadingToSuper.constant = self.startingRightLayoutConstraintConstant + deltaX
                        self.constViewBackgroundTrailingToSuper.constant = -(self.startingRightLayoutConstraintConstant + deltaX)
                    }
                }
            } else {
                if self.constViewBackgroundTrailingToSuper.constant <= 0 {
                    self.constViewBackgroundLeadingToSuper.constant = 0
                    self.constViewBackgroundTrailingToSuper.constant = 0
                } else {
                    if self.startingRightLayoutConstraintConstant == 0 {
                        self.constViewBackgroundLeadingToSuper.constant = deltaX
                        self.constViewBackgroundTrailingToSuper.constant = -deltaX
                    } else {
                        self.constViewBackgroundLeadingToSuper.constant = self.startingRightLayoutConstraintConstant + deltaX
                        self.constViewBackgroundTrailingToSuper.constant = -(self.startingRightLayoutConstraintConstant + deltaX)
                    }
                }
            }
        case .Ended:
            let halfOfButtonWidth: CGFloat = self.btnChatDelete.bounds.size.width / 2
            if self.constViewBackgroundTrailingToSuper.constant > halfOfButtonWidth {
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

            self.constViewBackgroundLeadingToSuper.constant = -self.btnChatDelete.bounds.size.width
            self.constViewBackgroundTrailingToSuper.constant = self.btnChatDelete.bounds.size.width

            self.layoutIfNeeded()
            }, completion: nil)
    }

    func closeCell(animated: Bool) {
        var duration: NSTimeInterval = 0.0
        if animated {
            duration = 0.5
        }

        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: {

            self.constViewBackgroundLeadingToSuper.constant = 0
            self.constViewBackgroundTrailingToSuper.constant = 0

            self.layoutIfNeeded()
            }, completion: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.closeCell(false)
    }

    @IBAction func tapDeleteChat(sender: AnyObject) {
        SSAlertController.showAlertTwoButton(title: "알림",
                                             message: "끝낸 쏨은 되돌릴 수 없어요...\n쏨을 정말로 끝내시겠어요?",
                                             button1Title: "끝내기",
                                             button2Title: "취소",
                                             button1Completion: { [unowned self] (action) in
                                                guard let _ = self.delegate?.deleteCell(self) else {
                                                    return
                                                }
            }) { (action) in
        }
    }

    @IBAction func tapShowPhoto(sender: AnyObject) {
        guard let _ = self.delegate?.tapProfileImage(self.profilImageUrl!) else {
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
