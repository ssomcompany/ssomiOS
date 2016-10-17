//
//  SSTodayPhotoViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 9. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSTodayPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imgViewPhoto: UIImageView!

    @IBOutlet var constBtnCancelTopMin: NSLayoutConstraint!
    @IBOutlet var constBtnSaveBottomToSuper: NSLayoutConstraint!

    @IBOutlet var btnSave: UIButton!

    var pickedImageExtension: String!
    var pickedImageName: String!
    var pickedImageData: NSData!

    var photoSaveCompletion: (()-> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    override func initView() {
        if let imageUrl = SSAccountManager.sharedInstance.profileImageUrl where imageUrl.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
            self.imgViewPhoto.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: nil) { (image, error, _, _) in
                if error != nil {
                } else {
                    let croppedProfileImage: UIImage = UIImage.cropInCircle(image, frame: CGRectMake(0, 0, self.imgViewPhoto.bounds.size.width, self.imgViewPhoto.bounds.size.height))

                    self.imgViewPhoto.image = croppedProfileImage
                }
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIScreen.mainScreen().bounds.height < 568.0 {
            self.constBtnSaveBottomToSuper.active = false
            self.constBtnCancelTopMin.active = true
        }
    }

    @IBAction func tapPhotoLibrary(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func tapCamera(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .Camera
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func tapDeletePhoto(sender: AnyObject) {
        SSAlertController.alertTwoButton(title: "Info", message: "정말로 오늘의 사진을 삭제하시겠습니까?", vc: self, button1Completion: { (action) in

            if let token = SSAccountManager.sharedInstance.sessionToken {
                SSNetworkAPIClient.deleteUserProfileImage(token, completion: { [weak self] (data, error) in
                    if let wself = self {
                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: nil)
                        } else {
                            SSNetworkContext.sharedInstance.deleteSharedAttribute("profileImageUrl")

                            if let completion = wself.photoSaveCompletion {
                                completion()
                            }

                            wself.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                    })
            }

        }) { (action) in

        }
    }

    @IBAction func tapNaviClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapSubmit(sender: AnyObject) {
        if let token = SSAccountManager.sharedInstance.sessionToken {
            SSNetworkAPIClient.postFile(token, fileExt: self.pickedImageExtension, fileName: self.pickedImageName, fileData: self.pickedImageData, completion: { [weak self] (photoURLPath, error) in
                if let wself = self {
                    if let err = error {
                        print(err.localizedDescription)

                        SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: nil)
                    } else {
                        if let imageUrl = photoURLPath {
                            SSNetworkContext.sharedInstance.saveSharedAttribute(imageUrl, forKey: "profileImageUrl")

                            if let completion = wself.photoSaveCompletion {
                                completion()
                            }
                        }

                        wself.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            })
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {

        let pickedImage: UIImage!
        // photo library
        if let pickedImageURL: NSURL = editingInfo![UIImagePickerControllerReferenceURL] as? NSURL {
            let pickedImageURLQueryParams: Array = pickedImageURL.query!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "=&"))
            pickedImage = editingInfo![UIImagePickerControllerOriginalImage] as! UIImage

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
        } else {
            pickedImage = image

            self.pickedImageExtension = "png"
            self.pickedImageName = "camera.png"
            self.pickedImageData = UIImagePNGRepresentation(pickedImage)
        }

        picker.dismissViewControllerAnimated(true, completion: { [weak self] in
            if let wself = self {
                let croppedProfileImage: UIImage = UIImage.cropInCircle(pickedImage, frame: CGRectMake(0, 0, wself.imgViewPhoto.bounds.size.width, wself.imgViewPhoto.bounds.size.height))

                wself.imgViewPhoto.image = croppedProfileImage
            }
        })

        self.btnSave.enabled = true
    }
}
