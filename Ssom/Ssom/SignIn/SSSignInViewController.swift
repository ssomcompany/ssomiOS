//
//  SSSignInViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 30..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSSignInViewController: UIViewController {

    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var lbEmailGuide: UILabel!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var lbPasswordGuide: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    func initView() {

    }

    @IBAction func tapSignUpButton(sender: AnyObject) {
    }

    @IBAction func tapSignInButton(sender: AnyObject) {
    }

    @IBAction func editingDidBeginEmail(sender: AnyObject) {
        self.lbEmailGuide.hidden = true;
    }
    @IBAction func editingDidEndEmail(sender: AnyObject) {
    }

    @IBAction func editingDidBeginPassword(sender: AnyObject) {
        self.lbPasswordGuide.hidden = true;
    }
    @IBAction func editingDidEndPassword(sender: AnyObject) {
    }

}
