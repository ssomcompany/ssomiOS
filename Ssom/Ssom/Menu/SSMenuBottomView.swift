//
//  SSMenuBottomView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 8. 21..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSMenuBottomView: UITableViewHeaderFooterView {

    @IBOutlet var lbLogout: UILabel!

    var blockLogout: ((_ finish: Bool) -> Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func loadFromNib() {

        if let contentView = UIView.loadFromNibNamed("SSMenuBottomView", bundle: nil, owner: self) {
            self.contentView.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": contentView]))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": contentView]))
        }
    }

    func configView() {
        if SSAccountManager.sharedInstance.isAuthorized {
        } else {
            let stringAttributes = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
            let logoutString = NSAttributedString(string: "로그아웃", attributes: stringAttributes)

            self.lbLogout.textColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1)
            self.lbLogout.attributedText = logoutString
        }

    }

    @IBAction func tapLogout(_ sender: AnyObject) {
        guard let _ = self.blockLogout else {
            return
        }

        self.blockLogout(true)
    }
}
