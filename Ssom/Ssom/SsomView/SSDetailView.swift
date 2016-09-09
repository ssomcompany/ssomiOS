//
//  SSDetailView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 2. 10..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSDetailViewDelegate: class {
    func closeDetailView(needToReload: Bool)
    func openSignIn(completion: ((finish:Bool) -> Void)?)
    func doSsom(ssomType: SSType, postId: String, partnerImageUrl: String?, ssomLatitude: Double, ssomLongitude: Double)
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

    weak var delegate: SSDetailViewDelegate!
    var ssomType: SSType!

    var viewModel: SSViewModel!

    var isMySsom: Bool = false

    var needToReload: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

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

        let ageArea: SSAgeAreaType = Util.getAgeArea(self.viewModel.minAge)
        self.lbAge.text = String("\(ageArea.rawValue), \(self.viewModel.userCount)")
        self.textViewDescription.text = self.viewModel.content
        self.lbDistance.text = "나와의 거리 \(Util.getDistanceString(self.viewModel.distance))"

        if SSAccountManager.sharedInstance.isAuthorized {
            if let userModel = SSAccountManager.sharedInstance.userModel {
                self.isMySsom = userModel.userId == self.viewModel.userId
            }
        }

        if self.isMySsom {
            self.btnSsom.setTitle("삭제", forState: UIControlState.Normal)
            self.btnSsom.setImage(nil, forState: UIControlState.Normal)
        }
    }

    func changeTheme(ssomType: SSType) {
        self.ssomType = ssomType

        if self.ssomType == .SSOM {
            self.imgHeart.image = UIImage(named: "heartGreen")
            self.viewSsomDescription.backgroundColor = UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1)
            self.lbSsom.text = "내가 쏨"
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonGreen"), forState: .Normal)
            self.lbAge.textColor = UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1)
        } else {
            self.imgHeart.image = UIImage(named: "heartRed")
            self.viewSsomDescription.backgroundColor = UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)
            self.lbSsom.text = "니가 쏴"
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonRed"), forState: .Normal)
            self.lbAge.textColor = UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)
        }
    }
    
    @IBAction func tapClose(sender: AnyObject?) {
        guard let _ = self.delegate?.closeDetailView(self.needToReload) else {
            NSLog("%@", "This SSDetailView's delegate isn't implemented closeDetailView function")

            return
        }
    }

    @IBAction func tapSsom(sender: AnyObject) {
        if SSAccountManager.sharedInstance.isAuthorized {
            if self.isMySsom {
                if let token = SSAccountManager.sharedInstance.sessionToken {
                    SSNetworkAPIClient.deletePost(token, postId: self.viewModel.postId, completion: { (error) in
                        if let err = error {
                            SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                        } else {
                            SSAlertController.showAlertConfirm(title: "알림", message: "성공적으로 삭제 되었쏨!", completion: { (action) in
                                self.needToReload = true
                                self.tapClose(nil)
                            })
                        }
                    })
                }
            } else {

                guard let _ = self.delegate?.doSsom(self.ssomType, postId: self.viewModel.postId, partnerImageUrl: self.viewModel.imageUrl, ssomLatitude: self.viewModel.latitude, ssomLongitude: self.viewModel.longitude) else {
                    NSLog("%@", "This SSDetailView's delegate isn't implemented doSsom function")

                    return
                }

                self.tapClose(nil)
            }
        } else {
            guard let _ = self.delegate?.openSignIn(nil) else {
                NSLog("%@", "This SSDetailView's delegate isn't implemented openSignIn function")

                return
            }

        }
    }
}