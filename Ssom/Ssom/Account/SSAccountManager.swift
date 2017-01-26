//
//  SSAccountManager.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 23..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import FirebaseAuth
import KeychainAccess
import FBSDKLoginKit

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
        if let savedEmail = SSNetworkContext.sharedInstance.getSharedAttribute("email") as? String {
            return savedEmail
        } else {
            return nil
        }
    }

    var profileImageUrl: String? {
        if let imageUrl = SSNetworkContext.sharedInstance.getSharedAttribute("profileImageUrl") as? String {
            return imageUrl
        } else {
            return nil
        }
    }

    var userUUID: String? {
        if let savedUserId = SSNetworkContext.sharedInstance.getSharedAttribute("userId") as? String {
            return savedUserId
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

    func openSignIn(_ willPresentViewController: UIViewController?, completion: ((_ finish:Bool) -> Void)?) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "SSSign", bundle: nil)
        if let vc = storyBoard.instantiateInitialViewController() as? UINavigationController {
            vc.modalPresentationStyle = .overFullScreen

            if let signInViewController: SSSignInViewController = vc.topViewController as? SSSignInViewController {
                signInViewController.completion = completion
            }

            if let presentVC = willPresentViewController {
                presentVC.present(vc, animated: true, completion: nil)
            }
        }
    }

    func doSignIn(_ userId: String, password: String, vc:UIViewController?, completion: ((_ finish: Bool) -> Void?)?) -> Void {
        SSNetworkAPIClient.postLogin(userId: userId, password: password) { error in
            if let err = error {
                print(err.localizedDescription)

                if let viewController = vc {
                    SSAlertController.alertConfirm(
                        title: "Error",
                        message: err.code != 999 ? err.localizedDescription : "로그인 인증에 실패하였습니다!",
                        vc: viewController,
                        completion: { (alertAction) in
                        guard let _ = completion!(false) else {
                            return
                        }
                    })
                } else {
                    SSAlertController.showAlertConfirm(
                        title: "Error",
                        message: err.code != 999 ? err.localizedDescription : "로그인 인증에 실패하였습니다!",
                        completion: { (action) in
                        guard let _ = completion!(false) else {
                            return
                        }
                    })
                }
            } else {
                SSNetworkContext.sharedInstance.saveSharedAttributes(["email" : userId])

                guard let _ = completion!(true) else {
                    return
                }
            }
        }
    }

    func doSignIn(withFBSDKAccessToken token: String, email: String, vc:UIViewController?, completion: ((_ finish: Bool) -> Void?)?) -> Void {
        SSNetworkAPIClient.postLogin(withFBSDKAccessToken: token, email: email) { error in
            if let err = error {
                print(err.localizedDescription)

                if let viewController = vc {
                    SSAlertController.alertConfirm(
                        title: "Error",
                        message: err.code != 999 ? err.localizedDescription : "로그인 인증에 실패하였습니다!",
                        vc: viewController,
                        completion: { (alertAction) in
                            guard let _ = completion!(false) else {
                                return
                            }
                    })
                } else {
                    SSAlertController.showAlertConfirm(
                        title: "Error",
                        message: err.code != 999 ? err.localizedDescription : "로그인 인증에 실패하였습니다!",
                        completion: { (action) in
                            guard let _ = completion!(false) else {
                                return
                            }
                    })
                }
            } else {
                SSNetworkContext.sharedInstance.saveSharedAttributes(["email" : email])

                guard let _ = completion!(true) else {
                    return
                }
            }
        }
    }

    func doSignOut(_ vc: UIViewController?, completion: ((_ finish: Bool) -> Void)?) -> Void {

        if let viewController = vc {
            SSAlertController.alertTwoButton(title: "", message: "로그아웃 하시겠습니까?", vc: viewController, button1Completion: { (action) in
                print("logout!!")

                if let token = self.sessionToken {
                    SSNetworkAPIClient.postLogout(token, completion: { (error) in
                        if let err = error {
                            print(err.localizedDescription)

                            if let viewController = vc {
                                SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: viewController, completion: { (alertAction) in
                                    guard let block = completion else {
                                        return
                                    }
                                    block(false)
                                })
                            } else {
                                SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: { (alertAction) in
                                    guard let block = completion else {
                                        return
                                    }
                                    block(false)
                                })
                            }
                        } else {
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("token")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("email")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("profileImageUrl")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("userId")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("userModel")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("heartsCount")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("heartRechargeTimerStartedDate")

                            if let _ = FBSDKAccessToken.current() {
                                FBSDKLoginManager().logOut()
                            }

                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SSInternalNotification.SignOut.rawValue), object: nil)

                            guard let block = completion else {
                                return
                            }
                            block(true)
                        }
                    })
                } else {
                    if let viewController = vc {
                        SSAlertController.alertConfirm(title: "Error", message: "로그인 상태가 아닙니다!", vc: viewController, completion: { (action) in
                            guard let block = completion else {
                                return
                            }
                            block(false)
                        })
                    } else {
                        SSAlertController.showAlertConfirm(title: "Error", message: "로그인 상태가 아닙니다!", completion: { (action) in
                            guard let block = completion else {
                                return
                            }
                            block(false)
                        })
                    }
                }
            }) { (action) in
                print("logout cancelled!!")
            }
        } else {
            SSAlertController.showAlertTwoButton(title: "", message: "로그아웃 하시겠습니까?", button1Completion: { (action) in
                print("logout!!")

                if let token = self.sessionToken {
                    SSNetworkAPIClient.postLogout(token, completion: { (error) in
                        if let err = error {
                            print(err.localizedDescription)

                            if let viewController = vc {
                                SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: viewController, completion: { (alertAction) in
                                    guard let block = completion else {
                                        return
                                    }
                                    block(false)
                                })
                            } else {
                                SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: { (alertAction) in
                                    guard let block = completion else {
                                        return
                                    }
                                    block(false)
                                })
                            }
                        } else {
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("token")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("email")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("profileImageUrl")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("userId")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("userModel")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("heartsCount")
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("heartRechargeTimerStartedDate")

                            if let _ = FBSDKAccessToken.current() {
                                FBSDKLoginManager().logOut()
                            }

                            guard let block = completion else {
                                return
                            }
                            block(true)
                        }
                    })
                } else {
                    if let viewController = vc {
                        SSAlertController.alertConfirm(title: "Error", message: "로그인 상태가 아닙니다!", vc: viewController, completion: { (action) in
                            guard let block = completion else {
                                return
                            }
                            block(false)
                        })
                    } else {
                        SSAlertController.showAlertConfirm(title: "Error", message: "로그인 상태가 아닙니다!", completion: { (action) in
                            guard let block = completion else {
                                return
                            }
                            block(false)
                        })
                    }
                }
            }) { (action) in
                print("logout cancelled!!")
            }
        }
    }
}
