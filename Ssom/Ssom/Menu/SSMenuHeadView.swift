//
//  SSMenuHeadView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSMenuHeadViewDelegate: class {
    func openSignIn(completion: ((finish: Bool)-> Void)?)
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

    var blockLogin: ((finish: Bool) -> Void)?

    var blockLogout: ((finish: Bool) -> Void)?

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
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": contentView]))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": contentView]))
        }
    }

    func configView() -> Void {
        var loginButtonStringAttributes = [String: AnyObject]()
        if let currentLoginButtonAttributedText = self.btnLogin.titleLabel?.attributedText {
            currentLoginButtonAttributedText.enumerateAttributesInRange(NSRange(location: 0, length: currentLoginButtonAttributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0), usingBlock: { (attr, _, _) in
                loginButtonStringAttributes = attr
                print("\(attr)")
            })
        }

        self.btnUserId.addTarget(self, action: #selector(tapLogin(_:)), forControlEvents: .TouchUpInside)

        if SSAccountManager.sharedInstance.isAuthorized {
            self.lbUserId.textColor = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)
            self.lbUserId.text = SSNetworkContext.sharedInstance.getSharedAttribute("email") as? String

            let loginButtonTitle = NSAttributedString(string: "로그아웃", attributes: loginButtonStringAttributes)
            self.btnLogin.setAttributedTitle(loginButtonTitle, forState: UIControlState.Normal)

            self.btnUserId.enabled = false
        } else {
            let stringAttributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            let loginString = NSAttributedString(string: "로그인 후 이용할 수 있습니다.", attributes: stringAttributes)

            let loginButtonTitle = NSAttributedString(string: "로그인", attributes: loginButtonStringAttributes)
            self.btnLogin.setAttributedTitle(loginButtonTitle, forState: UIControlState.Normal)

            self.lbUserId.textColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1)
            self.lbUserId.attributedText = loginString

            self.btnUserId.enabled = true
        }

        self.showProfileImage()
    }

    func showProfileImage() {
        self.btnPhoto.hidden = true
        self.imgViewPhoto.hidden = true

        if SSAccountManager.sharedInstance.isAuthorized {
            self.btnPhoto.hidden = false
            if let imageUrl = SSAccountManager.sharedInstance.profileImageUrl where imageUrl.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
                self.imgViewPhoto.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: nil, completed: { [weak self] (image, error, _, _) in
                    guard let wself = self else { return }

                    if error != nil {
                    } else {
                        let croppedProfileImage: UIImage = UIImage.cropInCircle(image, frame: CGRectMake(0, 0, wself.imgViewPhoto.bounds.size.width, wself.imgViewPhoto.bounds.size.height))

                        wself.imgViewPhoto.image = croppedProfileImage
                    }
                    })
                self.imgViewPhoto.hidden = false
            }
        }
    }

    @IBAction func tapPhoto(sender: AnyObject) {
        guard let _ = self.delegate?.showProfilePhoto() else {
            return
        }
    }

    @IBAction func tapLogin(sender: AnyObject) {
        if SSAccountManager.sharedInstance.isAuthorized {
            guard let block = self.blockLogout else {
                return
            }

            block(finish: true)
        } else {
            guard let _ = self.delegate?.openSignIn({ [weak self] (finish) in
                if finish {
                    guard let block = self?.blockLogin else {
                        return
                    }

                    block(finish: finish)
                }
                }) else {
                    return
            }
        }
    }

    @IBAction func tapMenuPush(sender: AnyObject) {
//        SSAlertController.showAlertConfirm(title: "알림", message: "Cache size : \(Util.getImageCacheSize(.Mega))", completion: nil)

        if let url = SSMenuType.Inquiry.url {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }

    }

    @IBAction func tapMenuHeart(sender: AnyObject) {

        if SSAccountManager.sharedInstance.isAuthorized {

            let storyboard = UIStoryboard(name: "Menu", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("HeartNaviController")
            if let presentedViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                presentedViewController.presentViewController(vc, animated: true, completion: nil)
            }

        } else {
            guard let _ = self.delegate?.openSignIn({ [weak self] (finish) in
                if finish {
                    guard let block = self?.blockLogin else {
                        return
                    }

                    block(finish: finish)
                }
                }) else {
                    return
            }
        }
    }
}
