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

class SSMenuHeadView: UIView {
    @IBOutlet var lbUserId: UILabel!
    @IBOutlet var btnSignOut: UIButton!

    var delegate: SSMenuHeadViewDelegate?

    func configView() -> Void {
        if SSAccountManager.sharedInstance.isAuthorized() {
            
        } else {

        }
    }

    @IBAction func tapSignOut(sender: AnyObject) {
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
