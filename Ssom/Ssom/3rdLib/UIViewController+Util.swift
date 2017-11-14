//
//  UIViewController+Util.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 9. 26..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

public protocol Reloadable: class {
    var needToReload: Bool { get set }
    func initView()
}

extension Reloadable where Self: UIViewController {
    var needToReload: Bool {
        get {
            return false
        }
        set {
            if newValue {
                if self is UINavigationController {
                    if let topViewController = (self as! UINavigationController).topViewController as? Reloadable {
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
