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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapPhotoLibrary(sender: AnyObject) {
    }
    @IBAction func tapCamera(sender: AnyObject) {
    }
    @IBAction func tapDeletePhoto(sender: AnyObject) {
    }

    @IBAction func tapCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func tapSubmit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
