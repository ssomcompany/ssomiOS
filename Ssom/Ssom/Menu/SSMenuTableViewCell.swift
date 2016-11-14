//
//  SSMenuTableViewCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

enum SSMenuType: Int {
    case Privacy = 0, Agreement, Withdraw, Inquiry

    static let AllValues = [Privacy, Agreement, Withdraw, Inquiry]

    var url: NSURL? {
        switch self {
        case .Privacy:
            return NSURL(string: "http://ssomcompany.wixsite.com/ssominfo")
        case .Agreement:
            return NSURL(string: "http://ssomcompany.wixsite.com/termsandconditions")
        case .Withdraw:
            return nil
        case .Inquiry:
            return NSURL(string: "http://www.myssom.com")
        }
    }

    var name: String? {
        switch  self {
        case .Privacy:
            return "개인 정보 처리 방침"
        case .Agreement:
            return "이용 약관"
        case .Withdraw:
            return "회원 탈퇴"
        case .Inquiry:
            return "문의 하기"
        }
    }

    var iconImage: UIImage? {
        switch  self {
        case .Privacy:
            return UIImage(named: "iconLock")
        case .Agreement:
            return UIImage(named: "iconBook")
        case .Withdraw:
            return nil
        case .Inquiry:
            return UIImage(named: "iconMail")
        }
    }
}

class SSMenuTableViewCell: UITableViewCell {
    @IBOutlet var imgMenuIcon: UIImageView!
    @IBOutlet var lbMenuName: UILabel!

    var menuType: SSMenuType = .Privacy

    func configCell(menuType: SSMenuType) -> Void {
        self.menuType = menuType

        self.imgMenuIcon.image = self.menuType.iconImage
        self.lbMenuName.text = self.menuType.name
    }
}
