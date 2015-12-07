//
//  SSFilterView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 12. 2..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

@objc protocol SSFilterViewDelegate: NSObjectProtocol {
    optional func closeFilterView() -> Void;
}

class SSFilterView: UIView {
    @IBOutlet var filterMainView: UIView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var filterAllButton: UIButton!
    @IBOutlet var filterIPayButton: UIButton!
    @IBOutlet var filterYouPayButton: UIButton!
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
            self.delegate?.closeFilterView!()
        }
    }

    @IBAction func tapFilterAllButton(sender: AnyObject) {
        self.filterAllButton.selected = true;
        self.filterIPayButton.selected = false;
        self.filterYouPayButton.selected = false;
    }

    @IBAction func tapIPayButton(sender: AnyObject) {
        self.filterAllButton.selected = false;
        self.filterIPayButton.selected = true;
        self.filterYouPayButton.selected = false;
    }

    @IBAction func tapFilterYouPayButton(sender: AnyObject) {
        self.filterAllButton.selected = false;
        self.filterIPayButton.selected = false;
        self.filterYouPayButton.selected = true;
    }

}
