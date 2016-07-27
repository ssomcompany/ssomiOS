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
    static func alertConfirm(title title: String, message: String, vc:UIViewController, completion:((UIAlertAction) -> Void)?) -> Void {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: completion)
        alert.addAction(okAction)

        vc.presentViewController(alert, animated: true, completion: nil)
    }

    static func alertTwoButton(title title: String, message: String, vc:UIViewController, button1Completion:((UIAlertAction) -> Void)?, button2Completion:((UIAlertAction) -> Void)?) -> Void {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: button1Completion)
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.Cancel, handler: button2Completion)
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        vc.presentViewController(alert, animated: true, completion: nil)
    }
}
