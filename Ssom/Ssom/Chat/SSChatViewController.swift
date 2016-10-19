//
//  SSChatViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 6..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatViewController: SSDetailViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {

// MARK: - properties
    var viewChatCoachmark: SSChatCoachmarkView!

    @IBOutlet var tableViewChat: UITableView!
    @IBOutlet var constTableViewChatTopToSuper: NSLayoutConstraint!
    @IBOutlet var constTableViewChatTopToViewRequest: NSLayoutConstraint!

    @IBOutlet var viewInputBar: UIView!
    @IBOutlet var constInputBarBottomToSuper: NSLayoutConstraint!
    @IBOutlet var tfInput: UITextField!
    @IBOutlet var btnSendMessage: UIButton!

    @IBOutlet var viewNotificationToStartMeet: UIView!
    @IBOutlet var constViewRequestHeight: NSLayoutConstraint!
    @IBOutlet var lbNotificationToStartMeet: UILabel!
    @IBOutlet var btnShowMap: UIButton!

    var barButtonItems: SSNavigationBarItems!

    var chatRoomId: String?
    var ssomType: SSType = .SSOM
    var postId: String?
    var myImageUrl: String?
    var partnerImageUrl: String?

    var ssomLatitude: Double = 0
    var ssomLongitude: Double = 0

    var messages: [SSChatViewModel] = [SSChatViewModel]()

    var meetRequestUserId: String?
    var meetRequestStatus: SSMeetRequestOptions = .NotRequested

    var refreshTimer: NSTimer!
    var isAlreadyShownCoachmark: Bool = false

// MARK: - functions
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.setNavigationBarView()

        self.initView()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if self.tfInput.isFirstResponder() {
            self.tfInput.resignFirstResponder()
        }

//        self.refreshTimer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showCoachmarkView() {
        if self.isAlreadyShownCoachmark {
            return
        }

        if self.viewChatCoachmark != nil && self.viewChatCoachmark.superview != nil {
            return
        }

        self.viewChatCoachmark = UIView.loadFromNibNamed("SSChatCoachmarkView") as? SSChatCoachmarkView
        self.viewChatCoachmark.closeBlock = { [weak self] in
            if let wself = self {
                wself.isAlreadyShownCoachmark = true
            }
        }
        if let appDelgate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let keyWindow = appDelgate.window

            keyWindow?.addSubview(self.viewChatCoachmark)
            self.viewChatCoachmark.translatesAutoresizingMaskIntoConstraints = false;
            keyWindow?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[viewChatCoachmark]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["viewChatCoachmark": self.viewChatCoachmark]))
            keyWindow?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[viewChatCoachmark]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["viewChatCoachmark": self.viewChatCoachmark]))

            keyWindow?.layoutIfNeeded()
        }
    }

    func setNavigationBarView() {

        self.barButtonItems = SSNavigationBarItems(animated: true)

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), forControlEvents: UIControlEvents.TouchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = ""

        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        let naviTitleView: UILabel = UILabel(frame: CGRectMake(0, 0, 150, 44))
        if #available(iOS 8.2, *) {
            naviTitleView.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 18) {
                naviTitleView.font = font
            }
        }
        naviTitleView.textAlignment = .Center
        naviTitleView.text = "Chat"
        naviTitleView.sizeToFit()
        self.navigationItem.titleView = naviTitleView;

        let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        barButtonSpacer.width = -10

        self.barButtonItems.btnMeetRequest.addTarget(self, action: #selector(tapMeetRequest), forControlEvents: UIControlEvents.TouchUpInside)
        let meetRequestButton = UIBarButtonItem(customView: barButtonItems.meetRequestButtonView!)

        self.navigationItem.rightBarButtonItems = [barButtonSpacer, meetRequestButton]
    }

    override func initView() {
        self.tableViewChat.registerNib(UINib(nibName: "SSChatStartingTableCell", bundle: nil), forCellReuseIdentifier: "chatStartingCell")
        self.tableViewChat.registerNib(UINib(nibName: "SSChatMessageTableCell", bundle: nil), forCellReuseIdentifier: "chatMessageCell")

        self.edgesForExtendedLayout = UIRectEdge.None

        (self.tableViewChat as UIScrollView).delegate = self

        self.registerForKeyboardNotifications()

//        self.viewNotificationToStartMeet.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
//        self.viewNotificationToStartMeet.layer.shadowOffset = CGSizeMake(0, 2)
//        self.viewNotificationToStartMeet.layer.shadowRadius = 1
//        self.viewNotificationToStartMeet.layer.shadowOpacity = 1

        self.loadData()

//        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)

        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let wself = self else { return }

            wself.tableViewChat.reloadData()

            let scrollOffset = wself.tableViewChat.contentSize.height - wself.tableViewChat.bounds.height
            wself.tableViewChat.setContentOffset(CGPointMake(0, scrollOffset <= 0 ? 0 : scrollOffset), animated: true)
        }
    }

    func loadData() {
        if let token = SSNetworkContext.sharedInstance.getSharedAttribute("token") as? String {
            if let roomId = self.chatRoomId {
                SSNetworkAPIClient.getChatMessages(token, chatroomId: roomId, completion: { [unowned self] (datas, error) in
                    if let err = error {
                        SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                    } else {
                        if let messages = datas {
                            self.messages = messages

                            if self.messages.count > 0 {
                                
                            } else {
                                self.showCoachmarkView()
                            }

                            self.tableViewChat.reloadData()

                            let scrollOffset = self.tableViewChat.contentSize.height - self.tableViewChat.bounds.height
                            self.tableViewChat.setContentOffset(CGPointMake(0, scrollOffset <= 0 ? 0 : scrollOffset), animated: true)

                            guard let requestUserId = self.meetRequestUserId else {
                                self.showMeetRequest(false)
                                return
                            }
                            if let loginedUserId = SSAccountManager.sharedInstance.userUUID {
                                if self.meetRequestStatus == .Accepted {
                                    self.showMeetRequest(true, status: .Accepted)
                                } else {
                                    if requestUserId == loginedUserId {
                                        self.showMeetRequest(false, status: .Requested)
                                    } else {
                                        self.showMeetRequest(false, status: .Received)
                                    }
                                }
                            } else {
                                self.showMeetRequest(false)
                            }
                        }
                    }
                })
            }
        }
    }

    func reload(with modelDict: [String: AnyObject]) {
        let newMessage = SSChatViewModel(modelDict: modelDict)

        switch newMessage.messageType {
        case .Normal:
            self.messages.append(newMessage)
        case .Request:
            self.showMeetRequest(false, status: .Received)
        case .Approve:
            self.showMeetRequest(true, status: .Accepted)
        default:
            break
        }

        self.tableViewChat.reloadData()

        let scrollOffset = self.tableViewChat.contentSize.height - self.tableViewChat.bounds.height
        self.tableViewChat.setContentOffset(CGPointMake(0, scrollOffset <= 0 ? 0 : scrollOffset), animated: true)
    }

    func registerForKeyboardNotifications() -> Void {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }

    func tapBack() {
        if self.meetRequestStatus == .Accepted {
            SSAlertController.alertTwoButton(title: "Info",
                                             message: "만남 중에는 채팅방을 나갈 수 없습니다.\n만남을 종료하고 나가시겠습니까?",
                                             vc: self,
                                             button1Completion: { (action) in
                                                self.cancelMeetRequest()
                                                self.navigationController?.popViewControllerAnimated(true)
                }, button2Completion: { (action) in
                    //
            })
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    func tapMeetRequest() {
        print("tapped meet request!!")

        switch self.meetRequestStatus {
        case .Requested:
            SSAlertController.alertTwoButton(title: "알림", message: "만남 요청을 취소 하시겠어요?", vc: self, button1Title: "요청취소", button2Title: "닫기", button1Completion: { (action) in
                self.cancelMeetRequest()
                }, button2Completion: { (action) in
                    //
            })
        case .Accepted:
            SSAlertController.alertTwoButton(title: "알림", message: "만남을 정말 취소 하시겠어요?", vc: self, button1Title: "만남취소", button2Title: "닫기", button1Completion: { (action) in
                self.cancelMeetRequest()
                }, button2Completion: { (action) in
                    //
            })
        case .Received:
            UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveLinear, animations: {
                self.barButtonItems.imgViewMeetRequest.transform = CGAffineTransformIdentity
            }) { (finish) in
                SSAlertController.alertTwoButton(title: "만남 요청", message: "상대방이 만남을 요청했습니다!\n수락 하시겠어요?", vc: self, button1Title: "만남 수락", button2Title: "아직은 좀...", button1Completion: { (action) in
                    guard let token = SSAccountManager.sharedInstance.sessionToken, let chatRoomId = self.chatRoomId else {
                        return
                    }

                    if chatRoomId.characters.count > 0 {
                        SSNetworkAPIClient.putMeetRequest(token, chatRoomId: chatRoomId, completion: { [weak self] (data, error) in
                            if let err = error {
                                SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                            } else {
                                if let wself = self {
                                    wself.showMeetRequest(true, status: .Accepted)
                                }
                            }
                        })
                    }
                    }, button2Completion: { (action) in
                        //
                })
            }
        case .NotRequested, .Cancelled:
            UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveLinear, animations: {
                self.barButtonItems.imgViewMeetRequest.transform = CGAffineTransformIdentity
            }) { (finish) in
                SSAlertController.alertTwoButton(title: "만남 요청", message: "현재 대화상대에게\n만남을 요청 하시겠어요?", vc: self, button1Title: "만나요", button2Title: "취소", button1Completion: { (action) in

                    guard let token = SSAccountManager.sharedInstance.sessionToken, let chatRoomId = self.chatRoomId else {
                        return
                    }

                    if chatRoomId.characters.count > 0 {

                        SSNetworkAPIClient.postMeetRequest(token, chatRoomId: chatRoomId, completion: { [weak self] (data, error) in
                            if let err = error {
                                SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                            } else {
                                if let wself = self {
                                    wself.showMeetRequest(false, status: .Requested)
                                }
                            }
                            })
                    } else {
                        SSAlertController.alertConfirm(title: "Error", message: "쏨 정보를 알 수 없습니다!", vc: self, completion: nil)
                    }
                }) { (action) in
                    //
                }
            }
        }
    }

    func showMeetRequest(enabled: Bool, status: SSMeetRequestOptions = .NotRequested) {
        defer {
            self.meetRequestStatus = status
        }

        self.barButtonItems.changeMeetRequest(status)

        var alpha:CGFloat = 0.0
        if enabled {

//            self.constTableViewChatTopToSuper.constant = 69
            self.constTableViewChatTopToSuper.active = false
            self.constTableViewChatTopToViewRequest.active = true

            self.constViewRequestHeight.constant = 43

            alpha = 1.0
        } else {

//            self.constTableViewChatTopToSuper.constant = 0
            self.constTableViewChatTopToViewRequest.active = false
            self.constTableViewChatTopToSuper.active = true

            self.constViewRequestHeight.constant = 0
        }

        UIView.animateWithDuration(0.9, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveLinear, animations: {
            self.view.layoutIfNeeded()
            self.viewNotificationToStartMeet.alpha = alpha
            }, completion: { (finish) in
                //
        })
    }

    func cancelMeetRequest() {
        guard let token = SSAccountManager.sharedInstance.sessionToken, let chatRoomId = self.chatRoomId else {
            return
        }

        SSNetworkAPIClient.deleteMeetRequest(token, chatRoomId: chatRoomId) { [weak self] (data, error) in
            if let err = error {
                SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
            } else {
                if let wself = self {
                    wself.showMeetRequest(false, status: .Cancelled)
                }
            }
        }
    }
    @IBAction func tapDownShowMap(sender: AnyObject) {
        self.btnShowMap.transform = CGAffineTransformMakeScale(0.9, 0.9)
    }

    @IBAction func tapShowMap(sender: AnyObject) {
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveLinear, animations: { 
            self.btnShowMap.transform = CGAffineTransformIdentity
            }) { (finish) in

                let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)

                let vc = chatStoryboard.instantiateViewControllerWithIdentifier("chatMapViewController") as! SSChatMapViewController
                let chatMapDict: [String: AnyObject?] = ["myImageUrl": self.myImageUrl,
                                                         "partnerImageUrl": self.partnerImageUrl,
                                                         "partnerLatitude": self.ssomLatitude,
                                                         "partnerLongitude": self.ssomLongitude,
                                                         "ssomType": self.ssomType.rawValue,
                                                         "ssomMeetRequestOptions": self.meetRequestStatus.rawValue]
                vc.data = SSChatMapViewModel(modelDict: chatMapDict)
                vc.blockCancelToMeet = { [weak self] in
                    if let wself = self {
                        wself.cancelMeetRequest()
                    }
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func tapDownSendMessage(sender: AnyObject) {
        self.btnSendMessage.transform = CGAffineTransformMakeScale(0.9, 0.9)
    }
    
    @IBAction func tapSendMessage(sender: AnyObject?) {
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveLinear, animations: { 
            self.btnSendMessage.transform = CGAffineTransformIdentity
            }) { (finish) in

                if let token = SSAccountManager.sharedInstance.sessionToken {
                    guard let messageText = self.tfInput.text else {
                        return
                    }

                    if messageText.characters.count > 0 {
                        var lastTimestamp = Int(NSDate().timeIntervalSince1970)
                        if let timestamp = self.messages.last?.messageDateTime.timeIntervalSince1970 {
                            lastTimestamp = Int(timestamp * 1000.0)
                        }

                        let nowDateTime = NSDate()

                        if let roomId = self.chatRoomId {
                            SSNetworkAPIClient.postChatMessage(token, chatroomId: roomId, message: messageText, lastTimestamp: lastTimestamp, completion: { [weak self] (datas, error) in

                                guard let wself = self else { return }

                                if let err = error {
                                    print(err.localizedDescription)

                                    SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: nil)
                                } else {
                                    if let newDatas = datas {
                                        wself.tfInput.text = ""

                                        if wself.messages.count != 0 {
                                            wself.messages.appendContentsOf(newDatas)
                                        } else {
                                            wself.messages = newDatas
                                        }

                                        // add my sent message on the last of the messages
                                        if let lastMessage = wself.messages.last where lastMessage.message != messageText && lastMessage.messageDateTime != nowDateTime {
                                            var myLastMessage = SSChatViewModel()
                                            myLastMessage.fromUserId = SSAccountManager.sharedInstance.userUUID!
                                            myLastMessage.message = messageText
                                            myLastMessage.messageDateTime = nowDateTime
                                            myLastMessage.profileImageUrl = wself.myImageUrl
                                            wself.messages.append(myLastMessage)
                                        }

                                        if wself.messages.count == 0 {
                                            var myLastMessage = SSChatViewModel()
                                            myLastMessage.fromUserId = SSAccountManager.sharedInstance.userUUID!
                                            myLastMessage.message = messageText
                                            myLastMessage.messageDateTime = nowDateTime
                                            myLastMessage.profileImageUrl = wself.myImageUrl
                                            wself.messages.append(myLastMessage)
                                        }

                                        wself.tableViewChat.reloadData()
                                    }

                                    let scrollOffset = wself.tableViewChat.contentSize.height - wself.tableViewChat.bounds.height
                                    wself.tableViewChat.setContentOffset(CGPointMake(0, scrollOffset <= 0 ? 0 : scrollOffset), animated: true)
                                }
                            })
                        }
                    }
                }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if touch.view !== self.tfInput {
                self.tfInput.resignFirstResponder()
            }
        }
    }

// MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if self.tfInput.isFirstResponder() {
            self.tfInput.resignFirstResponder()
        }
    }

// MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count == 0 ? 1 : self.messages.count + 1
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 ? 46 : 61
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell: SSChatStartingTableCell = tableView.dequeueReusableCellWithIdentifier("chatStartingCell", forIndexPath: indexPath) as? SSChatStartingTableCell {
                cell.configView(self.ssomType)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("chatStartingCell") as? SSChatStartingTableCell
                cell!.configView(self.ssomType)
                return cell!
            }
        } else {
            if let cell = tableView.dequeueReusableCellWithIdentifier("chatMessageCell", forIndexPath: indexPath) as? SSChatMessageTableCell {
                cell.ssomType = self.ssomType
                cell.configView(self.messages[indexPath.row-1])

                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("chatStartingCell") as? SSChatMessageTableCell
                cell!.ssomType = self.ssomType
                cell!.configView(self.messages[indexPath.row-1])

                return cell!
            }
        }
    }

// MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true;
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.characters.count > 0 {
            self.tapSendMessage(nil)
        }
        return true;
    }

// MARK: - Keyboard show & hide event
    func keyboardWillShow(notification: NSNotification) -> Void {
        if let info = notification.userInfo {
            if let keyboardFrame: CGRect = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {

                UIView.animateWithDuration(0.5, animations: {
                    self.constInputBarBottomToSuper.constant = keyboardFrame.size.height

                    self.view.layoutIfNeeded()

                    self.tableViewChat.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                })
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) -> Void {
        UIView.animateWithDuration(0.5) {
            self.constInputBarBottomToSuper.constant = 0

            self.view.layoutIfNeeded()
        }
    }
}
