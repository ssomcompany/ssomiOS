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
    var ageArea: SSAgeAreaType = .Unknown
    var peopleCount: SSPeopleCountStringType = .All
    var ssomType: SSType = .SSOM
    var postId: String?
    var myImageUrl: String?
    var partnerImageUrl: String?

    var ssomLatitude: Double = 0
    var ssomLongitude: Double = 0

    var messages: [SSChatViewModel] = [SSChatViewModel]()

    var meetRequestUserId: String?
    var meetRequestStatus: SSMeetRequestOptions = .NotRequested

    var refreshTimer: Timer!
    var isAlreadyShownCoachmark: Bool = false

// MARK: - functions
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.setNavigationBarView()

        self.initView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.tfInput.isFirstResponder {
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
        if let appDelgate = UIApplication.shared.delegate as? AppDelegate {
            let keyWindow = appDelgate.window

            keyWindow?.addSubview(self.viewChatCoachmark)
            self.viewChatCoachmark.translatesAutoresizingMaskIntoConstraints = false;
            keyWindow?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[viewChatCoachmark]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["viewChatCoachmark": self.viewChatCoachmark]))
            keyWindow?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[viewChatCoachmark]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["viewChatCoachmark": self.viewChatCoachmark]))

            keyWindow?.layoutIfNeeded()
        }
    }

    func setNavigationBarView() {

        self.barButtonItems = SSNavigationBarItems(animated: true)

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), for: UIControlEvents.touchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = ""
        var backButtonFrame = self.barButtonItems.backBarButtonView.frame
        backButtonFrame.size.width = 60
        self.barButtonItems.backBarButtonView.frame = backButtonFrame

        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        let naviTitleView: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 44))
        if #available(iOS 8.2, *) {
            naviTitleView.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 18) {
                naviTitleView.font = font
            }
        }
        naviTitleView.textAlignment = .center
        naviTitleView.text = "Chat"
        naviTitleView.sizeToFit()
        self.navigationItem.titleView = naviTitleView;

        self.showChatInfoOnNavigation()

        let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        barButtonSpacer.width = -10

        self.barButtonItems.btnMeetRequest.addTarget(self, action: #selector(tapMeetRequest), for: UIControlEvents.touchUpInside)
        let meetRequestButton = UIBarButtonItem(customView: barButtonItems.meetRequestButtonView!)

        self.navigationItem.rightBarButtonItems = [barButtonSpacer, meetRequestButton]
    }

    func showChatInfoOnNavigation() {
        if let naviTitleView = self.navigationItem.titleView as? UILabel {
            let peopleCount = self.peopleCount == .All ? "" : ", \(self.peopleCount.rawValue)"

            let titleAttributedString = NSMutableAttributedString(string: "Chat \(self.ageArea.rawValue)\(peopleCount)")

            if #available(iOS 8.2, *) {
                let firstAttributesDict = [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)]
                let secondAttributesDict = [NSForegroundColorAttributeName: UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0),
                                            NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)]
                titleAttributedString.addAttributes(firstAttributesDict, range: NSRange(location: 0, length: 5))
                titleAttributedString.addAttributes(secondAttributesDict, range: NSRange(location: 5, length: titleAttributedString.length - 5))
            } else {
                // Fallback on earlier versions
                if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 18) {
                    let firstAttributesDict = [NSFontAttributeName: font]
                    titleAttributedString.addAttributes(firstAttributesDict, range: NSRange(location: 0, length: 5))
                }
                if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 13) {
                    let secondAttributesDict = [NSForegroundColorAttributeName: UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0),
                                                NSFontAttributeName: font]
                    titleAttributedString.addAttributes(secondAttributesDict, range: NSRange(location: 5, length: titleAttributedString.length - 5))
                }
            }

            naviTitleView.attributedText = titleAttributedString
            naviTitleView.sizeToFit()
        }
    }

    override func initView() {
        self.tableViewChat.register(UINib(nibName: "SSChatStartingTableCell", bundle: nil), forCellReuseIdentifier: "chatStartingCell")
        self.tableViewChat.register(UINib(nibName: "SSChatMessageTableCell", bundle: nil), forCellReuseIdentifier: "chatMessageCell")

        self.edgesForExtendedLayout = UIRectEdge()

        (self.tableViewChat as UIScrollView).delegate = self

        self.tableViewChat.rowHeight = UITableViewAutomaticDimension
        self.tableViewChat.estimatedRowHeight = 61

        self.registerForKeyboardNotifications()

//        self.viewNotificationToStartMeet.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
//        self.viewNotificationToStartMeet.layer.shadowOffset = CGSizeMake(0, 2)
//        self.viewNotificationToStartMeet.layer.shadowRadius = 1
//        self.viewNotificationToStartMeet.layer.shadowOpacity = 1

        self.loadData()

//        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] (notification) in
            guard let wself = self else { return }

            wself.loadData()
        }
    }

    func loadData() {
        if let token = SSNetworkContext.sharedInstance.getSharedAttribute("token") as? String {
            if let roomId = self.chatRoomId {
                SSNetworkAPIClient.getChatMessages(token, chatroomId: roomId, completion: { [weak self] (datas, error) in
                    guard let wself = self else { return }

                    if let err = error {
                        SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: nil)
                    } else {
                        if let messages = datas {
                            wself.messages = messages

                            if wself.messages.count > 0 {
                                
                            } else {
                                wself.showCoachmarkView()
                            }

                            wself.tableViewChat.reloadData()

                            let lastIndexPath = IndexPath(row: wself.tableViewChat.numberOfRows(inSection: 0) - 1, section: 0)
                            wself.tableViewChat.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)

                            guard let requestUserId = wself.meetRequestUserId else {
                                wself.showMeetRequest(false)
                                return
                            }
                            if let loginedUserId = SSAccountManager.sharedInstance.userUUID {
                                if wself.meetRequestStatus == .Accepted {
                                    wself.showMeetRequest(true, status: .Accepted)
                                } else {
                                    if requestUserId == loginedUserId {
                                        wself.showMeetRequest(false, status: .Requested)
                                    } else {
                                        wself.showMeetRequest(false, status: .Received)
                                    }
                                }
                            } else {
                                wself.showMeetRequest(false)
                            }
                        }
                    }
                })
            }
        }
    }

    func reload(with modelDict: [String: AnyObject]) {

        DispatchQueue.main.async { [weak self] in
            guard let wself = self else { return }

            var newMessage = SSChatViewModel(modelDict: modelDict)

            if let loginUserId = SSAccountManager.sharedInstance.userUUID {
                if loginUserId == newMessage.fromUserId {
                    newMessage.profileImageUrl = wself.myImageUrl
                } else {
                    newMessage.profileImageUrl = wself.partnerImageUrl
                }
            }

            if wself.chatRoomId == newMessage.chatroomId {

                switch newMessage.messageType {
                case .Request:
                    wself.showMeetRequest(false, status: .Received)
                    newMessage.message = SSChatMessageType.Request.rawValue
                    newMessage.messageType = .System
                case .Approve:
                    wself.showMeetRequest(true, status: .Accepted)
                    newMessage.message = SSChatMessageType.Approve.rawValue
                    newMessage.messageType = .System
                case .Cancel:
                    wself.showMeetRequest(false)
                    newMessage.message = SSChatMessageType.Cancel.rawValue
                    newMessage.messageType = .System
                case .Finished:
                    wself.showMeetRequest(false)
                    newMessage.message = SSChatMessageType.Finished.rawValue
                    newMessage.messageType = .System
                default:
                    break
                }
                wself.messages.append(newMessage)

                wself.tableViewChat.reloadData()

                let lastIndexPath = IndexPath(row: wself.tableViewChat.numberOfRows(inSection: 0) - 1, section: 0)
                wself.tableViewChat.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
                
            }
        }
    }

    func registerForKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func tapBack() {
        if self.meetRequestStatus == .Accepted {
            SSAlertController.alertTwoButton(title: "알림",
                                             message: "만남 중에는 채팅방을 나갈 수 없습니다.\n만남을 종료하고 나가시겠습니까?",
                                             vc: self,
                                             button1Completion: { (action) in
                                                self.cancelMeetRequest()
                                                self.doBack()
                }, button2Completion: { (action) in
                    //
            })
        } else {
            self.doBack()
        }
    }

    func doBack() {
        if let token = SSAccountManager.sharedInstance.sessionToken, let chatRoomId = self.chatRoomId {
            SSNetworkAPIClient.putChatroomLastAccessTime(token, chatroomId: chatRoomId, completion: { [weak self] (_, error) in
                guard let wself = self else { return }

                if let err = error {
                    print(err.localizedDescription)

                    SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: nil)
                } else {
                    wself.navigationController?.popViewController(animated: true)
                }
            })
        }
    }

    func tapMeetRequest() {
        print(#function)

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
            UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveLinear, animations: {
                self.barButtonItems.imgViewMeetRequest.transform = CGAffineTransform.identity
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
            UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveLinear, animations: {
                self.barButtonItems.imgViewMeetRequest.transform = CGAffineTransform.identity
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

                                    // add my sent message on the last of the messages
                                    if var myLastMessage = data {
                                        if myLastMessage.messageType == .Request {
                                            myLastMessage.message = "request"
                                            myLastMessage.messageType = .System
                                        }
                                        myLastMessage.profileImageUrl = wself.myImageUrl
                                        wself.messages.append(myLastMessage)

                                        wself.tableViewChat.reloadData()

                                        let lastIndexPath = IndexPath(row: wself.tableViewChat.numberOfRows(inSection: 0) - 1, section: 0)
                                        wself.tableViewChat.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
                                    }
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
        default:
            break
        }
    }

    func showMeetRequest(_ enabled: Bool, status: SSMeetRequestOptions = .NotRequested) {
        defer {
            self.meetRequestStatus = status
        }

        self.barButtonItems.changeMeetRequest(status)

        var alpha:CGFloat = 0.0
        if enabled {

//            self.constTableViewChatTopToSuper.constant = 69
            self.constTableViewChatTopToSuper.isActive = false
            self.constTableViewChatTopToViewRequest.isActive = true

            self.constViewRequestHeight.constant = 43

            alpha = 1.0
        } else {

//            self.constTableViewChatTopToSuper.constant = 0
            self.constTableViewChatTopToViewRequest.isActive = false
            self.constTableViewChatTopToSuper.isActive = true

            self.constViewRequestHeight.constant = 0
        }

        UIView.animate(withDuration: 0.9, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveLinear, animations: {
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

                    // add my sent message on the last of the messages
                    var myLastMessage = SSChatViewModel()
                    myLastMessage.message = "cancel"
                    myLastMessage.messageType = .System
                    myLastMessage.fromUserId = SSAccountManager.sharedInstance.userUUID!
                    myLastMessage.profileImageUrl = wself.myImageUrl
                    wself.messages.append(myLastMessage)

                    wself.tableViewChat.reloadData()

                    let lastIndexPath = IndexPath(row: wself.tableViewChat.numberOfRows(inSection: 0) - 1, section: 0)
                    wself.tableViewChat.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
                }
            }
        }
    }
    @IBAction func tapDownShowMap(_ sender: AnyObject) {
        self.btnShowMap.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }

    @IBAction func tapShowMap(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveLinear, animations: { 
            self.btnShowMap.transform = CGAffineTransform.identity
            }) { (finish) in

                let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)

                let vc = chatStoryboard.instantiateViewController(withIdentifier: "chatMapViewController") as! SSChatMapViewController
                let chatMapDict: [String: Any?] = ["myImageUrl": self.myImageUrl,
                                                         "partnerImageUrl": self.partnerImageUrl,
                                                         "partnerLatitude": "\(self.ssomLatitude)",
                                                         "partnerLongitude": "\(self.ssomLongitude)",
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
    
    @IBAction func tapDownSendMessage(_ sender: AnyObject) {
        self.btnSendMessage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    @IBAction func tapSendMessage(_ sender: AnyObject?) {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveLinear, animations: { 
            self.btnSendMessage.transform = CGAffineTransform.identity
            }) { (finish) in

                if let token = SSAccountManager.sharedInstance.sessionToken {
                    guard let messageText = self.tfInput.text else {
                        return
                    }

                    if messageText.characters.count > 0 {
                        var lastTimestamp = Int(Date().timeIntervalSince1970)
                        if let timestamp = self.messages.last?.messageDateTime.timeIntervalSince1970 {
                            lastTimestamp = Int(timestamp * 1000.0)
                        }

                        let nowDateTime = Date()
print("start: \(Date())")
                        if let roomId = self.chatRoomId {
                            self.tfInput.text = ""

                            SSNetworkAPIClient.postChatMessage(token, chatroomId: roomId, message: messageText, lastTimestamp: lastTimestamp, completion: { [weak self] (datas, error) in
print("returned: \(Date())")
                                guard let wself = self else { return }

                                if let err = error {
                                    print(err.localizedDescription)

                                    SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: nil)
                                } else {
                                    if let newDatas = datas {
                                        if wself.messages.count != 0 {print("new message: \(Date())")
                                            wself.messages.append(contentsOf: newDatas)
                                        } else {print("all new message: \(Date())")
                                            wself.messages = newDatas
                                        }
print("last is : \(wself.messages.last!), sentDate is : \(nowDateTime)")
                                        // add my sent message on the last of the messages
                                        if let lastMessage = wself.messages.last, lastMessage.messageDateTime != nowDateTime {
                                            var myLastMessage = SSChatViewModel()
                                            myLastMessage.fromUserId = SSAccountManager.sharedInstance.userUUID!
                                            myLastMessage.message = messageText
                                            myLastMessage.messageDateTime = nowDateTime
                                            myLastMessage.profileImageUrl = wself.myImageUrl
                                            wself.messages.append(myLastMessage)
                                        }
print("last message: \(Date())")
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
print("same message: \(Date())")

//                                    let lastIndexPath = IndexPath(row: wself.tableViewChat.numberOfRows(inSection: 0) - 1, section: 0)
//                                    wself.tableViewChat.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)

                                    DispatchQueue.main.async(execute: { 

                                        wself.tableViewChat.setContentOffset(CGPoint(x: 0, y: wself.tableViewChat.contentSize.height - wself.tableViewChat.bounds.height), animated: true)
                                    })
print("### finished: \(Date()), contentSize:\(wself.tableViewChat.contentSize)")
                                }
                            })
                        }
                    }
                }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view !== self.tfInput {
                self.tfInput.resignFirstResponder()
            }
        }
    }

// MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.tfInput.isFirstResponder {
            self.tfInput.resignFirstResponder()
        }
    }

    var needToLoadMore: Bool = true
    var pageNumber: Int = 1
    var previousOffsetY: CGFloat = 0

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scroll 방향 체크
        if scrollView.contentOffset.y < self.previousOffsetY {
            // scroll 거의 상단에 다다랐을때...
            if scrollView.contentOffset.y <= 44 {
                if self.previousOffsetY == 0 {
                    self.needToLoadMore = true
                }

                if self.needToLoadMore {
                    self.pageNumber += 1
                    self.needToLoadMore = false

                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let wself = self else { return }

                        wself.tableViewChat.reloadData()

                        if (wself.messages.count + 1) != wself.tableViewChat.numberOfRows(inSection: 0) {
                            wself.tableViewChat.setContentOffset(CGPoint(x: 0, y: wself.tableViewChat.contentSize.height / CGFloat(wself.pageNumber)), animated: false)
                        }
                    })
                }
            } else {
                self.needToLoadMore = true
            }
        }

        self.previousOffsetY = scrollView.contentOffset.y
    }

// MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.messages.count == 0 {
            return 1
        } else if self.messages.count >= 60 {
            let pagingMessageCount = 60 * self.pageNumber + 1
            if pagingMessageCount > self.messages.count + 1 {
                return self.messages.count + 1
            }
            return pagingMessageCount
        } else {
            return self.messages.count + 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messages.count <= 60 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatStartingCell", for: indexPath) as! SSChatStartingTableCell
                cell.configView(self.ssomType)
                return cell
            } else {
                let chatModel = self.messages[indexPath.row-1]
                if chatModel.messageType == .System {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatStartingCell", for: indexPath) as! SSChatStartingTableCell
                    cell.configView(self.ssomType, model: chatModel)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatMessageCell", for: indexPath) as! SSChatMessageTableCell
                    cell.ssomType = self.ssomType
                    cell.configView(chatModel)
                    
                    return cell
                }
            }
        } else {
            var messageIndex = self.messages.count - (60 * self.pageNumber) - 1
            if self.messages.count <= 60 * self.pageNumber {
                messageIndex = -1
            }

            if (messageIndex + indexPath.row) == -1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatStartingCell", for: indexPath) as! SSChatStartingTableCell
                cell.configView(self.ssomType)
                return cell
            } else {
                let chatModel = self.messages[messageIndex + indexPath.row]
                if chatModel.messageType == .System {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatStartingCell", for: indexPath) as! SSChatStartingTableCell
                    cell.configView(self.ssomType, model: chatModel)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatMessageCell", for: indexPath) as! SSChatMessageTableCell
                    cell.ssomType = self.ssomType
                    cell.configView(chatModel)

                    return cell
                }
            }
        }
    }

// MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.characters.count > 0 {
            self.tapSendMessage(nil)
        }
        return true
    }

// MARK: - Keyboard show & hide event
    func keyboardWillShow(_ notification: Notification) -> Void {
        if let info = notification.userInfo {
            if let keyboardFrame: CGRect = (info[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {

                UIView.animate(withDuration: 0.5, animations: {
                    self.constInputBarBottomToSuper.constant = keyboardFrame.size.height

                    self.view.layoutIfNeeded()

                    let lastIndexPath = IndexPath(row: self.tableViewChat.numberOfRows(inSection: 0) - 1, section: 0)
                    self.tableViewChat.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
                })
            }
        }
    }

    func keyboardWillHide(_ notification: Notification) -> Void {
        UIView.animate(withDuration: 0.5, animations: {
            self.constInputBarBottomToSuper.constant = 0

            self.view.layoutIfNeeded()
        }) 
    }
}
