//
//  SSChatMessageTableCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 31..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatMessageTableCell: UITableViewCell {
    @IBOutlet var imgViewPartnerProfile: UIImageView!
    @IBOutlet var imgViewPartnerProfileBorder: UIImageView!
    @IBOutlet var viewPartnerMessage: UIView!
    @IBOutlet var lbPartnerMessage: UILabel!
    @IBOutlet var lbPartnerMessageTime: UILabel!
    @IBOutlet var imgViewMyProfile: UIImageView!
    @IBOutlet var imgViewMyProfileBorder: UIImageView!
    @IBOutlet var viewMyMessage: UIView!
    @IBOutlet var lbMyMessage: UILabel!
    @IBOutlet var lbMyMessageTime: UILabel!

    var ssomType: SSType = .SSOM
    var model: SSChatViewModel = SSChatViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewPartnerMessage.layer.cornerRadius = 2.3
        self.viewMyMessage.layer.cornerRadius = 2.3
    }

    func configView(_ model: SSChatViewModel) {
        self.model = model

        switch self.ssomType {
        case .SSOM:
            self.imgViewPartnerProfileBorder.image = UIImage(named: "profileBorderGreen")
            self.viewPartnerMessage.backgroundColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1.0)
        case .SSOSEYO:
            self.imgViewPartnerProfileBorder.image = UIImage(named: "profileBorderRed")
            self.viewPartnerMessage.backgroundColor = UIColor(red: 237.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        }

        self.imgViewPartnerProfile.image = UIImage(named: "noneProfile")
        self.imgViewMyProfile.image = UIImage(named: "noneProfile")

        if let loginedUserId = SSAccountManager.sharedInstance.userUUID {
            if model.fromUserId == loginedUserId {
                self.showMyViews()

                var profileImageUrl: String?
                if let imageUrl = model.profileImageUrl {
                    profileImageUrl = imageUrl
                } else if let imageUrl = SSAccountManager.sharedInstance.profileImageUrl {
                    profileImageUrl = imageUrl
                }

                if let imageUrl = profileImageUrl {
                    self.imgViewMyProfile.sd_setImage(with: URL(string: imageUrl+"?thumbnail=200"), completed: { (image, error, _, _) in
                        if error != nil {
                        } else {
                            let croppedProfileImage: UIImage = UIImage.cropInCircle(image!, frame: CGRect(x: 0, y: 0, width: self.imgViewPartnerProfile.bounds.size.width, height: self.imgViewMyProfile.bounds.size.height))

                            self.imgViewMyProfile.image = croppedProfileImage
                        }
                    })
                }

                self.lbMyMessage.text = model.message
                self.lbMyMessageTime.text = Util.getDateString(model.messageDateTime)
            } else {
                self.showPartnerViews()

                if let imageUrl = model.profileImageUrl {
                    self.imgViewPartnerProfile.sd_setImage(with: URL(string: imageUrl+"?thumbnail=200"), completed: { (image, error, _, _) in
                        if error != nil {
                        } else {
                            let croppedProfileImage: UIImage = UIImage.cropInCircle(image!, frame: CGRect(x: 0, y: 0, width: self.imgViewPartnerProfile.bounds.size.width, height: self.imgViewPartnerProfile.bounds.size.height))

                            self.imgViewPartnerProfile.image = croppedProfileImage
                        }
                    })
                }

                self.lbPartnerMessage.text = model.message
                self.lbPartnerMessageTime.text = Util.getDateString(model.messageDateTime)
            }
        }
    }

    func showMyViews() {
        self.imgViewPartnerProfile.isHidden = true
        self.imgViewPartnerProfileBorder.isHidden = true
        self.viewPartnerMessage.isHidden = true
        self.lbPartnerMessage.isHidden = true
        self.lbPartnerMessageTime.isHidden = true

        self.imgViewMyProfile.isHidden = false
        self.imgViewMyProfileBorder.isHidden = true
        self.viewMyMessage.isHidden = false
        self.lbMyMessage.isHidden = false
        self.lbMyMessageTime.isHidden = false

        self.imgViewMyProfile.layer.cornerRadius = self.imgViewMyProfile.bounds.height / 2.0
        self.imgViewMyProfile.layer.borderWidth = 1.5
        self.imgViewMyProfile.layer.borderColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
    }

    func showPartnerViews() {
        self.imgViewPartnerProfile.isHidden = false
        self.imgViewPartnerProfileBorder.isHidden = false
        self.viewPartnerMessage.isHidden = false
        self.lbPartnerMessage.isHidden = false
        self.lbPartnerMessageTime.isHidden = false

        self.imgViewMyProfile.isHidden = true
        self.imgViewMyProfileBorder.isHidden = true
        self.viewMyMessage.isHidden = true
        self.lbMyMessage.isHidden = true
        self.lbMyMessageTime.isHidden = true
    }
}
