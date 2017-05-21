//
//  SSDetailView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 2. 10..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import Toast_Swift

protocol SSDetailViewDelegate: class {
    func closeDetailView(_ needToReload: Bool)
    func openSignIn(_ completion: ((_ finish:Bool) -> Void)?)
    func doSsom(_ ssomType: SSType, model: SSViewModel)
}

class SSDetailView: UIView, SSPhotoViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var viewDetail: UIView!
    @IBOutlet var imgHeart: UIImageView!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var viewSsomDescription: UIView!
    @IBOutlet var lbSsom: UILabel!
    @IBOutlet var lbDistance: UILabel!
    @IBOutlet var lbAge: UILabel!
    @IBOutlet var textViewDescription: UITextView!
    @IBOutlet var btnSsom: UIButton!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnReport: UIButton!

    var profilePhotoView: SSPhotoView!

    weak var delegate: SSDetailViewDelegate!
    var ssomType: SSType!

    var viewModel: SSViewModel!

    var isMySsom: Bool = false

    var needToReload: Bool = false

    var gradationLayer: CAGradientLayer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewDetail.clipsToBounds = true
        self.viewDetail.layer.cornerRadius = 15

        self.btnCancel.layer.cornerRadius = 2
        self.btnCancel.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.btnCancel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        self.btnCancel.layer.shadowOpacity = 0.3
        self.btnCancel.layer.shadowRadius = 2
    }

    func configureWithViewModel(_ viewModel: SSViewModel) {
        self.viewModel = viewModel;

        if let imageUrl = self.viewModel.imageUrl {
            self.imgProfile.sd_setImage(with: URL(string: imageUrl), placeholderImage: nil, options: []) { [weak self] (image, error, cacheType, url) -> Void in
                guard let wself = self else { return }

                wself.imgProfile.contentMode = .scaleAspectFill
            }
        }

        let ageArea: SSAgeAreaType = Util.getAgeArea(self.viewModel.minAge)
        self.lbAge.text = String("\(ageArea.rawValue), \(self.viewModel.userCount!)")

        self.textViewDescription.text = self.viewModel.content

        self.lbDistance.text = "나와의 거리 \(Util.getDistanceString(self.viewModel.distance))"

        if SSAccountManager.sharedInstance.isAuthorized {
            if let userId = SSAccountManager.sharedInstance.userUUID {
                self.isMySsom = userId == self.viewModel.userId
            }
        }

        if let _ = self.viewModel.assignedChatroomId {
            self.btnSsom.setTitle("채팅 보기", for: UIControlState())
            self.btnSsom.setImage(nil, for: UIControlState())
        }

        if self.isMySsom {
            self.btnSsom.setTitle("삭제", for: UIControlState())
            self.btnSsom.setImage(nil, for: UIControlState())

            self.btnReport.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.gradationLayer == nil {
            let profileFrame = self.imgProfile.bounds

            self.gradationLayer = CAGradientLayer()
            self.gradationLayer.colors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).cgColor, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).cgColor, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75).cgColor]
            self.gradationLayer.locations = [0.0, 0.5, 1.0]
            let gradationLayerHeight = profileFrame.height * 85.0 / 286
            self.gradationLayer.frame = CGRect(origin: CGPoint(x: 0, y: profileFrame.height - gradationLayerHeight), size: CGSize(width: profileFrame.width, height: gradationLayerHeight))
            self.imgProfile.layer.addSublayer(self.gradationLayer)
        }
    }

    func changeTheme() {
        self.ssomType = self.viewModel.ssomType

        if self.ssomType == .SSOM {
            self.imgHeart.image = UIImage(named: "heartGreen")
            self.viewSsomDescription.backgroundColor = UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1)
            self.lbSsom.text = self.ssomType.shortTitle
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonGreen"), for: UIControlState())
            self.lbAge.textColor = UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1)
        } else {
            self.imgHeart.image = UIImage(named: "heartRed")
            self.viewSsomDescription.backgroundColor = UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)
            self.lbSsom.text = self.ssomType.shortTitle
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonRed"), for: UIControlState())
            self.lbAge.textColor = UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)
        }
    }
    
    @IBAction func tapClose(_ sender: AnyObject?) {
        self.textViewDescription.contentOffset = CGPoint.zero
        guard let _ = self.delegate?.closeDetailView(self.needToReload) else {
            NSLog("%@", "This SSDetailView's delegate isn't implemented closeDetailView function")

            return
        }
    }

    @IBAction func tapSsom(_ sender: AnyObject) {
        if SSAccountManager.sharedInstance.isAuthorized {
            if self.isMySsom {
                if let token = SSAccountManager.sharedInstance.sessionToken {
                    SSNetworkAPIClient.deletePost(token, postId: self.viewModel.postId, completion: { (error) in
                        if let err = error {
                            SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                        } else {
                            SSAlertController.showAlertConfirm(title: "알림", message: "성공적으로 삭제 되었쏨!", completion: { (action) in
                                self.needToReload = true
                                self.tapClose(nil)
                            })
                        }
                    })
                }
            } else {
                if let _ = self.viewModel.assignedChatroomId {
                    guard let _ = self.delegate?.doSsom(self.ssomType, model: self.viewModel) else {
                        NSLog("%@", "This SSDetailView's delegate isn't implemented doSsom function")

                        return
                    }

                    self.tapClose(nil)

                    return
                }
                if let heartsCount = SSNetworkContext.sharedInstance.getSharedAttribute("heartsCount") as? Int, heartsCount > 0 {

                    guard let _ = self.delegate?.doSsom(self.ssomType, model: self.viewModel) else {
                        NSLog("%@", "This SSDetailView's delegate isn't implemented doSsom function")

                        return
                    }
                    
                    self.tapClose(nil)
                } else {
                    SSAlertController.showAlertTwoButton(title: "Error", message: "쏨 타기 위한 하트 갯수가 부족합니다.\n하트를 충전하시겠습니까?", button1Completion: { (action) in
                        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "HeartNaviController")
                        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController {
                            presentedViewController.present(vc, animated: true, completion: nil)
                        }
                    }, button2Completion: { (action) in
                        //
                    })
                }
            }
        } else {
            guard let _ = self.delegate?.openSignIn(nil) else {
                NSLog("%@", "This SSDetailView's delegate isn't implemented openSignIn function")

                return
            }

        }
    }

    @IBAction func tapProfileImage(_ sender: AnyObject) {
        if self.viewModel.imageUrl != nil && self.viewModel.imageUrl.characters.count != 0 {

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let keyWindow = appDelegate.window else {
                return
            }

            self.profilePhotoView = UIView.loadFromNibNamed("SSPhotoView") as? SSPhotoView
            self.profilePhotoView.loadImage(keyWindow.bounds, imageUrl: self.viewModel.imageUrl)
            self.profilePhotoView.delegate = self

            keyWindow.addSubview(self.profilePhotoView)
        }
    }

    @IBAction func tapReport(_ sender: AnyObject) {
        SSAlertController.showAlertTwoButton(title: "알림", message: "이 게시물을 신고 하시겠어요?\n신고 된 게시물은 운영정책에 따라\n삭제 등의 조치가 이루어집니다.", button1Title: "신고하기", button1Completion: { (action) in
            if let token = SSAccountManager.sharedInstance.sessionToken {
                SSNetworkAPIClient.postReport(token, postId: self.viewModel.postId, reason: "", completion: { (data, error) in
                    if let err = error {
                        print(err.localizedDescription)

                        SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                    } else {
                        self.makeToast("정상적으로 신고 되었습니다", duration: 2.0, position: .top)
                    }
                })
            }
        }) { (action) in
                //
        }
    }

    var touchedPoint: CGPoint = CGPoint.zero

    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.touchedPoint = sender.translation(in: self)
            print("touchedPoint (began) : \(self.touchedPoint)")
        } else if sender.state == .changed {
            let touchedPoint = sender.translation(in: self)
            print("touchedPoint (~ing) : \(touchedPoint)")

            if touchedPoint.y > 0 {
                self.transform = CGAffineTransform(translationX: 0, y: touchedPoint.y)
            }

        } else if sender.state == .ended ||
            sender.state == .cancelled ||
            sender.state == .failed {

            let touchedPoint = sender.translation(in: self)
            print("touchedPoint (~ing) : \(touchedPoint)")

            if abs(touchedPoint.x) < abs(touchedPoint.y) {
                if touchedPoint.y > UIScreen.main.bounds.height / 2.0 {
                    self.tapClose(nil)
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                        self.transform = CGAffineTransform.identity
                        }, completion: { (finish) in
                            
                    })
                }
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                    self.transform = CGAffineTransform.identity
                    }, completion: { (finish) in

                })
            }
        }
    }

// MARK:- SSPhotoViewDelegate
    func tapPhotoViewClose() {
        self.profilePhotoView.removeFromSuperview()
    }

// MARK:- UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
