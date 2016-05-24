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

        self.configView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

//        NSBundle.mainBundle().loadNibNamed("SSChatCoachmarkView", owner: self, options: nil)
    }

    func configView() {
        self.viewHeartRound.layer.cornerRadius = self.viewHeartRound.bounds.height / 2.0
    }

    @IBAction func tapStartChat(sender: AnyObject) {
        self.removeFromSuperview()
    }
}