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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configView(ssomType: SSType) {
        switch ssomType {
        case .SSOM:
            lbColored.textColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1)
        case .SSOSEYO:
            lbColored.textColor = UIColor(red: 237.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1)
        }
    }
}
