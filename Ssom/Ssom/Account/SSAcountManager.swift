//
//  SSAcountManager.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 23..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import FirebaseAuth
import KeychainAccess

class SSAccountManager {
    static let sharedInstance = SSAccountManager()

    var isAuthorized: Bool {
        if let _ = SSNetworkContext.sharedInstance.getSharedAttribute("token") {
            return true
        } else {
            return false
        }
    }

    var sessionToken: String? {
        if let token = SSNetworkContext.sharedInstance.getSharedAttribute("token") as? String {
            return token
        } else {
            return nil
        }
    }

    var email: String? {
        if let savedEmail = SSNetworkContext.sharedInstance.getSharedAttribute("userId") as? String {
            return savedEmail
        } else {
            return nil
        }
    }

    var userModel: SSUserModel? {
        if let savedUserModel = SSNetworkContext.sharedInstance.getSharedAttribute("userModel") as? [String: AnyObject] {
            return SSUserModel(modelDict: savedUserModel)
        } else {
            return nil
        }
    }

    var userInFIB: FIRUser? {
        if let auth = FIRAuth.auth() {
            return auth.currentUser
        }

        return nil
    }

    var oneSignalPlayerId: String? {
        let keyChain = Keychain(service: "com.ssom")
        if let playerId = keyChain[string: "oneSignalPlayerID"] {
            return playerId
        }

        return nil
    }

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
            if let err = error {
                print(error?.localizedDescription)

                SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: vc, completion: { (alertAction) in
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
}
