//
//  SSAlertController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 27..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

public struct SSAlertController
{
    static func alertConfirm(title: String, message: String, vc:UIViewController, completion:((UIAlertAction) -> Void)?) -> Void {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: completion)
        alert.addAction(okAction)

        vc.present(alert, animated: true, completion: nil)
    }

    static func showAlertConfirm(title: String, message: String, completion:((UIAlertAction) -> Void)?) -> Void {
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController {

            if presentedViewController is UINavigationController {
                if let nowPresentedViewController = presentedViewController.presentedViewController {
                    SSAlertController.alertConfirm(title: title, message: message, vc: nowPresentedViewController, completion: completion)
                }
            } else {
                SSAlertController.alertConfirm(title: title, message: message, vc: presentedViewController, completion: completion)
            }
        }
    }

    static func alertTwoButton(title: String,
                                     message: String,
                                     vc:UIViewController,
                                     button1Title: String? = "확인",
                                     button2Title: String? = "취소",
                                     button1Completion:((UIAlertAction) -> Void)?,
                                     button2Completion:((UIAlertAction) -> Void)?) -> Void {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction: UIAlertAction = UIAlertAction(title: button1Title, style: UIAlertActionStyle.default, handler: button1Completion)
        let cancelAction: UIAlertAction = UIAlertAction(title: button2Title, style: UIAlertActionStyle.cancel, handler: button2Completion)
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        vc.present(alert, animated: true, completion: nil)
    }

    static func showAlertTwoButton(title: String,
                                         message: String,
                                         button1Title: String? = "확인",
                                         button2Title: String? = "취소",
                                         button1Completion:((UIAlertAction) -> Void)?,
                                         button2Completion:((UIAlertAction) -> Void)?) -> Void {
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController {

            if presentedViewController is UINavigationController {
                if let nowPresentedViewController = presentedViewController.presentedViewController {
                    SSAlertController.alertTwoButton(title: title, message: message, vc: nowPresentedViewController, button1Title: button1Title, button2Title: button2Title, button1Completion: button1Completion, button2Completion: button2Completion)
                }
            } else {
                SSAlertController.alertTwoButton(title: title, message: message, vc: presentedViewController, button1Title: button1Title, button2Title: button2Title, button1Completion: button1Completion, button2Completion: button2Completion)
            }
        }
    }

    static func alertTextField(title: String,
                                     message: String,
                                     vc:UIViewController,
                                     button1Title: String? = "확인",
                                     button2Title: String? = "취소",
                                     button1Completion:((UIAlertAction, String) -> Void)?,
                                     button2Completion:((UIAlertAction) -> Void)?) -> Void {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction: UIAlertAction = UIAlertAction(title: button1Title, style: UIAlertActionStyle.default) { (action) in
            guard let completion = button1Completion, let alertTextField = alert.textFields?.first else { return }

            completion(action, alertTextField.text!)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: button2Title, style: UIAlertActionStyle.cancel, handler: button2Completion)
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        alert.addTextField { (textField) in
            textField.placeholder = "신고 사유를 알려주세요!"
        }

        vc.present(alert, animated: true, completion: nil)
    }

    static func showAlertTextField(title: String,
                                         message: String,
                                         button1Title: String? = "확인",
                                         button2Title: String? = "취소",
                                         button1Completion:((UIAlertAction, String) -> Void)?,
                                         button2Completion:((UIAlertAction) -> Void)?) -> Void {
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController {

            if presentedViewController is UINavigationController {
                if let nowPresentedViewController = presentedViewController.presentedViewController {
                    SSAlertController.alertTextField(title: title, message: message, vc: nowPresentedViewController, button1Title: button1Title, button2Title: button2Title, button1Completion: button1Completion, button2Completion: button2Completion)
                }
            } else {
                SSAlertController.alertTextField(title: title, message: message, vc: presentedViewController, button1Title: button1Title, button2Title: button2Title, button1Completion: button1Completion, button2Completion: button2Completion)
            }
        }
    }
}
