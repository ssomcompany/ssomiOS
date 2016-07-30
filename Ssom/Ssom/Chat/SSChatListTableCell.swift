//
//  SSChatListTableCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 29..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatListTableCell: UITableViewCell {
    @IBOutlet var imgViewProfile: UIImageView!
    @IBOutlet var imgViewProfileBorder: UIImageView!
    @IBOutlet var lbSsomAgePeople: UILabel!
    @IBOutlet var lbLastMessage: UILabel!
    @IBOutlet var viewCountBackground: UIView!
    @IBOutlet var lbNewMessageCount: UILabel!
    @IBOutlet var lbDistance: UILabel!
    @IBOutlet var lbCreatedDate: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewCountBackground.layer.cornerRadius = self.viewCountBackground.bounds.size.height / 2
    }

    func configView() {

    }
}
