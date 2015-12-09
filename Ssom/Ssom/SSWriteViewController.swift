//
//  SSWriteViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 30..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSWriteViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var iPayButtonBackgroundImageView: UIImageView!
    @IBOutlet var iPayIconImageView: UIImageView!
    @IBOutlet var iPayLabel: UILabel!
    @IBOutlet var youPayButtonBackgroundImageView: UIImageView!
    @IBOutlet var youPayIconImageView: UIImageView!
    @IBOutlet var youPayLabel: UILabel!

    @IBOutlet var textView: UITextView!
    @IBOutlet var textGuideLabel: UILabel!

    @IBOutlet var mealButton: UIButton!
    @IBOutlet var alcholButton: UIButton!
    @IBOutlet var teaButton: UIButton!
    @IBOutlet var anyFoodButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    func initView() {
        self.navigationController!.navigationBarHidden = true;

        self.textView.delegate = self;
    }

    @IBAction func tapIPayButton(sender: AnyObject) {

        self.iPayButtonBackgroundImageView.image = UIImage(named: "toggle_write_black.png");
        self.iPayIconImageView.image = UIImage(named: "icon_check_w.png")
        self.iPayLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        self.youPayButtonBackgroundImageView.image = nil;
        self.youPayIconImageView.image = UIImage(named: "icon_target_g.png")
        self.youPayLabel.textColor = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1)
    }

    @IBAction func tapYouPayButton(sender: AnyObject) {

        self.iPayButtonBackgroundImageView.image = nil;
        self.iPayIconImageView.image = UIImage(named: "icon_check_g.png")
        self.iPayLabel.textColor = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1)

        self.youPayButtonBackgroundImageView.image = UIImage(named: "toggle_write_red.png");
        self.youPayIconImageView.image = UIImage(named: "icon_target_w.png")
        self.youPayLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }

    @IBAction func tapMealButton(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.mealButton.selected = true;
        self.alcholButton.selected = false;
        self.teaButton.selected = false;
        self.anyFoodButton.selected = false;
    }

    @IBAction func tapAlcholButton(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.mealButton.selected = false;
        self.alcholButton.selected = true;
        self.teaButton.selected = false;
        self.anyFoodButton.selected = false;
    }

    @IBAction func tapTeaButton(sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.mealButton.selected = false;
        self.alcholButton.selected = false;
        self.teaButton.selected = true;
        self.anyFoodButton.selected = false;
    }

    @IBAction func tapAnyFoodButton(sender: AnyObject) {
        self.textView.resignFirstResponder();
        
        self.mealButton.selected = false;
        self.alcholButton.selected = false;
        self.teaButton.selected = false;
        self.anyFoodButton.selected = true;
    }

    @IBAction func tapCameraButton(sender: AnyObject) {
        
    }

    @IBAction func tapRegisterButton(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
        self.navigationController!.navigationBarHidden = false
    }

    @IBAction func tapCloseButton(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
        self.navigationController!.navigationBarHidden = false
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
