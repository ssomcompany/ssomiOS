//
//  SSListTableViewCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 11..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

@objc protocol SSListTableViewCellDelegate: NSObjectProtocol {
    optional func tapProfileImage(sender: AnyObject, imageUrl: String)
}

class SSListTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var updatedTimeLabel: UILabel!
    @IBOutlet var memberInfoLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var imageTapButton: UIButton!

    var delegate: SSListTableViewCellDelegate?
    var profilImageUrl: String?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func tapProfileImage(sender: AnyObject) {
        if (self.delegate?.respondsToSelector(#selector(tapProfileImage(_:))) != nil) {
            self.delegate?.tapProfileImage!(sender, imageUrl:self.profilImageUrl!)
        }
    }
}
