//
//  SSFilterView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 12. 2..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSFilterViewDelegate: NSObjectProtocol {
    func closeFilterView() -> Void;
    func applyFilter(filterViewModel: SSFilterViewModel) -> Void;
}

class SSFilterView: UIView {
    @IBOutlet var filterMainView: UIView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var filterAllButton: UIButton!
    @IBOutlet var filterIPayButton: UIButton!
    @IBOutlet var filterIPayIconImageView: UIImageView!
    @IBOutlet var filterYouPayButton: UIButton!
    @IBOutlet var filterYouPayIconImageView: UIImageView!
    @IBOutlet var peopleLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!

    var delegate: SSFilterViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)

        self.filterMainView.layer.cornerRadius = 20
    }

    @IBAction func tapCloseButton(sender: AnyObject) {
        if self.delegate?.respondsToSelector("closeFilterView") != nil {
            self.delegate?.closeFilterView()
        }
    }

    @IBAction func tapFilterAllButton(sender: AnyObject) {
        self.filterAllButton.selected = true;
        self.filterIPayButton.selected = false;
        self.filterIPayIconImageView.image = UIImage(named: "icon_check_g.png")
        self.filterYouPayButton.selected = false;
        self.filterYouPayIconImageView.image = UIImage(named: "icon_target_g.png")
    }

    @IBAction func tapIPayButton(sender: AnyObject) {
        self.filterAllButton.selected = false;
        self.filterIPayButton.selected = true;
        self.filterIPayIconImageView.image = UIImage(named: "icon_check_w.png")
        self.filterYouPayButton.selected = false;
        self.filterYouPayIconImageView.image = UIImage(named: "icon_target_g.png")
    }

    @IBAction func tapFilterYouPayButton(sender: AnyObject) {
        self.filterAllButton.selected = false;
        self.filterIPayButton.selected = false;
        self.filterIPayIconImageView.image = UIImage(named: "icon_check_g.png")
        self.filterYouPayButton.selected = true;
        self.filterYouPayIconImageView.image = UIImage(named: "icon_target_w.png")
    }

    @IBAction func tapApplyButton(sender: AnyObject) {
        var filterValue: SSFilterViewModel = SSFilterViewModel(payType: .All, minPerson: 0, maxPerson: 0, minAge: 0, maxAge: 0)
        if self.filterAllButton.selected {
            filterValue.payType = .All
        } else if self.filterIPayButton.selected {
            filterValue.payType = .IPay
        } else if self.filterYouPayButton.selected {
            filterValue.payType = .YouPay
        }

        // min person

        // max person

        // min age

        // max age

        if self.delegate?.respondsToSelector("applyFilter") != nil {
            self.delegate?.applyFilter(filterValue)
        }
    }
}
