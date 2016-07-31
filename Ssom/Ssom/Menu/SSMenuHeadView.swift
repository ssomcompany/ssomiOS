//
//  SSMenuHeadView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSMenuHeadViewDelegate {
    func openSignIn(completion: ((finish: Bool)-> Void)?)
    func callSignOut(completion: ((finish: Bool)-> Void)?)
}

class SSMenuHeadView: UITableViewHeaderFooterView {
    @IBOutlet var view: UIView!
    @IBOutlet var lbUserId: UILabel!
    @IBOutlet var btnSignOut: UIButton!

    var delegate: SSMenuHeadViewDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.loadFromNib()
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
        if SSAccountManager.sharedInstance.isAuthorized {
            self.lbUserId.textColor = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)
            self.lbUserId.text = SSNetworkContext.sharedInstance.getSharedAttribute("userId") as? String

            self.btnSignOut.hidden = false
        } else {
            self.lbUserId.textColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1)
            self.lbUserId.text = "로그인"

            self.btnSignOut.hidden = true
        }
    }

    @IBAction func tapSignOut(sender: AnyObject) {
        guard let _ = self.delegate?.callSignOut({ [weak self] (finish) in
            if finish {
                self?.configView()
            }
        }) else {
            return
        }
    }

    @IBAction func tapMenuUser(sender: AnyObject) {
        if SSAccountManager.sharedInstance.isAuthorized {

        } else {
            guard let _ = self.delegate?.openSignIn({ [weak self] (finish) in
                if finish {
                    self?.configView()
                }
            }) else {
                return
            }
        }
    }

    @IBAction func tapMenuPush(sender: AnyObject) {
    }

    @IBAction func tapMenuHeart(sender: AnyObject) {
    }
}
