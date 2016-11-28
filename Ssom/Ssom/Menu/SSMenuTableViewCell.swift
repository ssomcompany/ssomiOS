//
//  SSMenuTableViewCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

enum SSMenuType: Int {
    case privacy = 0, agreement, withdraw, inquiry

    static let AllValues = [privacy, agreement, withdraw, inquiry]

    var url: URL? {
        switch self {
        case .privacy:
            return URL(string: "http://ssomcompany.wixsite.com/ssominfo")
        case .agreement:
            return URL(string: "http://ssomcompany.wixsite.com/termsandconditions")
        case .withdraw:
            return nil
        case .inquiry:
            return URL(string: "http://www.myssom.com")
        }
    }

    var name: String? {
        switch  self {
        case .privacy:
            return "개인 정보 처리 방침"
        case .agreement:
            return "이용 약관"
        case .withdraw:
            return "회원 탈퇴"
        case .inquiry:
            return "문의 하기"
        }
    }

    var iconImage: UIImage? {
        switch  self {
        case .privacy:
            return UIImage(named: "iconLock")
        case .agreement:
            return UIImage(named: "iconBook")
        case .withdraw:
            return nil
        case .inquiry:
            return UIImage(named: "iconMail")
        }
    }
}

class SSMenuTableViewCell: UITableViewCell {
    @IBOutlet var imgMenuIcon: UIImageView!
    @IBOutlet var lbMenuName: UILabel!

    var menuType: SSMenuType = .privacy

    func configCell(_ menuType: SSMenuType) -> Void {
        self.menuType = menuType

        self.imgMenuIcon.image = self.menuType.iconImage
        self.lbMenuName.text = self.menuType.name
    }
}
