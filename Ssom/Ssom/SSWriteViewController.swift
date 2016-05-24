//
//  SSWriteViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 30..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSWriteViewController: UIViewController, UITextViewDelegate
, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var barButtonItems: SSNavigationBarItems!

    @IBOutlet var profileView: UIView!
    @IBOutlet var imgDefaultProfile: UIImageView!
    @IBOutlet var imgPhotoGradation: UIImageView!
    @IBOutlet var imgProfile: UIImageView!

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

    var writeViewModel: SSWriteViewModel

    var pickedImageExtension: String!
    var pickedImageName: String!
    var pickedImageData: NSData!

    init() {
        self.writeViewModel = SSWriteViewModel()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.writeViewModel = SSWriteViewModel()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    func initView() {
        self.barButtonItems = SSNavigationBarItems()

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), forControlEvents: UIControlEvents.TouchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = "쏨 등록하기"

        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        self.textView.delegate = self;
    }

    func tapBack() {
        self.navigationController?.popViewControllerAnimated(true)
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

        self.writeViewModel.ageType = .AgeEarly20
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

        self.writeViewModel.ageType = .AgeMiddle20
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

        self.writeViewModel.ageType = .AgeLate20
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

        self.writeViewModel.ageType = .Age30
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

        self.writeViewModel.peopleCountType = .OnePerson
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

        self.writeViewModel.peopleCountType = .TwoPeople
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

        self.writeViewModel.peopleCountType = .ThreePeople
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

        self.writeViewModel.peopleCountType = .OverFourPeople
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
        self.writeViewModel.ssomType = .SSOM
        self.switchTheme(true)
    }

    @IBAction func tapYouPayButton(sender: AnyObject) {
        self.writeViewModel.ssomType = .SSOSEYO
        self.switchTheme(false)
    }

    @IBAction func tapCameraButton(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self;
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func tapRegisterButton(sender: AnyObject) {
        if let token: String = SSNetworkContext.sharedInstance.getSharedAttribute("token") as? String {
            let userId: String = SSNetworkContext.sharedInstance.getSharedAttribute("userId") as! String
            self.writeViewModel.userId = userId
            self.writeViewModel.content = self.textView.text

            print("SSWrite is : \(self.writeViewModel)")

            SSNetworkAPIClient.postFile(token, fileExt: self.pickedImageExtension, fileName: self.pickedImageName, fileData: self.pickedImageData, completion: { (photoURLPath, error) in
                if error != nil {
                    print(error?.localizedDescription)

                    SSAlertController.alertConfirm(title: "Error", message: (error?.localizedDescription)!, vc: self, completion: nil)
                } else {
                    self.writeViewModel.profilePhotoUrl = NSURL(string: photoURLPath!)
                    SSNetworkAPIClient.postPost(token, model: self.writeViewModel, completion: { [unowned self] (error) in
                        if error != nil {
                            print(error?.localizedDescription)

                            SSAlertController.alertConfirm(title: "Error", message: (error?.localizedDescription)!, vc: self, completion: { (action) in
                                self.navigationController!.popViewControllerAnimated(true)
                            })
                        } else {
                            self.navigationController!.popViewControllerAnimated(true)
                        }
                        })
                }
            })
        } else {
            self.openSignIn(nil)
        }
    }

    func openSignIn(completion: ((finish:Bool) -> Void)?) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "SSSignStoryBoard", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController()
        vc?.modalPresentationStyle = .OverFullScreen

        self.presentViewController(vc!, animated: true, completion: nil)
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


// MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imgDefaultProfile.hidden = true
        self.imgPhotoGradation.hidden = true    

        self.imgProfile.contentMode = .ScaleAspectFill
        self.imgProfile.clipsToBounds = true
        self.imgProfile.image = image
        self.imgProfile.hidden = false

        let pickedImageURL: NSURL = editingInfo![UIImagePickerControllerReferenceURL] as! NSURL
        let pickedImageURLQueryParams: Array = pickedImageURL.query!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "=&"))
        let pickedImage: UIImage = editingInfo![UIImagePickerControllerOriginalImage] as! UIImage
        var isExt: Bool = false;
        for queryParam: String in pickedImageURLQueryParams {
            if queryParam == "ext" {
                isExt = true
                continue
            }
            if isExt {
                switch queryParam {
                case "PNG":
                    self.pickedImageExtension = "png"
                    self.pickedImageData = UIImagePNGRepresentation(pickedImage)
                case "JPG", "JPEG":
                    self.pickedImageExtension = "jpeg"
                    self.pickedImageData = UIImageJPEGRepresentation(pickedImage, 1.0)
                default:
                    print("")
                }

                break
            }
        }
        self.pickedImageName = pickedImageURL.lastPathComponent

        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}