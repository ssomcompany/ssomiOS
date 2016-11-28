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
    @IBOutlet var btnWarningDefault6CharactersPassword: UIButton!

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
        self.navigationController?.isNavigationBarHidden = true

        self.registerForKeyboardNotifications()

        self.btnFBSignUp.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3).cgColor
        self.btnFBSignUp.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.btnFBSignUp.layer.shadowRadius = 1.0
        self.btnFBSignUp.layer.shadowOpacity = 1.0
        self.btnFBSignUp.clipsToBounds = true
        self.btnFBSignUp.delegate = self
        self.btnFBSignUp.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        self.btnFBSignUp.readPermissions = ["public_profile", "email"]
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func registerForKeyboardNotifications() -> Void {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.viewBackground.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewBackground.isHidden = false

        self.defaultScrollContentHeight = self.scrollView.contentSize.height
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

            if touch.view != self.tfConfirmPassword {
                if self.tfConfirmPassword.isFirstResponder {
                    self.tfConfirmPassword.resignFirstResponder()
                }
            }
        }
    }

    func validateInput() -> Bool {
        var isSuccessToValidate = true

        if let email = tfEmail.text {
            if email.characters.count <= 0 {
                isSuccessToValidate = isSuccessToValidate && false
            } else {
                if !Util.isValidEmail(email) {
                    isSuccessToValidate = isSuccessToValidate && false
                }
            }
        }

        let password = tfPassword.text!
        if password.characters.count < kPasswordMinLength {
            isSuccessToValidate = isSuccessToValidate && false
        }

        if let confirmPassword = tfConfirmPassword.text {
            self.btnWarningWrongConfirmPassword.isHidden = true
            if confirmPassword.characters.count < kPasswordMinLength {
                isSuccessToValidate = isSuccessToValidate && false
            } else {
                if confirmPassword != password {
                    isSuccessToValidate = isSuccessToValidate && false

                    self.btnWarningWrongConfirmPassword.isHidden = false
                }
            }
        }

        self.btnSignUp.isEnabled = isSuccessToValidate;

        return isSuccessToValidate;
    }

    @IBAction func tapClose(_ sender: AnyObject?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapSignUp(_ sender: AnyObject?) {
        self.btnWarningDuplicatedEmail.isHidden = true

        SSNetworkAPIClient.postUser(tfEmail.text!, password: tfPassword.text!) { (error) in
            if let err = error {
                print(err.localizedDescription)

                if err.code == SSNetworkError.errorDuplicatedData.rawValue {
                    self.btnWarningDuplicatedEmail.isHidden = false
                } else {
                    SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                }
            } else {
                self.tapClose(nil)
            }
        }
    }

// MARK:- UITextFieldDelegate
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

    @IBAction func editingDidBeginConfirmPassword(_ sender: AnyObject) {
        self.lbConfirmPassword.textColor = UIColor.black
        self.viewConfirmPasswordBottomLine.image = UIImage(named: "pointWriteLine")
    }
    @IBAction func editingDidEndConfirmPassword(_ sender: AnyObject) {
        self.lbConfirmPassword.textColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        self.viewConfirmPasswordBottomLine.image = UIImage(named: "writeLine")
    }
    @IBAction func editingChangedConfirmPassword(_ sender: AnyObject) {
        self.validateInput()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.tfEmail {
            self.tfEmail.resignFirstResponder()
            self.tfPassword.becomeFirstResponder()
        }
        if textField === self.tfPassword {
            self.tfPassword.resignFirstResponder()
            self.tfConfirmPassword.becomeFirstResponder()
        }
        if textField === self.tfConfirmPassword && self.btnSignUp.isEnabled {
            self.tapSignUp(nil)
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
                print("%@", resultOfQuery)

                if let res = resultOfQuery as? [String: String] {

                    self.btnWarningDuplicatedEmail.isHidden = true

                    SSNetworkAPIClient.postUser(res["email"]!, password: "facebook") { (error) in
                        if let err = error {
                            print(err.localizedDescription)
                            
                            if err.code == SSNetworkError.errorDuplicatedData.rawValue {
                                self.btnWarningDuplicatedEmail.isHidden = false
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
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("%@", #function)
    }
}
