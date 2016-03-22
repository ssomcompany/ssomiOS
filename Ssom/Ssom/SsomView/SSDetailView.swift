//
//  SSDetailView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 2. 10..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSDetailViewDelegate: NSObjectProtocol {
    func closeDetailView() -> Void;
}

class SSDetailView: UIView {

    @IBOutlet var viewDetail: UIView!
    @IBOutlet var imgHeart: UIImageView!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var viewSsomDescription: UIView!
    @IBOutlet var lbSsom: UILabel!
    @IBOutlet var lbDistance: UILabel!
    @IBOutlet var lbAge: UILabel!
    @IBOutlet var textViewDescription: UITextView!
    @IBOutlet var btnSsom: UIButton!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var imgPageLeft: UIImageView!
    @IBOutlet var imgPageRight: UIImageView!

    var delegate: SSDetailViewDelegate!
    var ssomType: SSType!

    var viewModel: SSViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewDetail.clipsToBounds = true
        self.viewDetail.layer.cornerRadius = 15

        self.btnCancel.layer.cornerRadius = 2
        self.btnCancel.layer.shadowOffset = CGSizeMake(0, 1)
        self.btnCancel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).CGColor
        self.btnCancel.layer.shadowOpacity = 0.3
        self.btnCancel.layer.shadowRadius = 2
    }

    func configureWithViewModel(viewModel: SSViewModel) {
        self.viewModel = viewModel;

        self.imgProfile.sd_setImageWithURL(NSURL(string: self.viewModel.imageUrl), placeholderImage: nil) { (image, error, cacheType, url) -> Void in
        }

        self.lbAge.text = String(format: "%d, %d", arguments: [self.viewModel.minAge, self.viewModel.userCount])
        self.textViewDescription.text = self.viewModel.content
    }

    func changeTheme(ssomType: SSType) {
        self.ssomType = ssomType

        if self.ssomType == .SSOM {
            self.imgHeart.image = UIImage(named: "heartGreen")
            self.imgPageLeft.image = UIImage(named: "pageLeftGreen")
            self.imgPageRight.image = UIImage(named: "pageRightGreen")
            self.viewSsomDescription.backgroundColor = UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1)
            self.lbSsom.text = "내가 쏨"
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonGreen"), forState: .Normal)
        } else {
            self.imgHeart.image = UIImage(named: "heartRed")
            self.imgPageLeft.image = UIImage(named: "pageLeft")
            self.imgPageRight.image = UIImage(named: "pageRight")
            self.viewSsomDescription.backgroundColor = UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)
            self.lbSsom.text = "니가 쏴"
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonRed"), forState: .Normal)
        }
    }
    
    @IBAction func tapClose(sender: AnyObject) {
        if self.delegate.respondsToSelector("closeDetailView") {
            self.delegate.closeDetailView()
        }
    }

    @IBAction func tapSsom(sender: AnyObject) {
    }
}