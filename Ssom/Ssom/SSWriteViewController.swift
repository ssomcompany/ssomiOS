//
//  SSWriteViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 30..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSWriteViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var profileView: UIView!

    let minWidthPayButton:CGFloat = 76
    let minHeightPayButton:CGFloat = 68
    let maxWidthPayButton:CGFloat = 95
    let maxHeightPayButton:CGFloat = 85

    @IBOutlet var textView: UITextView!
    @IBOutlet var textGuideLabel: UILabel!

    @IBOutlet var lbAge: UILabel!
    @IBOutlet var lbAgeTrailingText: UILabel!

    @IBOutlet var ageButton1: UIButton!
    @IBOutlet var ageButton2: UIButton!
    @IBOutlet var ageButton3: UIButton!
    @IBOutlet var ageButton4: UIButton!

    @IBOutlet var lbPeopleCount: UILabel!
    @IBOutlet var lbPeopleCountTrailingText: UILabel!

    @IBOutlet var peopleButton1: UIButton!
    @IBOutlet var peopleButton2: UIButton!
    @IBOutlet var peopleButton3: UIButton!
    @IBOutlet var peopleButton4: UIButton!

    @IBOutlet var btnIPay: UIButton!
    @IBOutlet var constWidthIPayButton: NSLayoutConstraint!
    @IBOutlet var constHeightIPayButton: NSLayoutConstraint!
    @IBOutlet var btnYouPay: UIButton!
    @IBOutlet var constWidthYouPayButton: NSLayoutConstraint!
    @IBOutlet var constHeightYouPayButton: NSLayoutConstraint!

    @IBOutlet var btnRegister: UIButton!

    var isIPay:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    func initView() {

        self.textView.delegate = self;
    }

    @IBAction func tapAgeButton1(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.ageButton1.selected = true;
        self.ageButton2.selected = false;
        self.ageButton3.selected = false;
        self.ageButton4.selected = false;

        self.ageButton1.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.ageButton2.backgroundColor = UIColor.whiteColor()
        self.ageButton3.backgroundColor = UIColor.whiteColor()
        self.ageButton4.backgroundColor = UIColor.whiteColor()

        self.lbAge.text = (self.ageButton1.titleLabel!.text)!+"반"
    }

    @IBAction func tapAgeButton2(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.ageButton1.selected = false;
        self.ageButton2.selected = true;
        self.ageButton3.selected = false;
        self.ageButton4.selected = false;

        self.ageButton1.backgroundColor = UIColor.whiteColor()
        self.ageButton2.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.ageButton3.backgroundColor = UIColor.whiteColor()
        self.ageButton4.backgroundColor = UIColor.whiteColor()

        self.lbAge.text = (self.ageButton2.titleLabel!.text)!+"반"
    }

    @IBAction func tapAgeButton3(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.ageButton1.selected = false;
        self.ageButton2.selected = false;
        self.ageButton3.selected = true;
        self.ageButton4.selected = false;

        self.ageButton1.backgroundColor = UIColor.whiteColor()
        self.ageButton2.backgroundColor = UIColor.whiteColor()
        self.ageButton3.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.ageButton4.backgroundColor = UIColor.whiteColor()

        self.lbAge.text = (self.ageButton3.titleLabel!.text)!+"반"
    }

    @IBAction func tapAgeButton4(sender: AnyObject) {
        self.textView.resignFirstResponder();
        
        self.ageButton1.selected = false;
        self.ageButton2.selected = false;
        self.ageButton3.selected = false;
        self.ageButton4.selected = true;

        self.ageButton1.backgroundColor = UIColor.whiteColor()
        self.ageButton2.backgroundColor = UIColor.whiteColor()
        self.ageButton3.backgroundColor = UIColor.whiteColor()
        self.ageButton4.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)

        self.lbAge.text = (self.ageButton4.titleLabel!.text)!
    }

    @IBAction func tapPeopleButton1(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.peopleButton1.selected = true;
        self.peopleButton2.selected = false;
        self.peopleButton3.selected = false;
        self.peopleButton4.selected = false;

        self.peopleButton1.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.peopleButton2.backgroundColor = UIColor.whiteColor()
        self.peopleButton3.backgroundColor = UIColor.whiteColor()
        self.peopleButton4.backgroundColor = UIColor.whiteColor()

        self.lbPeopleCount.text = "1"
    }

    @IBAction func tapPeopleButton2(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.peopleButton1.selected = false;
        self.peopleButton2.selected = true;
        self.peopleButton3.selected = false;
        self.peopleButton4.selected = false;

        self.peopleButton1.backgroundColor = UIColor.whiteColor()
        self.peopleButton2.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.peopleButton3.backgroundColor = UIColor.whiteColor()
        self.peopleButton4.backgroundColor = UIColor.whiteColor()

        self.lbPeopleCount.text = "2"
    }

    @IBAction func tapPeopleButton3(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.peopleButton1.selected = false;
        self.peopleButton2.selected = false;
        self.peopleButton3.selected = true;
        self.peopleButton4.selected = false;

        self.peopleButton1.backgroundColor = UIColor.whiteColor()
        self.peopleButton2.backgroundColor = UIColor.whiteColor()
        self.peopleButton3.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.peopleButton4.backgroundColor = UIColor.whiteColor()

        self.lbPeopleCount.text = "3"
    }

    @IBAction func tapPeopleButton4(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.peopleButton1.selected = false;
        self.peopleButton2.selected = false;
        self.peopleButton3.selected = false;
        self.peopleButton4.selected = true;

        self.peopleButton1.backgroundColor = UIColor.whiteColor()
        self.peopleButton2.backgroundColor = UIColor.whiteColor()
        self.peopleButton3.backgroundColor = UIColor.whiteColor()
        self.peopleButton4.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)

        self.lbPeopleCount.text = "4+"
    }

    func switchTheme(isIPay:Bool) {
        self.isIPay = isIPay

        if self.isIPay {

            self.btnIPay.selected = true
            self.btnYouPay.selected = false
            self.btnRegister.setBackgroundImage(UIImage(named: "acceptButtonGreen.png"), forState: .Normal)

            if #available(iOS 8.2, *) {
                self.btnIPay.titleLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
                self.btnYouPay.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
                self.btnIPay.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
                self.btnYouPay.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
            }

            self.constWidthIPayButton.constant = self.maxWidthPayButton
            self.constHeightIPayButton.constant = self.maxHeightPayButton
            self.constWidthYouPayButton.constant = self.minWidthPayButton
            self.constHeightYouPayButton.constant = self.minHeightPayButton
        } else {

            self.btnIPay.selected = false
            self.btnYouPay.selected = true
            self.btnRegister.setBackgroundImage(UIImage(named: "acceptButtonRed.png"), forState: .Normal)

            if #available(iOS 8.2, *) {
                self.btnIPay.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
                self.btnYouPay.titleLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
                self.btnIPay.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
                self.btnYouPay.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
            }

            self.constWidthIPayButton.constant = self.minWidthPayButton
            self.constHeightIPayButton.constant = self.minHeightPayButton
            self.constWidthYouPayButton.constant = self.maxWidthPayButton
            self.constHeightYouPayButton.constant = self.maxHeightPayButton
        }

        self.btnIPay.layoutIfNeeded()
        self.btnYouPay.layoutIfNeeded()
    }

    @IBAction func tapIPayButton(sender: AnyObject) {
        self.switchTheme(true)
    }

    @IBAction func tapYouPayButton(sender: AnyObject) {
        self.switchTheme(false)
    }

    @IBAction func tapCameraButton(sender: AnyObject) {
        
    }

    @IBAction func tapRegisterButton(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    @IBAction func tapCloseButton(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if touch.view !== self.textView {
                self.textView.resignFirstResponder()
            }
        }
    }

// MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        self.textGuideLabel.hidden = true;
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.characters.count == 0 {
            self.textGuideLabel.hidden = false;
        }
    }

}
