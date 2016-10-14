//
//  SSTodayPhotoViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 9. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSTodayPhotoViewController: UIViewController {
    @IBOutlet var imgViewPhoto: UIImageView!

    @IBOutlet var constBtnCancelTopMin: NSLayoutConstraint!
    @IBOutlet var constBtnSaveBottomToSuper: NSLayoutConstraint!

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
    }

    @IBAction func tapCamera(sender: AnyObject) {
    }

    @IBAction func tapDeletePhoto(sender: AnyObject) {
    }

    @IBAction func tapNaviClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapSubmit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
