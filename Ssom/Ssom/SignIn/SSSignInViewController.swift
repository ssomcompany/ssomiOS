//
//  SSSignInViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 30..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import FBSDKLoginKit

extension FBSDKLoginButton {
    override open func layoutSubviews() {
        self.setTitle(Util.getFBLoginButtonTitle(self), for: UIControlState())

        super.layoutSubviews()
    }
}

class SSSignInViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, FBSDKLoginButtonDelegate {

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
    @IBOutlet var btnFBLogin: FBSDKLoginButton!
    @IBOutlet var btnFindPassword: UIButton!
    @IBOutlet var btnSignUp: UIButton!

    var completion: ((_ finish: Bool) -> Void)?

    var defaultScrollContentHeight: CGFloat = 0.0

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    override func initView() {
        self.navigationController?.navigationBar.isHidden = true

        self.viewBackground.isHidden = true

        self.btnSignIn.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).cgColor
        self.btnSignIn.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.btnSignIn.layer.shadowRadius = 1.0
        self.btnSignIn.layer.shadowOpacity = 1.0

        self.btnFindPassword.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).cgColor
        self.btnFindPassword.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.btnFindPassword.layer.shadowRadius = 1.0
        self.btnFindPassword.layer.shadowOpacity = 1.0

        self.btnFBLogin.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).cgColor
        self.btnFBLogin.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.btnFBLogin.layer.shadowRadius = 1.0
        self.btnFBLogin.layer.shadowOpacity = 1.0
        self.btnFBLogin.clipsToBounds = true
        self.btnFBLogin.delegate = self
        self.btnFBLogin.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        self.btnFBLogin.setTitle("로그아웃", for: UIControlState.selected)
        self.btnFBLogin.readPermissions = ["public_profile", "email"]

        self.btnSignUp.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).cgColor
        self.btnSignUp.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.btnSignUp.layer.shadowRadius = 1.0
        self.btnSignUp.layer.shadowOpacity = 1.0

        self.registerForKeyboardNotifications()

    }

    func registerForKeyboardNotifications() -> Void {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewBackground.isHidden = false

        self.defaultScrollContentHeight = self.scrollView.contentSize.height
    }

    func validateInput() -> Bool {
        var isSuccessToValidate = true

        if let email = self.tfEmail.text, email.characters.count <= 0 {
            isSuccessToValidate = isSuccessToValidate && false
        } else {
//            if !Util.isValidEmail(email) {
//                isSuccessToValidate = isSuccessToValidate && false
//            }
        }

        let password:String = tfPassword.text!
        if password.characters.count < kPasswordMinLength {
            isSuccessToValidate = isSuccessToValidate && false
        }

        self.btnSignIn.isEnabled = isSuccessToValidate;

        return isSuccessToValidate;
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view != self.tfEmail {
                if self.tfEmail.isFirstResponder {
                    self.tfEmail.resignFirstResponder()
                }
            }

            if touch.view != self.tfPassword {
                if self.tfPassword.isFirstResponder {
                    self.tfPassword.resignFirstResponder()
                }
            }
        }
    }

    @IBAction func tapClose(_ sender: AnyObject?) {
        self.close(isSignedIn: false)
    }

    func close(isSignedIn: Bool) {
        guard let completionBlock = self.completion else {
            self.dismiss(animated: true, completion: nil)
            return
        }

        self.dismiss(animated: true, completion: {
            completionBlock(isSignedIn)
        })
    }

    @IBAction func tapSignInButton(_ sender: AnyObject?) {
        SSAccountManager.sharedInstance.doSignIn(self.tfEmail.text!, password: self.tfPassword.text!, vc: self) { [weak self] (finish) in
            guard let wself = self else { return nil }

            if finish {
                wself.close(isSignedIn: finish)
            } else {
                wself.tfPassword.text = ""
                wself.validateInput()
            }

            return nil
        }
    }
    
    @IBAction func tapFindPasswordButton(_ sender: AnyObject) {
        SSAlertController.alertConfirm(title: "알림", message: "아직 지원되지 않는 기능입니다.", vc: self, completion: nil)
    }

    @IBAction func editingDidBeginEmail(_ sender: AnyObject) {
        self.lbEmail.textColor = UIColor.black
        self.viewEmailBottomLine.image = UIImage(named: "pointWriteLine")
    }
    @IBAction func editingDidEndEmail(_ sender: AnyObject) {
        self.lbEmail.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        self.viewEmailBottomLine.image = UIImage(named: "writeLine")
    }
    @IBAction func editingChangedEmail(_ sender: AnyObject) {
        self.validateInput()
    }

    @IBAction func editingDidBeginPassword(_ sender: AnyObject) {
        self.lbPassword.textColor = UIColor.black
        self.viewPasswordBottomLine.image = UIImage(named: "pointWriteLine")
    }
    @IBAction func editingDidEndPassword(_ sender: AnyObject) {
        self.lbPassword.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        self.viewPasswordBottomLine.image = UIImage(named: "writeLine")
    }
    @IBAction func editingChangedPassword(_ sender: AnyObject) {
        self.validateInput()
    }

// MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.tfEmail {
            self.tfEmail.resignFirstResponder()
            self.tfPassword.becomeFirstResponder()
        }
        if textField === self.tfPassword && self.btnSignIn.isEnabled {
            self.tapSignInButton(nil)
        }

        return true;
    }

// MARK:- UIScrollView

// MARK: - Keyboard show & hide event
    func keyboardWillShow(_ notification: Notification) -> Void {
        if let info = notification.userInfo {
            if let keyboardFrame: CGRect = (info[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {

                self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.defaultScrollContentHeight+keyboardFrame.height-self.constScrollViewBottomToSuper.constant)
                self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.height-self.constScrollViewBottomToSuper.constant)
            }
        }
    }

    func keyboardWillHide(_ notification: Notification) -> Void {
        if let info = notification.userInfo {
            if let _ = (info[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {

                self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.defaultScrollContentHeight)
            }
        }
    }

// MARK:- FBSDKLoginButtonDelegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("%@", #function)

        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email"]).start { (connection, resultOfQuery, error) in
            if let err = error {
                print(err.localizedDescription)

                SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
            } else {
                print("%@", resultOfQuery!)

                if let res = resultOfQuery as? [String: String] {

                    SSAccountManager.sharedInstance.doSignIn(withFBSDKAccessToken: result.token.tokenString, email: res["email"]!, vc: self, completion: { [weak self] (finish) in
                        if let wself = self {
                            if finish {
                                wself.tapClose(nil)

                                guard let completionBlock = wself.completion else {
                                    return nil
                                }
                                completionBlock(finish)
                            } else {
                                FBSDKLoginManager().logOut()
                            }
                        }
                        
                        return nil
                    })
                }
            }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("%@", #function)
    }
}
