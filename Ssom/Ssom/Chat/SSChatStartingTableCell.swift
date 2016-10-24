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

        if let message = model where message.messageType == .System {
            if message.message == "out" {
                self.lbColored.text = "쏨이 끝났어요, "
                self.lbDetailMessage.text = "실망하지 말고 다른 상대를 찾아보아요∙∙∙(T_T)"
            } else if message.message == "request" {
                self.lbColored.text = "만남 요청을 받았습니다!"
                self.lbDetailMessage.text = ""
            } else if message.message == "approve" {
                self.lbColored.text = "쏨과 만나는 중..."
                self.lbDetailMessage.text = ""
            }
        }
    }
}
