//
//  UIViewController+Util.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 9. 26..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

extension UIViewController {
    var needToReload: Bool {
        get {
            return false
        }
        set {
            if newValue {
                if self is UINavigationController {
                    if let topViewController = (self as! UINavigationController).topViewController {
                        topViewController.initView()
                    }
                } else {
                    self.initView()
                }
            }
        }
    }

    func initView() {

    }
}
