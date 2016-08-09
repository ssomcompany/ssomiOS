//
//  SSSignInViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 30..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSSignInViewController: UIViewController {

    @IBOutlet var viewBackground: UIView!
    @IBOutlet var viewSignIn: UIView!
    @IBOutlet var lbEmail: UILabel!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var viewEmailBottomLine: UIImageView!
    @IBOutlet var lbPassword: UILabel!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var viewPasswordBottomLine: UIImageView!
    @IBOutlet var btnSignIn: UIButton!

    var completion: ((finish: Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    func initView() {
        self.navigationController?.navigationBar.hidden = true

        self.viewBackground.hidden = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.viewBackground.hidden = false
    }

    func validateInput() -> Bool {
        var isSuccessToValidate = true

        if let email:String = tfEmail.text! {
            if email.characters.count <= 0 {
                isSuccessToValidate = isSuccessToValidate && false
            } else {
//                if !Util.isValidEmail(email) {
//                    isSuccessToValidate = isSuccessToValidate && false
//                }
            }
        }

        let password:String = tfPassword.text!
        if password.characters.count < kPasswordMinLength {
            isSuccessToValidate = isSuccessToValidate && false
        }

        self.btnSignIn.enabled = isSuccessToValidate;

        return isSuccessToValidate;
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if touch.view != self.tfEmail {
                if self.tfEmail.isFirstResponder() {
                    self.tfEmail.resignFirstResponder()
                }
            }

            if touch.view != self.tfPassword {
                if self.tfPassword.isFirstResponder() {
                    self.tfPassword.resignFirstResponder()
                }
            }
        }
    }

    @IBAction func tapClose(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapSignInButton(sender: AnyObject) {
        SSAccountManager.sharedInstance.doSignIn(self.tfEmail.text!, password: self.tfPassword.text!, vc: self) { [weak self] (finish) in
            if let wself = self {
                wself.tapClose(nil)

                guard let completionBlock = wself.completion else {
                    return nil
                }

                completionBlock(finish: finish)
            }

            return nil
        }
    }
    
    @IBAction func tapFindPasswordButton(sender: AnyObject) {
    }

    @IBAction func tapSignUpButton(sender: AnyObject) {
    }

    @IBAction func editingDidBeginEmail(sender: AnyObject) {
        self.lbEmail.textColor = UIColor.blackColor()
        self.viewEmailBottomLine.image = UIImage(named: "pointWriteLine")
    }
    @IBAction func editingDidEndEmail(sender: AnyObject) {
        self.lbEmail.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        self.viewEmailBottomLine.image = UIImage(named: "writeLine")
    }
    @IBAction func editingChangedEmail(sender: AnyObject) {
        self.validateInput()
    }

    @IBAction func editingDidBeginPassword(sender: AnyObject) {
        self.lbPassword.textColor = UIColor.blackColor()
        self.viewPasswordBottomLine.image = UIImage(named: "pointWriteLine")
    }
    @IBAction func editingDidEndPassword(sender: AnyObject) {
        self.lbPassword.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        self.viewPasswordBottomLine.image = UIImage(named: "writeLine")
    }
    @IBAction func editingChangedPassword(sender: AnyObject) {
        self.validateInput()
    }

}
