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

    var handleAttach: (() -> Void)?
    var handleSsomLocation: (() -> Void)?
    var handleReport: (() -> Void)?
    var handleFinishSsom: (() -> Void)?

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

        guard let block = self.handleAttach else { return }
        block()
    }

    func tapShowSsomPosition() {
        print(#function)

        guard let block = self.handleSsomLocation else { return }
        block()
    }

    func tapReport() {
        print(#function)

        guard let block = self.handleReport else { return }
        block()
    }

    func tapFinishSssom() {
        print(#function)

        SSAlertController.showAlertTwoButton(title: "알림",
                                             message: "끝낸 쏨은 되돌릴 수 없어요...\n쏨을 정말로 끝내시겠어요?",
                                             button1Title: "끝내기",
                                             button2Title: "취소",
                                             button1Completion: { [weak self] (action) in
                                                guard let wself = self else { return }

                                                guard let block = wself.handleFinishSsom else { return }
                                                block()
        }) { (action) in
        }
    }
}
