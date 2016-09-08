//
//  SSNavigationBarItems.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 22..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

@objc protocol SSNavigationBarItemsDelegate : NSObjectProtocol
{
    optional func updateTextRechargeTime(rechargeTime: String)
    optional func updateTextMessageCount(count: String)
}

class SSNavigationBarItems : UIView
{
    @IBOutlet var heartBarButtonView: UIView!
    @IBOutlet var imgViewHeart: UIImageView!
    @IBOutlet var lbHeartCount: UILabel!
    @IBOutlet var lbRechargeTime: UILabel!
    @IBOutlet var btnHeartBar: UIButton!

    @IBOutlet var messageBarButtonView: UIView!
    @IBOutlet var imgViewMessage: UIImageView!
    @IBOutlet var lbUnreadMessageCount: UILabel!
    @IBOutlet var btnMessageBar: UIButton!

    @IBOutlet var backBarButtonView: UIView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var lbBackButtonTitle: UILabel!

    @IBOutlet var meetRequestButtonView: UIView!
    @IBOutlet var imgViewMeetRequest: UIImageView!
    @IBOutlet var btnMeetRequest: UIButton!
    @IBOutlet var imgViewMeetRequestHeart: UIImageView!

    var delegate: SSNavigationBarItemsDelegate!

    var animated: Bool = false

    init() {
        super.init(frame: CGRectZero)
        
        NSBundle.mainBundle().loadNibNamed("SSNavigationBarItems", owner: self, options: nil)

        self.btnHeartBar.addTarget(self, action: #selector(self.tapDownHeart), forControlEvents: UIControlEvents.TouchDown)
        self.btnHeartBar.addTarget(self, action: #selector(self.cancelTapHeart), forControlEvents: UIControlEvents.TouchCancel)

        self.btnMessageBar.addTarget(self, action: #selector(self.tapDownMessage), forControlEvents: UIControlEvents.TouchDown)
        self.btnMessageBar.addTarget(self, action: #selector(self.cancelTapMessage), forControlEvents: UIControlEvents.TouchCancel)

        self.btnMeetRequest.addTarget(self, action: #selector(self.tapDownMeetRequest), forControlEvents: UIControlEvents.TouchDown)
        self.btnMeetRequest.addTarget(self, action: #selector(self.cancelTapMeetRequest), forControlEvents: UIControlEvents.TouchCancel)
    }

    convenience init(animated: Bool) {
        self.init()

        self.animated = animated
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func tapDownHeart() {
        if self.animated {
            self.imgViewHeart.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
    }

    func cancelTapHeart() {
        self.imgViewHeart.transform = CGAffineTransformIdentity
    }

    func tapDownMessage() {
        if self.animated {
            self.imgViewMessage.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
    }

    func cancelTapMessage() {
        self.imgViewMessage.transform = CGAffineTransformIdentity
    }

    func tapDownMeetRequest() {
        if self.animated {
            self.imgViewMeetRequest.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
    }

    func cancelTapMeetRequest() {
        self.imgViewMeetRequest.transform = CGAffineTransformIdentity
    }

    func changeMeetRequest(inout isRequestedToMeet: Bool) {
        if isRequestedToMeet {
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonRed")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            self.btnMeetRequest.setTitle("        만남요청", forState: UIControlState.Normal)
            self.imgViewMeetRequestHeart.hidden = false
        } else {
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonBlack")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
            self.btnMeetRequest.setTitle("만남 취소", forState: UIControlState.Normal)
            self.imgViewMeetRequestHeart.hidden = true
        }

        isRequestedToMeet = !isRequestedToMeet
    }
}
