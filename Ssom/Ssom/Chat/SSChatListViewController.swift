//
//  SSChatListViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 23..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var chatListTableView: UITableView!

    var barButtonItems: SSNavigationBarItems!

    var datas: [SSChatroomViewModel] = [SSChatroomViewModel]()

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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setNavigationBarView() {

        self.barButtonItems = SSNavigationBarItems()

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), forControlEvents: UIControlEvents.TouchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = ""

        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        let naviTitleView: UILabel = UILabel(frame: CGRectMake(0, 0, 200, 44))
        if #available(iOS 8.2, *) {
            naviTitleView.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            naviTitleView.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        }
        naviTitleView.textAlignment = .Center
        naviTitleView.text = "Chat list"
        naviTitleView.sizeToFit()
        self.navigationItem.titleView = naviTitleView;

        var rightBarButtonItems: Array = self.navigationItem.rightBarButtonItems!

        let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        barButtonSpacer.width = 20

        barButtonItems.btnMessageBar.addTarget(rightBarButtonItems[0].target, action: rightBarButtonItems[0].action, forControlEvents: UIControlEvents.TouchUpInside)
        let messageBarButton = UIBarButtonItem(customView: barButtonItems.messageBarButtonView!)

        self.navigationItem.rightBarButtonItems = [messageBarButton]
    }

    func initView() {
        self.chatListTableView.registerNib(UINib(nibName: "SSChatListTableCell", bundle: nil), forCellReuseIdentifier: "chatListCell")

        self.edgesForExtendedLayout = UIRectEdge.None

        self.loadData()
    }

    func tapBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func loadData() {
        if let token: String = SSNetworkContext.sharedInstance.getSharedAttribute("token") as? String {
            SSNetworkAPIClient.getChatroomList(token, completion: { (models, error) in
                if error != nil {
                    print(error?.localizedDescription)

                    SSAlertController.alertConfirm(title: "Error", message: (error?.localizedDescription)!, vc: self, completion: nil)

                } else {
                    if let datas = models {
                        self.datas = datas

                        self.chatListTableView.reloadData()
                    }
                }
            })
        }
    }

// MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell: SSChatListTableCell = tableView.dequeueReusableCellWithIdentifier("chatListCell", forIndexPath: indexPath) as? SSChatListTableCell {
            cell.configView()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("chatListCell") as? SSChatListTableCell

            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
        let vc = chatStoryboard.instantiateViewControllerWithIdentifier("chatViewController") as! SSChatViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
