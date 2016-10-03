//
//  SSSignInViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 30..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSSignInViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet var viewBackground: UIView!
    @IBOutlet var scrollView: SSCustomScrollView!
    @IBOutlet var constScrollViewBottomToSuper: NSLayoutConstraint!
    @IBOutlet var viewSignIn: UIView!
    @IBOutlet var lbEmail: UILabel!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var viewEmailBottomLine: UIImageView!
    @IBOutlet var lbPassword: UILabel!
    @IBOutlet var tfPassword: UITextField!
    @IBOutlet var viewPasswordBottomLine: UIImageView!
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var btnFindPassword: UIButton!
    @IBOutlet var btnSignUp: UIButton!

    var completion: ((finish: Bool) -> Void)?

    var defaultScrollContentHeight: CGFloat = 0.0

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    override func initView() {
        self.navigationController?.navigationBar.hidden = true

        self.viewBackground.hidden = true

        self.btnSignIn.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).CGColor
        self.btnSignIn.layer.shadowOffset = CGSizeMake(0, 1)
        self.btnSignIn.layer.shadowRadius = 1.0
        self.btnSignIn.layer.shadowOpacity = 1.0

        self.btnFindPassword.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).CGColor
        self.btnFindPassword.layer.shadowOffset = CGSizeMake(0, 1)
        self.btnFindPassword.layer.shadowRadius = 1.0
        self.btnFindPassword.layer.shadowOpacity = 1.0

        self.btnSignUp.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).CGColor
        self.btnSignUp.layer.shadowOffset = CGSizeMake(0, 1)
        self.btnSignUp.layer.shadowRadius = 1.0
        self.btnSignUp.layer.shadowOpacity = 1.0

        self.registerForKeyboardNotifications()

    }

    func registerForKeyboardNotifications() -> Void {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.viewBackground.hidden = false

        self.defaultScrollContentHeight = self.scrollView.contentSize.height
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

    @IBAction func tapSignInButton(sender: AnyObject?) {
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
        SSAlertController.alertConfirm(title: "Info", message: "아직 지원되지 않는 기능입니다.", vc: self, completion: nil)
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

// MARK:- UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === self.tfEmail {
            self.tfEmail.resignFirstResponder()
            self.tfPassword.becomeFirstResponder()
        }
        if textField === self.tfPassword && self.btnSignIn.enabled {
            self.tapSignInButton(nil)
        }

        return true;
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
}
