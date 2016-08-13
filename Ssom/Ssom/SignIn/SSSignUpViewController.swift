//
//  SSSignUpViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 3..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

let kPasswordMinLength = 6

class SSSignUpViewController: UIViewController {
    @IBOutlet var viewBackground: UIView!

    @IBOutlet var lbEmail: UILabel!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var viewEmailBottomLine: UIImageView!
    @IBOutlet var btnWarningDuplicatedEmail: UIButton!

    @IBOutlet var lbPassword: UILabel!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var viewPasswordBottomLine: UIImageView!

    @IBOutlet var lbConfirmPassword: UILabel!
    @IBOutlet var tfConfirmPassword: UITextField!
    @IBOutlet var viewConfirmPasswordBottomLine: UIImageView!
    @IBOutlet var btnWarningWrongConfirmPassword: UIButton!

    @IBOutlet var btnSignUp: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    func initView() {
        self.navigationController?.navigationBarHidden = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.viewBackground.hidden = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.viewBackground.hidden = false
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

            if touch.view != self.tfConfirmPassword {
                if self.tfConfirmPassword.isFirstResponder() {
                    self.tfConfirmPassword.resignFirstResponder()
                }
            }
        }
    }

    func validateInput() -> Bool {
        var isSuccessToValidate = true

        if let email:String = tfEmail.text! {
            if email.characters.count <= 0 {
                isSuccessToValidate = isSuccessToValidate && false
            } else {
                if !Util.isValidEmail(email) {
                    isSuccessToValidate = isSuccessToValidate && false
                }
            }
        }

        let password:String = tfPassword.text!
        if password.characters.count < kPasswordMinLength {
            isSuccessToValidate = isSuccessToValidate && false
        }

        if let confirmPassword:String = tfConfirmPassword.text! {
            self.btnWarningWrongConfirmPassword.hidden = true
            if confirmPassword.characters.count < kPasswordMinLength {
                isSuccessToValidate = isSuccessToValidate && false
            } else {
                if confirmPassword != password {
                    isSuccessToValidate = isSuccessToValidate && false

                    self.btnWarningWrongConfirmPassword.hidden = false
                }
            }
        }

        self.btnSignUp.enabled = isSuccessToValidate;

        return isSuccessToValidate;
    }

    @IBAction func tapClose(sender: AnyObject?) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapSignUp(sender: AnyObject) {
        self.btnWarningDuplicatedEmail.hidden = true

        SSNetworkAPIClient.postUser(tfEmail.text!, password: tfPassword.text!) { (error) in
            if let err = error {
                print(err.localizedDescription)

                if err.code == SSNetworkError.ErrorDuplicatedData.rawValue {
                    self.btnWarningDuplicatedEmail.hidden = false
                } else {
                    SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                }
            } else {
                self.tapClose(nil)
            }
        }
    }

// MARK:- UITextFieldDelegate
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

    @IBAction func editingDidBeginConfirmPassword(sender: AnyObject) {
        self.lbConfirmPassword.textColor = UIColor.blackColor()
        self.viewConfirmPasswordBottomLine.image = UIImage(named: "pointWriteLine")
    }
    @IBAction func editingDidEndConfirmPassword(sender: AnyObject) {
        self.lbConfirmPassword.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        self.viewConfirmPasswordBottomLine.image = UIImage(named: "writeLine")
    }
    @IBAction func editingChangedConfirmPassword(sender: AnyObject) {
        self.validateInput()
    }
}
