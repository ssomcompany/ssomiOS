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
    @objc optional func updateTextRechargeTime(_ rechargeTime: String)
    @objc optional func updateTextMessageCount(_ count: String)
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

    @IBOutlet var filterBarButtonView: UIView!
    @IBOutlet var imgViewFilterIcon: UIImageView!
    @IBOutlet var btnFilterBar: UIButton!

    weak var delegate: SSNavigationBarItemsDelegate!

    var animated: Bool = false

    init() {
        super.init(frame: CGRect.zero)
        
        Bundle.main.loadNibNamed("SSNavigationBarItems", owner: self, options: nil)

        self.btnHeartBar.addTarget(self, action: #selector(self.tapDownHeart), for: UIControlEvents.touchDown)
        self.btnHeartBar.addTarget(self, action: #selector(self.cancelTapHeart), for: UIControlEvents.touchCancel)

        self.btnMessageBar.addTarget(self, action: #selector(self.tapDownMessage), for: UIControlEvents.touchDown)
        self.btnMessageBar.addTarget(self, action: #selector(self.cancelTapMessage), for: UIControlEvents.touchCancel)

        self.btnFilterBar.addTarget(self, action: #selector(self.tapDownFilter), for: UIControlEvents.touchDown)
        self.btnFilterBar.addTarget(self, action: #selector(self.cancelTapFilter), for: UIControlEvents.touchCancel)

        self.btnMeetRequest.addTarget(self, action: #selector(self.tapDownMeetRequest), for: UIControlEvents.touchDown)
        self.btnMeetRequest.addTarget(self, action: #selector(self.cancelTapMeetRequest), for: UIControlEvents.touchCancel)

        self.lbHeartCount.format = "%d"
        self.lbHeartCount.method = UILabelCountingMethod.linear

        NotificationCenter.default.addObserver(self, selector: #selector(changeHeartCount(_:)), name: NSNotification.Name(rawValue: SSInternalNotification.SignOut.rawValue), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(pauseHeartRechageTimer), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeHeartRechargerTimer(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    convenience init(animated: Bool) {
        self.init()

        self.animated = animated
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func tapDownHeart() {
        if self.animated {
            self.imgViewHeart.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    func cancelTapHeart() {
        self.imgViewHeart.transform = CGAffineTransform.identity
    }

    func changeHeartCount(_ count: Int = 0) {
        let countNow = Int(self.lbHeartCount.text!)!
        self.lbHeartCount.count(from: CGFloat(countNow), to: CGFloat(count), withDuration: 1.0)
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
            self.imgViewMessage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    func cancelTapMessage() {
        self.imgViewMessage.transform = CGAffineTransform.identity
    }

    func changeMessageCount(_ count: Int, hiddenIfZero: Bool) {
        if count > 0 {
            self.imgViewMessage.image = UIImage(named: "messageRed")
            self.lbUnreadMessageCount.text = "\(count)"

            self.imgViewMessage.isHidden = false
            self.lbUnreadMessageCount.isHidden = false
        } else {
            if hiddenIfZero {
                self.imgViewMessage.isHidden = true
                self.lbUnreadMessageCount.isHidden = true
            } else {
                self.imgViewMessage.isHidden = false
                self.lbUnreadMessageCount.isHidden = false
            }

            self.imgViewMessage.image = UIImage(named: "message")
            self.lbUnreadMessageCount.text = "\(count)"
        }
    }

    var heartRechargeTimer: Timer!

    func startHeartRechargeTimer(_ needRestart: Bool = false) {
        print("\(#function, #line)")

        // check if the heart recharging timer is already running..
        if let _ = SSNetworkContext.sharedInstance.getSharedAttribute("heartRechargetTimerStartedForNavigation") as? Bool {
            return
        }

        if needRestart {
            self.initHeartRechargeTime()
        } else {
            if let heartRechargeTimerStartedDate = SSNetworkContext.sharedInstance.getSharedAttribute("heartRechargeTimerStartedDate") as? Date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"

                let timeIntervalString = Util.getTimeIntervalString(from: heartRechargeTimerStartedDate)
                self.lbRechargeTime.text = timeIntervalString.0

                if timeIntervalString.1 <= 0 && timeIntervalString.2 <= 0 {
                    self.initHeartRechargeTime()
                } else {
                    self.lbRechargeTime.text = Util.getTimeIntervalString(from: heartRechargeTimerStartedDate).0
                }
            } else {
                self.initHeartRechargeTime()
            }
        }

        if let _ = self.heartRechargeTimer {
        } else {
            self.heartRechargeTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(changeHeartRechargerTimer(_:)), userInfo: nil, repeats: true)

            SSNetworkContext.sharedInstance.saveSharedAttribute(true, forKey: "heartRechargetTimerStartedForNavigation")
        }
    }

    func initHeartRechargeTime() {
        print("\(#function, #line)")

        let now = Date()
        SSNetworkContext.sharedInstance.saveSharedAttribute(now, forKey: "heartRechargeTimerStartedDate")

        self.lbRechargeTime.text = Util.getTimeIntervalString(from: now).0
    }

    func pauseHeartRechageTimer() {
        print("\(#function, #line)")

        if let timer = self.heartRechargeTimer {
            timer.invalidate()

            SSNetworkContext.sharedInstance.deleteSharedAttribute("heartRechargetTimerStartedForNavigation")
        }
    }

    func stopHeartRechageTimer(_ needToSave: Bool = false) {
        print("\(#function, #line)")

        if let timer = self.heartRechargeTimer {
            timer.invalidate()
        }

        self.heartRechargeTimer = nil

        SSNetworkContext.sharedInstance.deleteSharedAttribute("heartRechargeTimerStartedDate")

        SSNetworkContext.sharedInstance.deleteSharedAttribute("heartRechargetTimerStartedForNavigation")

        self.lbRechargeTime.text = "00:00"

        if needToSave {
            // 타이머 값 서버에 저장
        }
    }

    func changeHeartRechargerTimer(_ sender: Timer?) {
        print("\(#function, #line)")

        if let heartsCount = SSNetworkContext.sharedInstance.getSharedAttribute("heartsCount") as? Int, heartsCount >= SSDefaultHeartCount {
            self.stopHeartRechageTimer()

            return
        }

        if let heartRechargeTimerStartedDate = SSNetworkContext.sharedInstance.getSharedAttribute("heartRechargeTimerStartedDate") as? Date {
            print("heartRechargeTimerStartedDate for ##Navi## is \(heartRechargeTimerStartedDate), now is \(Date()), time after 4hours is \(Date(timeInterval: SSDefaultHeartRechargeTimeInterval, since: heartRechargeTimerStartedDate))")

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            let timeIntervalString = Util.getTimeIntervalString(from: heartRechargeTimerStartedDate)
            self.lbRechargeTime.text = timeIntervalString.0

            if timeIntervalString.1 <= 0 && timeIntervalString.2 <= 0 {
                // 하트 1개 구매 처리
                if let token = SSAccountManager.sharedInstance.sessionToken {

                    SSNetworkAPIClient.postPurchaseHearts(token, purchasedHeartCount: 1, completion: { [weak self] (heartsCount, error) in

                        guard let wself = self else { return }

                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                        } else {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: SSInternalNotification.PurchasedHeart.rawValue), object: nil, userInfo: ["purchasedHeartCount": 1, "heartsCount": heartsCount])

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
            } else {
                self.startHeartRechargeTimer()
            }
        } else {
            self.pauseHeartRechageTimer()
        }
    }

    func tapDownMeetRequest() {
        if self.animated {
            self.imgViewMeetRequest.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    func cancelTapMeetRequest() {
        self.imgViewMeetRequest.transform = CGAffineTransform.identity
    }

    func changeMeetRequest(_ status: SSMeetRequestOptions = .NotRequested) {
        self.cancelTapMeetRequest()

        switch status {
        case .Requested:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonBlack")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            self.btnMeetRequest.setTitle("요청 취소", for: UIControlState())
        case .Accepted:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonBlack")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            self.btnMeetRequest.setTitle("만남 종료", for: UIControlState())
        case .Received:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonRed")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            self.btnMeetRequest.setTitle("만남 수락", for: UIControlState())
        case .Cancelled:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonRed")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            self.btnMeetRequest.setTitle("만남 요청", for: UIControlState())
        default:
            self.imgViewMeetRequest.image = UIImage(named: "meetButtonRed")
            self.btnMeetRequest.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            self.btnMeetRequest.setTitle("만남 요청", for: UIControlState())
        }
    }

    func tapDownFilter() {
        if self.animated {
            self.imgViewFilterIcon.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    func cancelTapFilter() {
        self.imgViewFilterIcon.transform = CGAffineTransform.identity
    }

    func changeFilter(ssomTypes: [SSType] = [.SSOM, .SSOSEYO]) {
        if ssomTypes == [.SSOM] {
            self.imgViewFilterIcon.image = #imageLiteral(resourceName: "topIconGreen")
        } else if ssomTypes == [.SSOSEYO] {
            self.imgViewFilterIcon.image = #imageLiteral(resourceName: "topIconRed")
        } else {
            self.imgViewFilterIcon.image = #imageLiteral(resourceName: "topIconGreenred")
        }
    }
}
