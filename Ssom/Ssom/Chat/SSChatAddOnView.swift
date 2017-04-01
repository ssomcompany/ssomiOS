//
//  SSChatAddOnView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2017. 4. 2..
//  Copyright © 2017년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatAddOnView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var addOnButtonCollectionView: UICollectionView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellID = ""
        switch indexPath.row {
        case 0:
            cellID = "cellAttach"
        case 1:
            cellID = "cellSsomLocation"
        case 2:
            cellID = "cellReport"
        case 3:
            cellID = "cellFinishSsom"
        default:
            break
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)

        cell.layer.cornerRadius = cell.bounds.height / 2.0

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.tapAttachPhoto()
        case 1:
            self.tapShowSsomPosition()
        case 2:
            self.tapReport()
        case 3:
            self.tapFinishSssom()
        default:
            break
        }
    }

    func tapAttachPhoto() {
        print(#function)
    }

    func tapShowSsomPosition() {
        print(#function)
    }

    func tapReport() {
        print(#function)
    }

    func tapFinishSssom() {
        print(#function)
    }
}
