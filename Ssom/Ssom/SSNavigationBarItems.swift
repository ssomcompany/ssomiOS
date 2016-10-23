//
//  SSNavigationBarItems.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 22..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import UICountingLabel

@objc protocol SSNavigationBarItemsDelegate : NSObjectProtocol
{
    optional func updateTextRechargeTime(rechargeTime: String)
    optional func updateTextMessageCount(count: String)
}

class SSNavigationBarItems : UIView
{
    @IBOutlet var heartBarButtonView: UIView!
    @IBOutlet var imgViewHeart: UIImageView!
    @IBOutlet var imgTopPlus: UIImageView!
    @IBOutlet var lbHeartCount: UICountingLabel!
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

    weak var delegate: SSNavigationBarItemsDelegate!

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

        self.lbHeartCount.format = "%d"
        self.lbHeartCount.method = UILabelCountingMethod.Linear
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

    func changeHeartCount(count: Int) {
        let countNow = Int(self.lbHeartCount.text!)!
        self.lbHeartCount.countFrom(CGFloat(countNow), to: CGFloat(count), withDuration: 1.0)
//            self.lbHeartCount.text = "\(count)"

        if count == 0 {
            self.imgViewHeart.image = UIImage(named: "topHeartGray")
            self.imgTopPlus.image = UIImage(named: "topPlusGray")
        } else {
            self.imgViewHeart.image = UIImage(named: "topHeartShop")
            self.imgTopPlus.image = UIImage(named: "topPlus")
        }

        if SSAccountManager.sharedInstance.isAuthorized {
            if count < SSDefaultHeartCount {
                self.startHeartRechargeTimer()
            } else {
                self.stopHeartRechageTimer()
            }
        } else {
            self.stopHeartRechageTimer()
        }
    }

    func tapDownMessage() {
        if self.animated {
            self.imgViewMessage.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
    }

    func cancelTapMessage() {
        self.imgViewMessage.transform = CGAffineTransformIdentity
    }

    func changeMessageCount(count: Int, hiddenIfZero: Bool) {
        if count > 0 {
            self.imgViewMessage.image = UIImage(named: "messageRed")
            self.lbUnreadMessageCount.text = "\(count)"

            self.imgViewMessage.hidden = false
            self.lbUnreadMessageCount.hidden = false
        } else {
            if hiddenIfZero {
                self.imgViewMessage.hidden = true
                self.lbUnreadMessageCount.hidden = true
            } else {
                self.imgViewMessage.hidden = false
                self.lbUnreadMessageCount.hidden = false
            }

            self.imgViewMessage.image = UIImage(named: "message")
            self.lbUnreadMessageCount.text = "\(count)"
        }
    }

    var heartRechargeTimer: NSTimer!

    func startHeartRechargeTimer(needRestart: Bool = false) {
        print(#function)

        if needRestart {
            let now = NSDate()
            SSNetworkContext.sharedInstance.saveSharedAttribute(now, forKey: "heartRechargeTimerStartedDate")

            self.lbRechargeTime.text = Util.getTimeIntervalString(from: now)
        } else {
            if let heartRechargeTimerStartedDate = SSNetworkContext.sharedInstance.getSharedAttribute("heartRechargeTimerStartedDate") as? NSDate {
                self.lbRechargeTime.text = Util.getTimeIntervalString(from: heartRechargeTimerStartedDate)
            } else {
                let now = NSDate()
                SSNetworkContext.sharedInstance.saveSharedAttribute(now, forKey: "heartRechargeTimerStartedDate")

                self.lbRechargeTime.text = Util.getTimeIntervalString(from: now)
            }
        }

        self.heartRechargeTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(changeHeartRechargerTimer(_:)), userInfo: nil, repeats: true)
    }

    func stopHeartRechageTimer(needToSave: Bool = false) {
        print(#function)

        if let timer = self.heartRechargeTimer {
            timer.invalidate()
            self.heartRechargeTimer = nil

            SSNetworkContext.sharedInstance.deleteSharedAttribute("heartRechargeTimerStartedDate")
        }

        self.lbRechargeTime.text = "00:00"

        if needToSave {
            // 타이머 값 서버에 저장
        }
    }

    func changeHeartRechargerTimer(sender: NSTimer?) {
        print(#function)

        if let heartRechargeTimerStartedDate = SSNetworkContext.sharedInstance.getSharedAttribute("heartRechargeTimerStartedDate") as? NSDate {
            print("heartRechargeTimerStartedDate is \(heartRechargeTimerStartedDate), now is \(NSDate()), time after 4hours is \(NSDate(timeInterval: SSDefaultHeartRechargeTimeInterval, sinceDate: heartRechargeTimerStartedDate))")

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            self.lbRechargeTime.text = Util.getTimeIntervalString(from: heartRechargeTimerStartedDate)

            if self.lbRechargeTime.text == "00:00" {
                // 하트 1개 구매 처리
                if let token = SSAccountManager.sharedInstance.sessionToken {

                    SSNetworkAPIClient.postPurchaseHearts(token, purchasedHeartCount: 1, completion: { [weak self] (heartsCount, error) in

                        guard let wself = self else { return }

                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                        } else {
                            NSNotificationCenter.defaultCenter().postNotificationName(SSInternalNotification.PurchasedHeart.rawValue, object: nil, userInfo: ["purchasedHeartCount": 1,
                                "heartsCount": heartsCount])

                            // 하트가 2개 이상이면, time 종료 처리
                            if heartsCount >= SSDefaultHeartCount {
                                wself.stopHeartRechageTimer()

                                SSAlertController.showAlertConfirm(title: "알림", message: String(format: "%d시간이 지나서 하트가 1개 충전되었습니다!!", SSDefaultHeartRechargeHour), completion: nil)
                            } else { // 하트가 2개 미만이면, time restart 처리
                                wself.startHeartRechargeTimer(true)
                            }
                        }
                    })
                }
            }
        } else {
            sender?.invalidate()
        }
    }

    func tapDownMeetRequest() {
        if self.animated {
            self.imgViewMeetRequest.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
    }

    func cancelTapMeetRequest() {
        self.imgViewMeetRequest.transform = CGAffineTransformIdentity
    }

    func changeMeetRequest(status: SSMeetRequestOptions = .NotRequested) {
        self.cancelTapMeetRequest()

        switch status {
        case .Requested:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonBlack")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
            self.btnMeetRequest.setTitle("요청 취소", forState: UIControlState.Normal)
        case .Accepted:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonBlack")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
            self.btnMeetRequest.setTitle("만남 종료", forState: UIControlState.Normal)
        case .Received:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonRed")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
            self.btnMeetRequest.setTitle("만남 수락", forState: UIControlState.Normal)
        case .Cancelled:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonRed")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            self.btnMeetRequest.setTitle("만남 요청", forState: UIControlState.Normal)
        default:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonRed")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            self.btnMeetRequest.setTitle("만남 요청", forState: UIControlState.Normal)
        }
    }
}
