//
//  SSSignUpViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 3..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSSignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    func initView() {
        self.navigationController?.navigationBarHidden = true
    }

    @IBAction func tapClose(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
