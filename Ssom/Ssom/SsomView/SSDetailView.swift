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
    func closeDetailView(needToReload: Bool)
    func openSignIn(completion: ((finish:Bool) -> Void)?)
    func doSsom(ssomType: SSType, model: SSViewModel)
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
        self.btnCancel.layer.shadowOffset = CGSizeMake(0, 1)
        self.btnCancel.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).CGColor
        self.btnCancel.layer.shadowOpacity = 0.3
        self.btnCancel.layer.shadowRadius = 2
    }

    func configureWithViewModel(viewModel: SSViewModel) {
        self.viewModel = viewModel;

        if let imageUrl = self.viewModel.imageUrl {
            self.imgProfile.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: nil) { [weak self] (image, error, cacheType, url) -> Void in
                guard let wself = self else { return }

                wself.imgProfile.contentMode = .ScaleAspectFill
            }
        }

        let ageArea: SSAgeAreaType = Util.getAgeArea(self.viewModel.minAge)
        self.lbAge.text = String("\(ageArea.rawValue), \(self.viewModel.userCount)")

        self.textViewDescription.text = self.viewModel.content

        self.lbDistance.text = "나와의 거리 \(Util.getDistanceString(self.viewModel.distance))"

        if SSAccountManager.sharedInstance.isAuthorized {
            if let userId = SSAccountManager.sharedInstance.userUUID {
                self.isMySsom = userId == self.viewModel.userId
            }
        }

        if let _ = self.viewModel.assignedChatroomId {
            self.btnSsom.setTitle("채팅 보기", forState: UIControlState.Normal)
            self.btnSsom.setImage(nil, forState: UIControlState.Normal)
        }

        if self.isMySsom {
            self.btnSsom.setTitle("삭제", forState: UIControlState.Normal)
            self.btnSsom.setImage(nil, forState: UIControlState.Normal)

            self.btnReport.hidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.gradationLayer == nil {
            let profileFrame = self.imgProfile.bounds

            self.gradationLayer = CAGradientLayer()
            self.gradationLayer.colors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).CGColor, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75).CGColor]
            self.gradationLayer.locations = [0.0, 0.5, 1.0]
            let gradationLayerHeight = profileFrame.height * 85.0 / 286
            self.gradationLayer.frame = CGRect(origin: CGPoint(x: 0, y: profileFrame.height - gradationLayerHeight), size: CGSize(width: profileFrame.width, height: gradationLayerHeight))
            self.imgProfile.layer.addSublayer(self.gradationLayer)
        }
    }

    func changeTheme(ssomType: SSType) {
        self.ssomType = ssomType

        if self.ssomType == .SSOM {
            self.imgHeart.image = UIImage(named: "heartGreen")
            self.viewSsomDescription.backgroundColor = UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1)
            self.lbSsom.text = self.ssomType.shortTitle
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonGreen"), forState: .Normal)
            self.lbAge.textColor = UIColor(red: 0, green: 180/255, blue: 143/255, alpha: 1)
        } else {
            self.imgHeart.image = UIImage(named: "heartRed")
            self.viewSsomDescription.backgroundColor = UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)
            self.lbSsom.text = self.ssomType.shortTitle
            self.btnSsom.setBackgroundImage(UIImage(named: "acceptButtonRed"), forState: .Normal)
            self.lbAge.textColor = UIColor(red: 237/255, green: 52/255, blue: 75/255, alpha: 1)
        }
    }
    
    @IBAction func tapClose(sender: AnyObject?) {
        self.textViewDescription.contentOffset = CGPointZero
        guard let _ = self.delegate?.closeDetailView(self.needToReload) else {
            NSLog("%@", "This SSDetailView's delegate isn't implemented closeDetailView function")

            return
        }
    }

    @IBAction func tapSsom(sender: AnyObject) {
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
                if let heartsCount = SSNetworkContext.sharedInstance.getSharedAttribute("heartsCount") as? Int where heartsCount > 0 {

                    guard let _ = self.delegate?.doSsom(self.ssomType, model: self.viewModel) else {
                        NSLog("%@", "This SSDetailView's delegate isn't implemented doSsom function")

                        return
                    }
                    
                    self.tapClose(nil)
                } else {
                    SSAlertController.showAlertTwoButton(title: "Error", message: "쏨 타기 위한 하트 갯수가 부족합니다.\n하트를 충전하시겠습니까?", button1Completion: { (action) in
                        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
                        let vc = storyboard.instantiateViewControllerWithIdentifier("HeartNaviController")
                        if let presentedViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                            presentedViewController.presentViewController(vc, animated: true, completion: nil)
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

    @IBAction func tapProfileImage(sender: AnyObject) {
        if self.viewModel.imageUrl != nil && self.viewModel.imageUrl.characters.count != 0 {

            guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let keyWindow = appDelegate.window else {
                return
            }

            self.profilePhotoView = UIView.loadFromNibNamed("SSPhotoView") as? SSPhotoView
            self.profilePhotoView.loadingImage(keyWindow.bounds, imageUrl: self.viewModel.imageUrl)
            self.profilePhotoView.delegate = self

            keyWindow.addSubview(self.profilePhotoView)
        }
    }

    @IBAction func tapReport(sender: AnyObject) {
        SSAlertController.showAlertTwoButton(title: "알림", message: "이 게시물을 신고 하시겠어요?\n신고 된 게시물은 운영정책에 따라\n삭제 등의 조치가 이루어집니다.", button1Title: "신고하기", button1Completion: { (action) in
            if let token = SSAccountManager.sharedInstance.sessionToken {
                SSNetworkAPIClient.postReport(token, postId: self.viewModel.postId, reason: "", completion: { (data, error) in
                    if let err = error {
                        print(err.localizedDescription)

                        SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                    } else {
                        self.makeToast("정상적으로 신고 되었습니다", duration: 2.0, position: .Top)
                    }
                })
            }
        }) { (action) in
                //
        }
    }

    var touchedPoint: CGPoint = CGPointZero

    @IBAction func handlePanGesture(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            self.touchedPoint = sender.translationInView(self)
            print("touchedPoint (began) : \(self.touchedPoint)")
        } else if sender.state == .Changed {
            let touchedPoint = sender.translationInView(self)
            print("touchedPoint (~ing) : \(touchedPoint)")

            if touchedPoint.y > 0 {
                self.transform = CGAffineTransformMakeTranslation(0, touchedPoint.y)
            }

        } else if sender.state == .Ended ||
            sender.state == .Cancelled ||
            sender.state == .Failed {

            let touchedPoint = sender.translationInView(self)
            print("touchedPoint (~ing) : \(touchedPoint)")

            if abs(touchedPoint.x) < abs(touchedPoint.y) {
                if touchedPoint.y > UIScreen.mainScreen().bounds.height / 2.0 {
                    self.tapClose(nil)
                } else {
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .CurveEaseOut, animations: {
                        self.transform = CGAffineTransformIdentity
                        }, completion: { (finish) in
                            
                    })
                }
            } else {
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .CurveEaseOut, animations: {
                    self.transform = CGAffineTransformIdentity
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
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
