//
//  SSChatAddOnView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2017. 4. 2..
//  Copyright © 2017년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatAddOnView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var addOnButtonCollectionView: UICollectionView!

    var handleAttach: (() -> Void)?
    var handleSsomLocation: (() -> Void)?
    var handleReport: (() -> Void)?
    var handleFinishSsom: (() -> Void)?

    var pickedImageExtension: String!
    var pickedImageName: String!
    var pickedImageData: Data!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellID = ""
        switch indexPath.row {
        case 0:
            cellID = "cellAttach"
//        case 1:
//            cellID = "cellSsomLocation"
        case 1:
            cellID = "cellReport"
        case 2:
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
//        case 1:
//            self.tapShowSsomPosition()
        case 1:
            self.tapReport()
        case 2:
            self.tapFinishSssom()
        default:
            break
        }
    }

    func tapAttachPhoto() {
        print(#function)

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.parentViewController?.present(imagePickerController, animated: true, completion: nil)
    }

    func tapShowSsomPosition() {
        print(#function)

        guard let block = self.handleSsomLocation else { return }
        block()
    }

    func tapReport() {
        print(#function)

        SSAlertController.showAlertTwoButton(title: "알림", message: "이 게시물을 신고 하시겠어요?\n신고 된 게시물은 운영정책에 따라\n삭제 등의 조치가 이루어집니다.", button1Title: "신고하기", button1Completion: { (action) in
            guard let block = self.handleReport else { return }
            block()
        }) { (action) in
            //
        }
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

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {

        let pickedImage: UIImage!
        // photo library
        if let pickedImageURL: URL = editingInfo![UIImagePickerControllerReferenceURL] as? URL {
            let pickedImageURLQueryParams: Array = pickedImageURL.query!.components(separatedBy: CharacterSet(charactersIn: "=&"))
            pickedImage = editingInfo![UIImagePickerControllerOriginalImage] as! UIImage

            var isExt: Bool = false;
            for queryParam: String in pickedImageURLQueryParams {
                if queryParam == "ext" {
                    isExt = true
                    continue
                }
                if isExt {
                    switch queryParam {
                    case "PNG":
                        self.pickedImageExtension = "png"
                        self.pickedImageData = UIImagePNGRepresentation(pickedImage)
                    case "JPG", "JPEG":
                        self.pickedImageExtension = "jpeg"
                        self.pickedImageData = UIImageJPEGRepresentation(pickedImage, 1.0)
                    default:
                        print("unable to upload!!")
                        break
                    }

                    break
                }
            }
            self.pickedImageName = pickedImageURL.lastPathComponent
        } else {
            pickedImage = image

            self.pickedImageExtension = "png"
            self.pickedImageName = "camera.png"
            self.pickedImageData = UIImagePNGRepresentation(pickedImage)
        }

        picker.dismiss(animated: true, completion: { [weak self] in
            if let wself = self {
//                let croppedProfileImage: UIImage = UIImage.cropInCircle(pickedImage, frame: CGRect(x: 0, y: 0, width: wself.imgViewPhoto.bounds.size.width, height: wself.imgViewPhoto.bounds.size.height))

//                wself.imgViewPhoto.image = croppedProfileImage

                guard let block = wself.handleAttach else { return }
                block()
            }
        })
    }
}
