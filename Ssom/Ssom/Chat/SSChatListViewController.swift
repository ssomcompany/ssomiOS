//
//  SSChatListViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 23..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatListViewController : UIViewController {

    var barButtonItems: SSNavigationBarItems!

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
    }

    func tapBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
