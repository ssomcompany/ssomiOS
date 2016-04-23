//
//  SSChatViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 6..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatViewController: UIViewController {

    var barButtonItems: SSNavigationBarItems!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

        self.setNavigationBarView()
    }

    func setNavigationBarView() {

        self.barButtonItems = SSNavigationBarItems()

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), forControlEvents: UIControlEvents.TouchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = ""

        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        var naviTitleViewFrame:CGRect = self.navigationItem.titleView!.frame
        naviTitleViewFrame = CGRectMake(naviTitleViewFrame.origin.x, naviTitleViewFrame.origin.y
            , naviTitleViewFrame.size.width, 38)
        self.navigationItem.titleView!.frame = naviTitleViewFrame

        let titleBackgroundView: UIImageView = UIImageView(image: UIImage(named: "1DepToggleOn.png"))
        titleBackgroundView.frame = CGRectMake(0, 0, 175, 38)
        self.navigationItem.titleView!.addSubview(titleBackgroundView)

        let btnNavi1: UIButton = UIButton(frame: CGRectMake(0, 0, 97, 38))
        btnNavi1.setTitle("MAP", forState: .Normal)
        btnNavi1.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        btnNavi1.setBackgroundImage(UIImage(named: "1DepToggleOff.png"), forState: .Selected)
        btnNavi1.selected = true
        self.navigationItem.titleView!.addSubview(btnNavi1)

        let btnNavi2: UIButton = UIButton(frame: CGRectMake(175-97, 0, 97, 38))
        btnNavi2.setTitle("LIST", forState: .Normal)
        btnNavi2.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1), forState: .Normal)
        btnNavi2.selected = false
        self.navigationItem.titleView!.addSubview(btnNavi2)

        if #available(iOS 8.2, *) {
            btnNavi1.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
            btnNavi2.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            btnNavi1.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
            btnNavi2.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        }

        self.navigationItem.leftBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem?.image = UIImage.resizeImage(UIImage(named: "manu.png")!, frame: CGRectMake(0, 0, 21, 14))

        var rightBarButtonItems: Array = self.navigationItem.rightBarButtonItems!
        if rightBarButtonItems.count == 2 {
            self.barButtonItems = SSNavigationBarItems()

            let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            barButtonSpacer.width = 20

            barButtonItems.btnHeartBar.addTarget(rightBarButtonItems[1].target, action: rightBarButtonItems[1].action, forControlEvents: UIControlEvents.TouchUpInside)
            let heartBarButton = UIBarButtonItem(customView: barButtonItems.heartBarButtonView!)

            barButtonItems.btnMessageBar.addTarget(rightBarButtonItems[0].target, action: rightBarButtonItems[0].action, forControlEvents: UIControlEvents.TouchUpInside)
            let messageBarButton = UIBarButtonItem(customView: barButtonItems.messageBarButtonView!)

            self.navigationItem.rightBarButtonItems = [messageBarButton, barButtonSpacer, heartBarButton]
        }
    }

    func initView() {
    }

    func tapBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
