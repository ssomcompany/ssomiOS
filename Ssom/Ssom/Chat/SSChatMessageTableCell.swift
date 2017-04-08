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
    @IBOutlet var imgViewPartnerMessage: UIImageView!
    @IBOutlet var lbPartnerMessageTime: UILabel!
    @IBOutlet var imgViewMyProfile: UIImageView!
    @IBOutlet var imgViewMyProfileBorder: UIImageView!
    @IBOutlet var viewMyMessage: UIView!
    @IBOutlet var lbMyMessage: UILabel!
    @IBOutlet var imgViewMyMessage: UIImageView!
    @IBOutlet var lbMyMessageTime: UILabel!

    var ssomType: SSType = .SSOM
    var model: SSChatViewModel = SSChatViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewPartnerMessage.layer.cornerRadius = 6.0
        self.viewPartnerMessage.layer.borderWidth = 0.6
        self.viewPartnerMessage.layer.borderColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor

        self.viewMyMessage.layer.cornerRadius = 6.0
        self.viewMyMessage.layer.borderWidth = 0.6
        self.viewMyMessage.layer.borderColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
    }

    func configView(_ model: SSChatViewModel) {
        self.model = model

        self.backgroundColor = UIColor.clear

        self.imgViewPartnerProfileBorder.layer.borderWidth = 1.3
        self.imgViewPartnerProfileBorder.layer.borderColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor

        self.imgViewMyProfileBorder.layer.borderWidth = 1.3
        self.imgViewMyProfileBorder.layer.borderColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor

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

                if self.validateImageUrl(message: model.message) {
                    self.imgViewMyMessage.sd_setImage(with: URL(string: model.message), completed: { (image, error, _, _) in
                        if error != nil {
                        } else {
                            self.imgViewMyMessage.image = image
                            self.imgViewMyMessage.addConstraint(NSLayoutConstraint(item: self.imgViewMyMessage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.imgViewMyMessage, attribute: NSLayoutAttribute.height, multiplier: image!.size.width / image!.size.height, constant: 0.0))
                        }
                    })
                } else {
                    self.lbMyMessage.text = model.message
                    self.imgViewMyMessage.image = nil
                }
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

                if self.validateImageUrl(message: model.message) {
                    self.imgViewPartnerMessage.sd_setImage(with: URL(string: model.message), completed: { (image, error, _, _) in
                        if error != nil {
                        } else {
                            self.imgViewPartnerMessage.image = image
                            self.imgViewPartnerMessage.addConstraint(NSLayoutConstraint(item: self.imgViewPartnerMessage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.imgViewPartnerMessage, attribute: NSLayoutAttribute.height, multiplier: image!.size.width / image!.size.height, constant: 0.0))
                        }
                    })
                } else {
                    self.lbPartnerMessage.text = model.message
                    self.imgViewPartnerMessage.image = nil
                }
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
        self.imgViewMyProfileBorder.isHidden = false
        self.viewMyMessage.isHidden = false
        self.lbMyMessage.isHidden = false
        self.lbMyMessageTime.isHidden = false

        self.imgViewMyProfile.layer.cornerRadius = self.imgViewMyProfile.bounds.height / 2.0
        self.imgViewMyProfileBorder.layer.cornerRadius = self.imgViewMyProfileBorder.bounds.height / 2.0
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

        self.imgViewPartnerProfile.layer.cornerRadius = self.imgViewPartnerProfile.bounds.height / 2.0
        self.imgViewPartnerProfileBorder.layer.cornerRadius = self.imgViewPartnerProfileBorder.bounds.height / 2.0
    }

    func validateImageUrl(message: String) -> Bool {
        return message.contains("api.myssom.com/file/images/")
    }
}
