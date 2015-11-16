//
//  ListTableViewCell.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 11..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var updatedTimeLabel: UILabel!
    @IBOutlet var memberInfoLabel: UILabel!
    @IBOutlet var ingLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
