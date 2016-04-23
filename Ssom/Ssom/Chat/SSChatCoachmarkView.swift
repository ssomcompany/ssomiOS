//
//  SSChatCoachmarkView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 24..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatCoachmarkView: UIView {
    @IBOutlet var viewHeartRound: UIView!
    @IBOutlet var lbGuideText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewHeartRound.layer.cornerRadius = self.viewHeartRound.bounds.size.height / 2.0
    }

    @IBAction func tapStartChat(sender: AnyObject) {
    }
}