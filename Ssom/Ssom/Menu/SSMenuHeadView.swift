//
//  SSMenuHeadView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSMenuHeadViewDelegate {
    func openSignIn(completion: (()-> Void)?)
}

class SSMenuHeadView: UITableViewHeaderFooterView {
    @IBOutlet var lbUserId: UILabel!
    @IBOutlet var btnSignOut: UIButton!

    var delegate: SSMenuHeadViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configView() -> Void {
        if SSAccountManager.sharedInstance.isAuthorized() {
            self.lbUserId.text = SSNetworkContext.sharedInstance.getSharedAttribute("userId") as? String
        } else {
            self.lbUserId.textColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1)
            self.lbUserId.text = "로그인"
        }
    }

    @IBAction func tapSignOut(sender: AnyObject) {
        SSAccountManager.sharedInstance.doSignOut(nil)
    }

    @IBAction func tapMenuUser(sender: AnyObject) {
        if SSAccountManager.sharedInstance.isAuthorized() {

        } else {
            guard let _ = self.delegate?.openSignIn(nil) else {
                return
            }
        }
    }

    @IBAction func tapMenuPush(sender: AnyObject) {
    }

    @IBAction func tapMenuHeart(sender: AnyObject) {
    }
}
