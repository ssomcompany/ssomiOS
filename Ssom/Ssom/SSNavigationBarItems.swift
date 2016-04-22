//
//  SSNavigationBarItems.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 22..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

@objc protocol SSNavigationBarItemsDelegate : NSObjectProtocol
{
    optional func updateTextRechargeTime(rechargeTime: String)
    optional func updateTextMessageCount(count: String)
}

class SSNavigationBarItems : UIView
{
    @IBOutlet var heartBarButtonView: UIView!
    @IBOutlet var lbHeartCount: UILabel!
    @IBOutlet var lbRechargeTime: UILabel!
    @IBOutlet var btnHeartBar: UIButton!

    @IBOutlet var messageBarButtonView: UIView!
    @IBOutlet var lbUnreadMessageCount: UILabel!
    @IBOutlet var btnMessageBar: UIButton!

    @IBOutlet var backBarButtonView: UIView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var lbBackButtonTitle: UILabel!

    var delegate: SSNavigationBarItemsDelegate!

    init() {
        super.init(frame: CGRectZero)
        
        NSBundle.mainBundle().loadNibNamed("SSNavigationBarItems", owner: self, options: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
