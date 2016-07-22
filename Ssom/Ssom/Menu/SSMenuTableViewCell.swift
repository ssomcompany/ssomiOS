//
//  SSMenuTableViewCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

enum SSMenuType: Int {
    case Privacy = 0, Agreement, Inquiry

    static let AllValues = [Privacy, Agreement, Inquiry]
}

class SSMenuTableViewCell: UITableViewCell {
    @IBOutlet var imgMenuIcon: UIImageView!
    @IBOutlet var lbMenuName: UILabel!

    func configCell(menuType: SSMenuType) -> Void {
        switch menuType {
        case .Privacy:
            self.imgMenuIcon.image = UIImage(named: "iconLock")
            self.lbMenuName.text = "개인 정보"
        case .Agreement:
            self.imgMenuIcon.image = UIImage(named: "iconBook")
            self.lbMenuName.text = "이용 약관"
        case .Inquiry:
            self.imgMenuIcon.image = UIImage(named: "iconMail")
            self.lbMenuName.text = "문의 하기"
        }
    }
}
