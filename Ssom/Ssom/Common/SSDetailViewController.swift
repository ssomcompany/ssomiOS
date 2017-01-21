//
//  SSDetailViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 8. 2..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = false
        }

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    // MARK:- UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
