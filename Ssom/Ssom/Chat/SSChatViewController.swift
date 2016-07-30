//
//  SSChatViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 6..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var viewChatCoachmark: SSChatCoachmarkView!
    @IBOutlet var tableViewChat: UITableView!
    @IBOutlet var viewInputBar: UIView!
    @IBOutlet var tfInput: UITextField!
    @IBOutlet var constInputBarBottomToSuper: NSLayoutConstraint!

    var barButtonItems: SSNavigationBarItems!

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

        (self.tableViewChat as UIScrollView).delegate = self

        self.registerForKeyboardNotifications()

        self.showCoachmarkView()
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
        return self.messages.count == 0 ? 1 : self.messages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell: SSChatStartingTableCell = tableView.dequeueReusableCellWithIdentifier("chatStartingCell", forIndexPath: indexPath) as? SSChatStartingTableCell {
            // FIXME: need to change the ssom type
            cell.configView(SSType.SSOSEYO)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("chatStartingCell")

            return cell!
        }
    }

// MARK: - Keyboard show & hide event
    func keyboardWillShow(notification: NSNotification) -> Void {
        if let info = notification.userInfo {
            if let keyboardFrame: CGRect = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {

                self.constInputBarBottomToSuper.constant = keyboardFrame.size.height
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) -> Void {
        self.constInputBarBottomToSuper.constant = 0
    }
}
