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

        if UIScreen.main.bounds.width <= 320 {
            self.constLbHeartCountPrefixCentorY.constant = 3
        } else {
            self.constLbHeartCountPrefixCentorY.constant = -1
        }
    }

    func configView(_ heartGood: SSHeartGoods, priceWithTax: String, heartCount: String) {

        self.heartGood = heartGood

        self.viewBoundary.layer.borderColor = heartGood.boundaryColor.cgColor
        self.imgViewPackageLabel.isHidden = !(heartGood.isEconomyPackage || heartGood.isHotPackage)
        self.imgViewPackageLabel.image = heartGood.tagIconImage
        self.lbPackage.isHidden = !(heartGood.isEconomyPackage || heartGood.isHotPackage)
        self.lbPackage.text = heartGood.tagName
        self.imgViewHeartType.image = heartGood.iconImage
        self.lbHeartCount.text = heartCount
        self.lbHeartPrice.text = priceWithTax
        self.imgViewSaleIcon.image = heartGood.saleIconImage
        self.lbSalePercent.text = heartGood.sale
        self.lbSale.isHidden = heartGood == .heart2Package

        if UIScreen.main.bounds.width <= 320 {
            self.lbHeartCountPrefix.font = UIFont.systemFont(ofSize: 16)
            self.lbHeartCount.font = UIFont.boldSystemFont(ofSize: 21)
        } else {
            self.lbHeartCountPrefix.font = UIFont.systemFont(ofSize: 31)
            self.lbHeartCount.font = UIFont.boldSystemFont(ofSize: 41)
        }
    }

    func showTapAnimation() {
        self.viewBoundary.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(), animations: { 
            self.viewBoundary.transform = CGAffineTransform.identity
            }) { (finish) in
                //
        }
    }
}
