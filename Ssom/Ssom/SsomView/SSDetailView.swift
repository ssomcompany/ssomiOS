//
//  SSDetailView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 2. 10..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSDetailViewDelegate {
    func closeDetailView()
    func openSignIn(completion: ((finish:Bool) -> Void)?)
    func doSsom(ssomType: SSType)
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

    var delegate: SSDetailViewDelegate!
    var ssomType: SSType!

    var viewModel: SSViewModel!

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
    }

    func changeTheme(ssomType: SSType) {
        self.ssomType = ssomType

        if self.ssomType == .SSOM {
            self.imgHeart.image = UIImage(named: "heartGreen")
            self.viewSsomDescription.backgroundColor = UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1)
            self.lbSsom.text = "내가 쏨"
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonGreen"), forState: .Normal)
        } else {
            self.imgHeart.image = UIImage(named: "heartRed")
            self.viewSsomDescription.backgroundColor = UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)
            self.lbSsom.text = "니가 쏴"
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonRed"), forState: .Normal)
        }
    }
    
    @IBAction func tapClose(sender: AnyObject?) {
        guard let _ = self.delegate?.closeDetailView() else {
            NSLog("%@", "This SSDetailView's delegate isn't implemented closeDetailView function")

            return
        }
    }

    @IBAction func tapSsom(sender: AnyObject) {
        if SSAccountManager.sharedInstance.isAuthorized() {
            if let userId = SSNetworkContext.sharedInstance.getSharedAttribute("userId") as? String {
                let token = SSNetworkContext.sharedInstance.getSharedAttribute("token") as! String
                SSNetworkAPIClient.getUser(token, email: userId, completion: { (model, error) in
                    if let err = error {
                        print(err.localizedDescription)

                        SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                    } else {
                        if let m = model {
                            if m.userId == self.viewModel.userId {
                                SSAlertController.showAlertConfirm(title: "", message: "내가 등록한 쏨입니다!", completion: nil)
                            } else {

                                guard let _ = self.delegate?.doSsom(self.ssomType) else {
                                    NSLog("%@", "This SSDetailView's delegate isn't implemented doSsom function")

                                    return
                                }
                                
                                self.tapClose(nil)
                            }
                        }
                    }
                })
            }
        } else {
            guard let _ = self.delegate?.openSignIn(nil) else {
                NSLog("%@", "This SSDetailView's delegate isn't implemented openSignIn function")

                return
            }

        }
    }
}