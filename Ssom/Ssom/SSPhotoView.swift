//
//  SSPhotoView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 19..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol SSPhotoViewDelegate: NSObjectProtocol {
    optional func tapClose() -> Void
}

class SSPhotoView: UIView {
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    var delegate: SSPhotoViewDelegate?

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

    func loadingImage(frame: CGRect, imageUrl: String) {
        self.frame = frame

        self.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]

        Alamofire.request(.GET, imageUrl)
            .response { (request, response, data, error) -> Void in
                self.imageView.image = UIImage(data: data!)
        }
    }

    @IBAction func tapClose(sender: UIButton) {
        if ((self.delegate?.respondsToSelector("tapClose")) != nil) {
            self.delegate?.tapClose!()
        }
    }
}