//
//  SSWriteViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 30..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class SSWriteViewController: SSDetailViewController, UITextViewDelegate
, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var barButtonItems: SSNavigationBarItems!

    @IBOutlet var profileView: UIView!
    @IBOutlet var constProfileViewTopToSuper: NSLayoutConstraint!
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
    @IBOutlet var constBtnIPayWidthRatio: NSLayoutConstraint!
    @IBOutlet var constBtnIPayAspectRatio: NSLayoutConstraint!
    @IBOutlet var constBtnIPayMinWidthRatio: NSLayoutConstraint!
    @IBOutlet var constBtnIPayMinAspectRatio: NSLayoutConstraint!

//    @IBOutlet var constWidthIPayButton: NSLayoutConstraint!
//    @IBOutlet var constHeightIPayButton: NSLayoutConstraint!

    @IBOutlet var btnYouPay: UIButton!
    @IBOutlet var constBtnYouPayWidthRatio: NSLayoutConstraint!
    @IBOutlet var constBtnYouPayAspectRatio: NSLayoutConstraint!
    @IBOutlet var constBtnYouPayMinWidthRatio: NSLayoutConstraint!
    @IBOutlet var constBtnYouPayMinAspectRatio: NSLayoutConstraint!

//    @IBOutlet var constWidthYouPayButton: NSLayoutConstraint!
//    @IBOutlet var constHeightYouPayButton: NSLayoutConstraint!

    @IBOutlet var btnRegister: UIButton!

    var isIPay:Bool = true

    var writeViewModel: SSWriteViewModel

    var pickedImageExtension: String!
    var pickedImageName: String!
    var pickedImageData: Data!

    init() {
        self.writeViewModel = SSWriteViewModel()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.writeViewModel = SSWriteViewModel()

        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    override func initView() {
        self.barButtonItems = SSNavigationBarItems()

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), for: UIControlEvents.touchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = "쏨 등록하기"

        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        self.textView.delegate = self;

        if UIScreen.main.bounds.width == 320 {
            self.textGuideLabel.font = UIFont.systemFont(ofSize: 13)
        }

        if let profileImageUrl = SSNetworkContext.sharedInstance.getSharedAttribute("profileImageUrl") as? String {
            self.imgProfile.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: nil, options: [], completed: { (image, error, _, _) in
                self.imgProfile.contentMode = .scaleAspectFill
                self.imgProfile.clipsToBounds = true
                self.imgProfile.isHidden = false

                self.btnRegister.isEnabled = true

                self.writeViewModel.profilePhotoUrl = URL(string: profileImageUrl)
            })
        }

        self.registerForKeyboardNotifications()
    }

    func registerForKeyboardNotifications() -> Void {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func tapBack() {
        if self.pickedImageData != nil || self.writeViewModel.content.characters.count != 0 {
            SSAlertController.alertTwoButton(title: "알림", message: "쏨 등록이 완료되지 않았어요.\n작성했던 내용을 삭제 하시겠어요?", vc: self, button1Title: "삭제하기", button1Completion: { (action) in
                self.navigationController?.popViewController(animated: true)
            }, button2Completion: { (action) in
                //
            })
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func tapAgeButton1(_ sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.ageButton1.isSelected = true;
        self.ageButton2.isSelected = false;
        self.ageButton3.isSelected = false;
        self.ageButton4.isSelected = false;

        self.ageButton1.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.ageButton2.backgroundColor = UIColor.white
        self.ageButton3.backgroundColor = UIColor.white
        self.ageButton4.backgroundColor = UIColor.white

        self.lbAge.text = (self.ageButton1.titleLabel!.text)!+"반"

        self.writeViewModel.ageType = .ageEarly20
    }

    @IBAction func tapAgeButton2(_ sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.ageButton1.isSelected = false;
        self.ageButton2.isSelected = true;
        self.ageButton3.isSelected = false;
        self.ageButton4.isSelected = false;

        self.ageButton1.backgroundColor = UIColor.white
        self.ageButton2.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.ageButton3.backgroundColor = UIColor.white
        self.ageButton4.backgroundColor = UIColor.white

        self.lbAge.text = (self.ageButton2.titleLabel!.text)!+"반"

        self.writeViewModel.ageType = .ageMiddle20
    }

    @IBAction func tapAgeButton3(_ sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.ageButton1.isSelected = false;
        self.ageButton2.isSelected = false;
        self.ageButton3.isSelected = true;
        self.ageButton4.isSelected = false;

        self.ageButton1.backgroundColor = UIColor.white
        self.ageButton2.backgroundColor = UIColor.white
        self.ageButton3.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.ageButton4.backgroundColor = UIColor.white

        self.lbAge.text = (self.ageButton3.titleLabel!.text)!+"반"

        self.writeViewModel.ageType = .ageLate20
    }

    @IBAction func tapAgeButton4(_ sender: AnyObject) {
        self.textView.resignFirstResponder();
        
        self.ageButton1.isSelected = false;
        self.ageButton2.isSelected = false;
        self.ageButton3.isSelected = false;
        self.ageButton4.isSelected = true;

        self.ageButton1.backgroundColor = UIColor.white
        self.ageButton2.backgroundColor = UIColor.white
        self.ageButton3.backgroundColor = UIColor.white
        self.ageButton4.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)

        self.lbAge.text = (self.ageButton4.titleLabel!.text)!

        self.writeViewModel.ageType = .age30
    }

    @IBAction func tapPeopleButton1(_ sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.peopleButton1.isSelected = true;
        self.peopleButton2.isSelected = false;
        self.peopleButton3.isSelected = false;
        self.peopleButton4.isSelected = false;

        self.peopleButton1.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.peopleButton2.backgroundColor = UIColor.white
        self.peopleButton3.backgroundColor = UIColor.white
        self.peopleButton4.backgroundColor = UIColor.white

        self.lbPeopleCount.text = "1"

        self.writeViewModel.peopleCountType = .onePerson
    }

    @IBAction func tapPeopleButton2(_ sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.peopleButton1.isSelected = false;
        self.peopleButton2.isSelected = true;
        self.peopleButton3.isSelected = false;
        self.peopleButton4.isSelected = false;

        self.peopleButton1.backgroundColor = UIColor.white
        self.peopleButton2.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.peopleButton3.backgroundColor = UIColor.white
        self.peopleButton4.backgroundColor = UIColor.white

        self.lbPeopleCount.text = "2"

        self.writeViewModel.peopleCountType = .twoPeople
    }

    @IBAction func tapPeopleButton3(_ sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.peopleButton1.isSelected = false;
        self.peopleButton2.isSelected = false;
        self.peopleButton3.isSelected = true;
        self.peopleButton4.isSelected = false;

        self.peopleButton1.backgroundColor = UIColor.white
        self.peopleButton2.backgroundColor = UIColor.white
        self.peopleButton3.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.peopleButton4.backgroundColor = UIColor.white

        self.lbPeopleCount.text = "3"

        self.writeViewModel.peopleCountType = .threePeople
    }

    @IBAction func tapPeopleButton4(_ sender: AnyObject) {
        self.textView.resignFirstResponder();

        self.peopleButton1.isSelected = false;
        self.peopleButton2.isSelected = false;
        self.peopleButton3.isSelected = false;
        self.peopleButton4.isSelected = true;

        self.peopleButton1.backgroundColor = UIColor.white
        self.peopleButton2.backgroundColor = UIColor.white
        self.peopleButton3.backgroundColor = UIColor.white
        self.peopleButton4.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)

        self.lbPeopleCount.text = "4+"

        self.writeViewModel.peopleCountType = .overFourPeople
    }

    func switchTheme(_ isIPay:Bool) {
        self.isIPay = isIPay

        if self.isIPay {

            self.btnIPay.isSelected = true
            self.btnYouPay.isSelected = false
            self.btnRegister.setBackgroundImage(UIImage(named: "acceptButtonGreen"), for: UIControlState())

            if #available(iOS 8.2, *) {
                self.btnIPay.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
                self.btnYouPay.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
                if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 18) {
                    self.btnIPay.titleLabel?.font = font
                }
                if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 13) {
                    self.btnYouPay.titleLabel?.font = font
                }
            }

            self.lbAge.textColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1.0)
            self.lbPeopleCount.textColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1.0)

            self.textGuideLabel.text = SSType.SSOM.guideText

            self.constBtnIPayWidthRatio.isActive = true
            self.constBtnIPayAspectRatio.isActive = true

            self.constBtnIPayMinWidthRatio.isActive = false
            self.constBtnIPayMinAspectRatio.isActive = false

            self.constBtnYouPayWidthRatio.isActive = true
            self.constBtnYouPayAspectRatio.isActive = true

            self.constBtnYouPayMinWidthRatio.isActive = false
            self.constBtnYouPayMinAspectRatio.isActive = false
        } else {

            self.btnIPay.isSelected = false
            self.btnYouPay.isSelected = true
            self.btnRegister.setBackgroundImage(UIImage(named: "acceptButtonRed"), for: UIControlState())

            if #available(iOS 8.2, *) {
                self.btnIPay.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
                self.btnYouPay.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
                if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 13) {
                    self.btnIPay.titleLabel?.font = font
                }
                if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 18) {
                    self.btnYouPay.titleLabel?.font = font
                }
            }

            self.lbAge.textColor = UIColor(red: 237.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            self.lbPeopleCount.textColor = UIColor(red: 237.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)

            self.textGuideLabel.text = SSType.SSOSEYO.guideText

            self.constBtnIPayWidthRatio.isActive = false
            self.constBtnIPayAspectRatio.isActive = false

            self.constBtnIPayMinWidthRatio.isActive = true
            self.constBtnIPayMinAspectRatio.isActive = true

            self.constBtnYouPayWidthRatio.isActive = false
            self.constBtnYouPayAspectRatio.isActive = false

            self.constBtnYouPayMinWidthRatio.isActive = true
            self.constBtnYouPayMinAspectRatio.isActive = true
        }

        self.btnIPay.layoutIfNeeded()
        self.btnYouPay.layoutIfNeeded()
        self.profileView.layoutIfNeeded()
    }

    @IBAction func tapIPayButton(_ sender: AnyObject) {
        self.writeViewModel.ssomType = .SSOM
        self.switchTheme(true)
    }

    @IBAction func tapYouPayButton(_ sender: AnyObject) {
        self.writeViewModel.ssomType = .SSOSEYO
        self.switchTheme(false)
    }

    @IBAction func tapCameraButton(_ sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self;
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func tapRegisterButton(_ sender: AnyObject) {
        if let token: String = SSNetworkContext.sharedInstance.getSharedAttribute("token") as? String,
            let userId: String = SSNetworkContext.sharedInstance.getSharedAttribute("userId") as? String {
            self.writeViewModel.userId = userId
            self.writeViewModel.content = self.textView.text

            print("SSWrite is : \(self.writeViewModel)")

            // 미리 설정된 사진이 있으면, 쏨 등록 가능하게 함.
            if self.pickedImageData == nil {
                if let _ = self.writeViewModel.profilePhotoUrl {
                    self.registerSsom()
                } else {
                    SSAlertController.alertConfirm(title: "Error", message: "사진 등록은 필수입니다!", vc: self, completion: nil)
                }
            } else {
                SSNetworkAPIClient.postFile(token, fileExt: self.pickedImageExtension, fileName: self.pickedImageName, fileData: self.pickedImageData, completion: { (photoURLPath, error) in
                    if let err = error {
                        print(err.localizedDescription)

                        SSAlertController.alertConfirm(title: "Error", message: (error?.localizedDescription)!, vc: self, completion: nil)
                    } else {
                        self.writeViewModel.profilePhotoUrl = URL(string: photoURLPath!)
                        self.registerSsom()
                    }
                })
            }
        } else {
            self.openSignIn(nil)
        }
    }

    func registerSsom() {
        if let token = SSAccountManager.sharedInstance.sessionToken {
            SSNetworkAPIClient.postPost(token, model: self.writeViewModel, completion: { [weak self] (error) in
                guard let wself = self else { return }

                if let err = error {
                    print(err.localizedDescription)

                    SSAlertController.alertConfirm(title: "Error", message: (error?.localizedDescription)!, vc: wself, completion: { (action) in
//                                    self.navigationController!.popViewControllerAnimated(true)
                    })
                } else {
                    SSNetworkContext.sharedInstance.saveSharedAttribute(wself.writeViewModel.profilePhotoUrl?.absoluteString as Any, forKey: "profileImageUrl")
                    wself.navigationController!.popViewController(animated: true)
                }
            })
        }
    }

    func openSignIn(_ completion: ((_ finish:Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: nil)
    }

    @IBAction func tapCloseButton(_ sender: AnyObject) {
        self.tapBack()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view !== self.textView {
                self.textView.resignFirstResponder()
            }
        }
    }

// MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textGuideLabel.isHidden = true;
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.characters.count == 0 {
            self.textGuideLabel.isHidden = false;
        }
    }


// MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imgDefaultProfile.isHidden = true
        self.imgPhotoGradation.isHidden = true    

        self.imgProfile.contentMode = .scaleAspectFill
        self.imgProfile.clipsToBounds = true
        self.imgProfile.image = image
        self.imgProfile.isHidden = false

        let pickedImageURL: URL = editingInfo![UIImagePickerControllerReferenceURL] as! URL
        let pickedImageURLQueryParams: Array = pickedImageURL.query!.components(separatedBy: CharacterSet(charactersIn: "=&"))
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
                    print("unable to upload!!")
                    break
                }

                break
            }
        }
        self.pickedImageName = pickedImageURL.lastPathComponent

        picker.dismiss(animated: true, completion: nil)

        self.btnRegister.isEnabled = true
    }

// MARK: - Keyboard show & hide event
    func keyboardWillShow(_ notification: Notification) -> Void {
        if let info = notification.userInfo {
            if let _ = (info[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {

                self.constProfileViewTopToSuper.constant = -self.profileView.bounds.size.height
            }
        }
    }

    func keyboardWillHide(_ notification: Notification) -> Void {
        self.constProfileViewTopToSuper.constant = 0
    }
}
