//
//  SSSignUpViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 3..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import FBSDKLoginKit

let kPasswordMinLength = 6

class SSSignUpViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet var viewBackground: UIView!
    @IBOutlet var scrollView: SSCustomScrollView!
    @IBOutlet var constScrollViewBottomToSuper: NSLayoutConstraint!

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
    @IBOutlet var btnFBSignUp: FBSDKLoginButton!

    var defaultScrollContentHeight: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    override func initView() {
        self.navigationController?.navigationBarHidden = true

        self.registerForKeyboardNotifications()

        self.btnFBSignUp.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).CGColor
        self.btnFBSignUp.layer.shadowOffset = CGSizeMake(0, 1)
        self.btnFBSignUp.layer.shadowRadius = 1.0
        self.btnFBSignUp.layer.shadowOpacity = 1.0
        self.btnFBSignUp.clipsToBounds = true
        self.btnFBSignUp.delegate = self
        self.btnFBSignUp.titleLabel!.font = UIFont.boldSystemFontOfSize(15)
        self.btnFBSignUp.readPermissions = ["public_profile", "email"]
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func registerForKeyboardNotifications() -> Void {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.viewBackground.hidden = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.viewBackground.hidden = false

        self.defaultScrollContentHeight = self.scrollView.contentSize.height
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

    // MARK:- UIScrollView

    // MARK: - Keyboard show & hide event
    func keyboardWillShow(notification: NSNotification) -> Void {
        if let info = notification.userInfo {
            if let keyboardFrame: CGRect = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {

                self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.defaultScrollContentHeight+keyboardFrame.height-self.constScrollViewBottomToSuper.constant)
                self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.height-self.constScrollViewBottomToSuper.constant)
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) -> Void {
        if let info = notification.userInfo {
            if let _ = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {

                self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.defaultScrollContentHeight)
            }
        }
    }

    // MARK:- FBSDKLoginButtonDelegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("%@", #function)

        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email"]).startWithCompletionHandler { (connection, resultOfQuery, error) in
            if let err = error {
                print(err.localizedDescription)

                SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
            } else {
                print("%@", resultOfQuery)

                if let res = resultOfQuery as? [String: String] {

                    self.btnWarningDuplicatedEmail.hidden = true

                    SSNetworkAPIClient.postUser(res["email"]!, password: "facebook") { (error) in
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

                        // 가입 후 로그인 하기 때문에..
                        FBSDKLoginManager().logOut()
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("%@", #function)
    }
}
