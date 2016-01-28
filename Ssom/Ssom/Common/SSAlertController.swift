//
//  SSAlertController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 27..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

public class SSAlertController
{
    class func alertConfirm(title title: String, message: String, completion:((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: completion)
        alert.addAction(okAction)

        return alert
    }

    class func alertTwoButton(title title: String, message: String, button1Completion:((UIAlertAction) -> Void)?, button2Completion:((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.Default, handler: button1Completion)
        let cancelAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.Cancel, handler: button2Completion)
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        return alert
    }
}
