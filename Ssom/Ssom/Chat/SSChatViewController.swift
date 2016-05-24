//
//  SSChatViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 6..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatViewController: UIViewController {

    var viewChatCoachmark: SSChatCoachmarkView!
    @IBOutlet var tableViewChat: UITableView!
    @IBOutlet var viewInputBar: UIView!

    var barButtonItems: SSNavigationBarItems!

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
        naviTitleView.font = UIFont.systemFontOfSize(18)
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
        self.showCoachmarkView()
    }

    func tapBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func tapHeart() {
        print("tapped heart!!")
    }
}
