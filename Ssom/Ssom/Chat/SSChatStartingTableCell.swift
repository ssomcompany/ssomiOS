//
//  SSChatStartingTableCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 29..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatStartingTableCell: UITableViewCell {
    @IBOutlet var lbColored: UILabel!
    @IBOutlet var constLbColoredCenterXToSuper: NSLayoutConstraint!
    @IBOutlet var lbDetailMessage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configView(ssomType: SSType, model: SSChatViewModel? = nil) {
        switch ssomType {
        case .SSOM:
            self.lbColored.textColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1)
        case .SSOSEYO:
            self.lbColored.textColor = UIColor(red: 237.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1)
        }

        self.lbColored.text = "두근두근, "
        self.constLbColoredCenterXToSuper.constant = -48.0
        self.lbDetailMessage.text = "대화가 시작 되었쏨 : )"

        if let message = model where message.messageType == .System {
            if message.message == "out" || message.message == "complete" {
                self.lbColored.text = "쏨이 끝났어요, "
                self.lbDetailMessage.text = "다른 상대를∙∙∙(T_T)"
            } else if message.message == "request" {
                if message.fromUserId == SSAccountManager.sharedInstance.userUUID {
                    self.lbColored.text = "만남 요청을 했습니다!"
                } else {
                    self.lbColored.text = "만남 요청을 받았습니다!"
                }
                self.lbDetailMessage.text = ""
                self.constLbColoredCenterXToSuper.constant = 0.0
            } else if message.message == "approve" {
                self.lbColored.text = "쏨과 만나는 중..."
                self.lbDetailMessage.text = ""
                self.constLbColoredCenterXToSuper.constant = 0.0
            } else if message.message == "cancel" {
                self.lbColored.text = "요청이 취소되었어요"
                self.lbDetailMessage.text = ""
                self.constLbColoredCenterXToSuper.constant = 0.0
            }
        }
    }
}
