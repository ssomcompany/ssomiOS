//
//  SSPhotoView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 19..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import SDWebImage

@objc protocol SSPhotoViewDelegate: NSObjectProtocol {
    @objc optional func tapPhotoViewClose() -> Void
}

class SSPhotoView: UIView, UIScrollViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    weak var delegate: SSPhotoViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init(frame: CGRect, imageUrl: String) {
        self.init(frame: frame)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        print("awakeFromNib")
    }

    func loadingImage(_ frame: CGRect, imageUrl: String) {
        self.frame = frame

        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        self.imageView.sd_setImage(with: URL(string: imageUrl)) { (image, error, cacheType, imageURL) in
            if error != nil {
                SSAlertController.showAlertConfirm(title: "Error", message: (error?.localizedDescription)!, completion: nil)
            }
        }
    }

    @IBAction func tapClose(_ sender: UIButton) {
        if (self.delegate!.responds(to: #selector(SSPhotoViewDelegate.tapPhotoViewClose))) {
            self.delegate!.tapPhotoViewClose!()
        }
    }
    @IBAction func handleDoubleTapImage(_ sender: AnyObject) {
        if self.scrollView.zoomScale == 1 {
            self.scrollView.zoomScale = 2
        } else {
            self.scrollView.zoomScale = 1
        }
    }

    // MARK:- UIScrollViewDelegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("zoom")
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
