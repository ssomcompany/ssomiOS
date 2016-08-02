//
//  SSChatViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 6..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatViewController: SSDetailViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var viewChatCoachmark: SSChatCoachmarkView!

    @IBOutlet var tableViewChat: UITableView!
    @IBOutlet var constTableViewChatTopToSuper: NSLayoutConstraint!
    @IBOutlet var constTableViewChatTopToViewRequest: NSLayoutConstraint!

    @IBOutlet var viewInputBar: UIView!
    @IBOutlet var tfInput: UITextField!
    @IBOutlet var constInputBarBottomToSuper: NSLayoutConstraint!

    @IBOutlet var viewRequest: UIView!
    @IBOutlet var lbRequestMeet: UILabel!
    @IBOutlet var btnRequestMeet: UIButton!

    var barButtonItems: SSNavigationBarItems!

    var chatRoomId: String?
    var ssomType: SSType = .SSOM
    var partnerImageUrl: String?
    var messages: [SSChatViewModel] = [SSChatViewModel]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.setNavigationBarView()

        self.initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showCoachmarkView() {
        self.viewChatCoachmark = UIView.loadFromNibNamed("SSChatCoachmarkView") as? SSChatCoachmarkView
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

        self.barButtonItems = SSNavigationBarItems()

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), forControlEvents: UIControlEvents.TouchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = ""

        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        let naviTitleView: UILabel = UILabel(frame: CGRectMake(0, 0, 150, 44))
        if #available(iOS 8.2, *) {
            naviTitleView.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            naviTitleView.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        }
        naviTitleView.textAlignment = .Center
        naviTitleView.text = "Chat"
        naviTitleView.sizeToFit()
        self.navigationItem.titleView = naviTitleView;

        let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        barButtonSpacer.width = -10

        barButtonItems.btnHeartBar.addTarget(self, action: #selector(tapHeart), forControlEvents: UIControlEvents.TouchUpInside)
        let heartBarButton = UIBarButtonItem(customView: barButtonItems.heartBarButtonView!)

        self.navigationItem.rightBarButtonItems = [heartBarButton, barButtonSpacer]
    }

    func initView() {
        self.tableViewChat.registerNib(UINib(nibName: "SSChatStartingTableCell", bundle: nil), forCellReuseIdentifier: "chatStartingCell")
        self.tableViewChat.registerNib(UINib(nibName: "SSChatMessageTableCell", bundle: nil), forCellReuseIdentifier: "chatMessageCell")

        (self.tableViewChat as UIScrollView).delegate = self

        self.registerForKeyboardNotifications()

        self.loadData()
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
                        }
                    }
                })
            }
        }
    }

    func registerForKeyboardNotifications() -> Void {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }

    func tapBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func tapHeart() {
        print("tapped heart!!")

        SSAlertController.alertTwoButton(title: "만남", message: "현재 대화상대에게\n만남을 요청 하시겠어요?", vc: self, button1Title: "만나요", button2Title: "취소", button1Completion: { (action) in

            UIView.animateWithDuration(0.5, animations: {
                self.constTableViewChatTopToSuper.active = false
                self.constTableViewChatTopToViewRequest.active = true

                self.view.layoutIfNeeded()
            })
            }) { (action) in
                //
        }
    }

    @IBAction func tapRequest(sender: AnyObject) {
        SSAlertController.alertTwoButton(title: "알림", message: "만남 취소 시 하트 1개가 소모됩니다.\n만남을 취소 하시겠어요?", vc: self, button1Title: "만남취소", button2Title: "닫기", button1Completion: { (action) in

            UIView.animateWithDuration(0.5, animations: {
                self.constTableViewChatTopToViewRequest.active = false
                self.constTableViewChatTopToSuper.active = true

                self.view.layoutIfNeeded()
            })
            }) { (action) in
                //
        }
    }
    
    @IBAction func tapSendMessage(sender: AnyObject) {
        if let token = SSAccountManager.sharedInstance.sessionToken {
            if let message = self.tfInput.text {
                var lastTimestamp = Int(NSDate().timeIntervalSince1970)
                if let timestamp = self.messages.last?.messageDateTime.timeIntervalSince1970 {
                    lastTimestamp = Int(timestamp)
                }

                if let roomId = self.chatRoomId {
                    SSNetworkAPIClient.postChatMessage(token, chatroomId: roomId, message: message, lastTimestamp: lastTimestamp, completion: { (datas, error) in
                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                        } else {
                            if let newDatas = datas {
                                self.messages.append(newDatas)

                                self.tableViewChat.reloadData()
                            }
                        }
                    })
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
                cell.partnerImageUrl = self.partnerImageUrl
                cell.configView(self.messages[indexPath.row-1])

                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("chatStartingCell") as? SSChatMessageTableCell
                cell!.ssomType = self.ssomType
                cell!.partnerImageUrl = self.partnerImageUrl
                cell!.configView(self.messages[indexPath.row-1])

                return cell!
            }
        }
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
