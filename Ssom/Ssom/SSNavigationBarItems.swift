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
    @IBOutlet var lbRechargeTime: UILabel!
    @IBOutlet var btnHeartBar: UIButton!

    @IBOutlet var messageBarButtonView: UIView!
    @IBOutlet var lbUnreadMessageCount: UILabel!
    @IBOutlet var btnMessageBar: UIButton!

    var delegate: SSNavigationBarItemsDelegate!

    init() {
        super.init(frame: CGRectZero)
        
        NSBundle.mainBundle().loadNibNamed("SSNavigationBarItems", owner: self, options: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    class func insert(action: Selector?, target: AnyObject?, inout toBarButtonItem: UIBarButtonItem) {
        if let insertedAction = action {
            toBarButtonItem.action = insertedAction
        }
        if let insertedTarget = target {
            toBarButtonItem.target = insertedTarget
        }
    }
}
