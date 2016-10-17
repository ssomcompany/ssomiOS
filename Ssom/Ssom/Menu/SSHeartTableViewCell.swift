//
//  SSHeartTableViewCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 10. 15..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSHeartTableViewCell: UITableViewCell {
    
    @IBOutlet var viewBoundary: UIView!
    @IBOutlet var imgViewPackageLabel: UIImageView!
    @IBOutlet var lbPackage: UILabel!
    @IBOutlet var imgViewHeartType: UIImageView!
    @IBOutlet var lbHeartCountPrefix: UILabel!
    @IBOutlet var constLbHeartCountPrefixCentorY: NSLayoutConstraint!
    @IBOutlet var lbHeartCount: UILabel!
    @IBOutlet var lbHeartPrice: UILabel!
    @IBOutlet var imgViewSaleIcon: UIImageView!
    @IBOutlet var lbSalePercent: UILabel!
    @IBOutlet var lbSale: UILabel!

    var heartGood: SSHeartGoods!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewBoundary.layer.cornerRadius = 8.6
        self.viewBoundary.layer.borderWidth = 1.4
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if UIScreen.mainScreen().bounds.width <= 320 {
            self.constLbHeartCountPrefixCentorY.constant = 3
        } else {
            self.constLbHeartCountPrefixCentorY.constant = -1
        }
    }

    func configView(heartGood: SSHeartGoods, priceWithTax: String, heartCount: String) {

        self.heartGood = heartGood

        self.viewBoundary.layer.borderColor = heartGood.boundaryColor.CGColor
        self.imgViewPackageLabel.hidden = !(heartGood.isEconomyPackage || heartGood.isHotPackage)
        self.imgViewPackageLabel.image = heartGood.tagIconImage
        self.lbPackage.hidden = !(heartGood.isEconomyPackage || heartGood.isHotPackage)
        self.lbPackage.text = heartGood.tagName
        self.imgViewHeartType.image = heartGood.iconImage
        self.lbHeartCount.text = heartCount
        self.lbHeartPrice.text = priceWithTax
        self.imgViewSaleIcon.image = heartGood.saleIconImage
        self.lbSalePercent.text = heartGood.sale
        self.lbSale.hidden = heartGood == .heart2Package

        if UIScreen.mainScreen().bounds.width <= 320 {
            self.lbHeartCountPrefix.font = UIFont.systemFontOfSize(16)
            self.lbHeartCount.font = UIFont.boldSystemFontOfSize(21)
        } else {
            self.lbHeartCountPrefix.font = UIFont.systemFontOfSize(31)
            self.lbHeartCount.font = UIFont.boldSystemFontOfSize(41)
        }
    }
}
