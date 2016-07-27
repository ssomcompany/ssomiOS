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
        if let vc = storyBoard.instantiateInitialViewController() as? UINavigationController {
            vc.modalPresentationStyle = .OverFullScreen

            if let signInViewController: SSSignInViewController = vc.topViewController as? SSSignInViewController {
                signInViewController.completion = completion
            }

            willPresentViewController.presentViewController(vc, animated: true, completion: nil)
        }
    }

    func doSignIn(userId: String, password: String, vc:UIViewController, completion: ((finish: Bool) -> Void?)?) -> Void {
        SSNetworkAPIClient.postLogin(userId: userId, password: password) { error in
            if error != nil {
                print(error?.localizedDescription)

                SSAlertController.alertConfirm(title: "Error", message: (error?.localizedDescription)!, vc: vc, completion: { (alertAction) in
                    guard let _ = completion!(finish: false) else {
                        return
                    }
                })
            } else {
                SSNetworkContext.sharedInstance.saveSharedAttributes(["userId" : userId])

                guard let _ = completion!(finish: true) else {
                    return
                }
            }
        }
    }

    func doSignOut(vc: UIViewController, completion: ((finish: Bool) -> Void?)?) -> Void {

        SSAlertController.alertTwoButton(title: "", message: "로그아웃 하시겠습니까?", vc: vc, button1Completion: { (action) in
            print("button1!!")

            SSNetworkContext.sharedInstance.deleteSharedAttribute("token")
            SSNetworkContext.sharedInstance.deleteSharedAttribute("userId")

            guard let _ = completion!(finish: true) else {
                return
            }
            }) { (action) in
                print("button2!!")
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