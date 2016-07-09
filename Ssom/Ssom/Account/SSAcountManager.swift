//
//  SSAcountManager.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 23..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSAccountManager {
    static let sharedInstance = SSAccountManager()

    func openSignIn(willPresentViewController: UIViewController, completion: ((finish:Bool) -> Void)?) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "SSSignStoryBoard", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController()
        vc?.modalPresentationStyle = .OverFullScreen

        if completion != nil {
            completion!(finish: true)
        }

        willPresentViewController.presentViewController(vc!, animated: true, completion: nil)
    }

    func doSignIn(userId: String, password: String, vc:UIViewController, completion: (() -> Void?)?) -> Void {
        SSNetworkAPIClient.postLogin(userId: userId, password: password) { error in
            if error != nil {
                print(error?.localizedDescription)

                SSAlertController.alertConfirm(title: "Error", message: (error?.localizedDescription)!, vc: vc, completion: { (alertAction) in
                    guard let _ = completion!() else {
                        return
                    }
                })
            } else {
                SSNetworkContext.sharedInstance.saveSharedAttributes(["userId" : userId])

                guard let _ = completion!() else {
                    return
                }
            }
        }
    }

    func isAuthorized() -> Bool {
        if SSNetworkContext.sharedInstance.getSharedAttribute("token") != nil {
            return true
        } else {
            return false
        }
    }
}