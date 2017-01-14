//
//  SSMenuHeadView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSMenuHeadViewDelegate: class {
    func openSignIn(_ completion: ((_ finish: Bool)-> Void)?)
    func showProfilePhoto()
}

class SSMenuHeadView: UITableViewHeaderFooterView {
    @IBOutlet var view: UIView!
    @IBOutlet var lbUserId: UILabel!
    @IBOutlet var btnUserId: UIButton!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var imgViewPhotoBorder: UIImageView!
    @IBOutlet var imgViewPhoto: UIImageView!
    @IBOutlet var btnPhoto: UIButton!

    weak var delegate: SSMenuHeadViewDelegate?

    var blockLogin: ((_ finish: Bool) -> Void)?

    var blockLogout: ((_ finish: Bool) -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func loadFromNib() {

        if let contentView = UIView.loadFromNibNamed("SSMenuHeadView", bundle: nil, owner: self) {
            self.contentView.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": contentView]))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": contentView]))
        }
    }

    func configView() -> Void {
//        var loginButtonStringAttributes = [String: AnyObject]()
//        if let currentLoginButtonAttributedText = self.btnLogin.titleLabel?.attributedText {
//            currentLoginButtonAttributedText.enumerateAttributes(in: NSRange(location: 0, length: currentLoginButtonAttributedText.length), options: NSAttributedString.EnumerationOptions(rawValue: 0), using: { (attr, _, _) in
//                loginButtonStringAttributes = attr as [String : AnyObject]
//                print("\(attr)")
//            })
//        }
//
//        self.btnUserId.addTarget(self, action: #selector(tapLogin(_:)), for: .touchUpInside)
//
//        if SSAccountManager.sharedInstance.isAuthorized {
//            self.lbUserId.textColor = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)
//            self.lbUserId.text = SSNetworkContext.sharedInstance.getSharedAttribute("email") as? String
//
//            let loginButtonTitle = NSAttributedString(string: "로그아웃", attributes: loginButtonStringAttributes)
//            self.btnLogin.setAttributedTitle(loginButtonTitle, for: UIControlState())
//
//            self.btnUserId.isEnabled = false
//        } else {
//            let stringAttributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
//            let loginString = NSAttributedString(string: "로그인 후 이용할 수 있습니다.", attributes: stringAttributes)
//
//            let loginButtonTitle = NSAttributedString(string: "로그인", attributes: loginButtonStringAttributes)
//            self.btnLogin.setAttributedTitle(loginButtonTitle, for: UIControlState())
//
//            self.lbUserId.textColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1)
//            self.lbUserId.attributedText = loginString
//
//            self.btnUserId.isEnabled = true
//        }

        self.showProfileImage()
    }

    func showProfileImage() {
        self.btnPhoto.isHidden = true
        self.imgViewPhoto.isHidden = true

        if SSAccountManager.sharedInstance.isAuthorized {
            self.btnPhoto.isHidden = false
            if let imageUrl = SSAccountManager.sharedInstance.profileImageUrl, imageUrl.lengthOfBytes(using: String.Encoding.utf8) != 0 {
                self.imgViewPhoto.sd_setImage(with: URL(string: imageUrl+"?thumbnail=200"), placeholderImage: nil, options: [], completed: { [weak self] (image, error, _, _) in
                    guard let wself = self else { return }

                    if error != nil {
                    } else {
                        let croppedProfileImage: UIImage = UIImage.cropInCircle(image!, frame: CGRect(x: 0, y: 0, width: wself.imgViewPhoto.bounds.size.width, height: wself.imgViewPhoto.bounds.size.height))

                        wself.imgViewPhoto.image = croppedProfileImage
                    }
                    })
                self.imgViewPhoto.isHidden = false
            }
        }
    }

    @IBAction func tapPhoto(_ sender: AnyObject) {
        guard let _ = self.delegate?.showProfilePhoto() else {
            return
        }
    }

    @IBAction func tapLogin(_ sender: AnyObject) {
        if SSAccountManager.sharedInstance.isAuthorized {
            guard let block = self.blockLogout else {
                return
            }

            block(true)
        } else {
            guard let _ = self.delegate?.openSignIn({ [weak self] (finish) in
                if finish {
                    guard let block = self?.blockLogin else {
                        return
                    }

                    block(finish)
                }
                }) else {
                    return
            }
        }
    }

    @IBAction func tapMenuPush(_ sender: AnyObject) {
//        SSAlertController.showAlertConfirm(title: "알림", message: "Cache size : \(Util.getImageCacheSize(.Mega))", completion: nil)

        if let url = SSMenuType.inquiry.url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }

    }

    @IBAction func tapMenuHeart(_ sender: AnyObject) {

        if SSAccountManager.sharedInstance.isAuthorized {

            let storyboard = UIStoryboard(name: "Menu", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HeartNaviController")
            if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController {
                presentedViewController.present(vc, animated: true, completion: nil)
            }

        } else {
            guard let _ = self.delegate?.openSignIn({ [weak self] (finish) in
                if finish {
                    guard let block = self?.blockLogin else {
                        return
                    }

                    block(finish)
                }
                }) else {
                    return
            }
        }
    }
}
