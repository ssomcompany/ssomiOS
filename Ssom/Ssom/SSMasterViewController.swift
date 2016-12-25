//
//  SSMasterViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 4..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import GoogleMaps

let kMapButtonTitle: String = "MAP"
let kListButtonTitle: String = "LIST"

class SSMasterViewController: UIViewController, UITabBarDelegate {

    var barButtonItems: SSNavigationBarItems!
    var segButton1: UIButton!
    var segButton2: UIButton!

    @IBOutlet var tabBar: UITabBar!

    @IBOutlet var mapView: UIView!
    @IBOutlet var listView: UIView!

    var buttonBackgroundView: UIImageView!
    var lbButtonTitle: UILabel!

    var unreadCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        self.setNavigationBarView()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: SSInternalNotification.PurchasedHeart.rawValue), object: nil, queue: nil) { [weak self] (notification) in

            guard let wself = self else { return }

            if let userInfo = notification.userInfo {
                if let heartsCount = userInfo["heartsCount"] as? Int {
                    wself.barButtonItems.changeHeartCount(heartsCount)
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setNavigationBarView() {
        var naviTitleViewFrame:CGRect = self.navigationItem.titleView!.frame
        naviTitleViewFrame = CGRect(x: naviTitleViewFrame.origin.x, y: naviTitleViewFrame.origin.y
            , width: naviTitleViewFrame.size.width, height: CGFloatWithScreenRatio(38, axis: Axis.y, criteria: .iPhone6Plus))
        self.navigationItem.titleView!.frame = naviTitleViewFrame

        let titleBackgroundView: UIImageView = UIImageView(image: UIImage(named: "1DepToggleOn.png"))
        titleBackgroundView.frame = CGRectMakeWithScreenRatio(0, 0, 175, 38, criteria: .iPhone6Plus)
        self.navigationItem.titleView!.addSubview(titleBackgroundView)

        self.buttonBackgroundView = UIImageView(image: UIImage(named: "1DepToggleOff.png"))
        self.buttonBackgroundView.frame = CGRectMakeWithScreenRatio(0, 0, 97, 38, criteria: .iPhone6Plus)
        self.navigationItem.titleView!.addSubview(self.buttonBackgroundView)

        self.lbButtonTitle = UILabel()
        self.lbButtonTitle.text = kMapButtonTitle
        self.lbButtonTitle.textColor = UIColor.white
        self.buttonBackgroundView.addSubview(self.lbButtonTitle)

        self.lbButtonTitle.translatesAutoresizingMaskIntoConstraints = false
        self.buttonBackgroundView.addConstraint(NSLayoutConstraint(item: self.buttonBackgroundView, attribute: .centerX, relatedBy: .equal, toItem: self.lbButtonTitle, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.buttonBackgroundView.addConstraint(NSLayoutConstraint(item: self.buttonBackgroundView, attribute: .centerY, relatedBy: .equal, toItem: self.lbButtonTitle, attribute: .centerY, multiplier: 1.0, constant: 0.0))

        self.segButton1 = UIButton(frame: CGRectMakeWithScreenRatio(0, 0, 97, 38, criteria: .iPhone6Plus))
        self.segButton1.setTitle(kMapButtonTitle, for: UIControlState())
        self.segButton1.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1), for: UIControlState())
        self.segButton1.setTitleColor(UIColor.clear, for: .selected)
//        self.segButton1.setTitleColor(UIColor.whiteColor(), forState: .Selected)
//        self.segButton1.setBackgroundImage(UIImage(named: "1DepToggleOff.png"), forState: .Selected)
        self.segButton1.isSelected = true
        self.navigationItem.titleView!.addSubview(self.segButton1)

        self.segButton2 = UIButton(frame: CGRectMakeWithScreenRatio(CGFloat(175-97), 0, 97, 38, criteria: .iPhone6Plus))
        self.segButton2.setTitle(kListButtonTitle, for: UIControlState())
        self.segButton2.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1), for: UIControlState())
        self.segButton2.setTitleColor(UIColor.clear, for: .selected)
//        self.segButton2.setTitleColor(UIColor.whiteColor(), forState: .Selected)
//        self.segButton2.setBackgroundImage(UIImage(named: "1DepToggleOff.png"), forState: .Selected)
        self.segButton2.isSelected = false
        self.navigationItem.titleView!.addSubview(self.segButton2)

        if #available(iOS 8.2, *) {
            self.segButton1.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
            self.segButton2.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)

            self.lbButtonTitle.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 13) {
                self.segButton1.titleLabel?.font = font
                self.lbButtonTitle.font = font
            }
            if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 13) {
                self.segButton2.titleLabel?.font = font
            }
        }

        let leftBarButtonItem: UIBarButtonItem = self.navigationItem.leftBarButtonItem!
        leftBarButtonItem.title = ""
        leftBarButtonItem.image = UIImage.resizeImage(UIImage(named: "manu.png")!, frame: CGRect(x: 0, y: 0, width: 21, height: 14))
        leftBarButtonItem.target = self
        leftBarButtonItem.action = #selector(tapMenu)

        let rightBarButtonItems: Array = self.navigationItem.rightBarButtonItems!
        if rightBarButtonItems.count == 2 {
            self.barButtonItems = SSNavigationBarItems(animated: true)

            let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            barButtonSpacer.width = 20

            self.barButtonItems.btnHeartBar.addTarget(self, action: #selector(tapHeart), for: UIControlEvents.touchUpInside)
            let heartBarButton = UIBarButtonItem(customView: barButtonItems.heartBarButtonView!)

            self.barButtonItems.btnMessageBar.addTarget(self, action: #selector(tapChat), for: UIControlEvents.touchUpInside)
            let messageBarButton = UIBarButtonItem(customView: barButtonItems.messageBarButtonView!)

            self.navigationItem.rightBarButtonItems = [messageBarButton, barButtonSpacer, heartBarButton]
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadData()
    }

    override func initView() {
        if let segmentControl = self.navigationItem.titleView as? UISegmentedControl {
            segmentControl.selectedSegmentIndex = 0

            self.switchView(segmentControl)

            self.loadData()
        }
    }

    func loadData() {
        if let token = SSAccountManager.sharedInstance.sessionToken {
            SSNetworkAPIClient.getUnreadCount(token, completion: { (data, error) in
                if let err = error {
                    print(err.localizedDescription)
//                    SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                } else {
                    if let rawData = data, let unreadCount = rawData["unreadCount"] as? Int {
                        print("unreadCount : \(unreadCount)")

                        self.unreadCount = unreadCount
                        self.barButtonItems.changeMessageCount(unreadCount, hiddenIfZero: false)
                    }
                }
            })
        }

        // heart count
        if let heartsCount = SSNetworkContext.sharedInstance.getSharedAttribute("heartsCount") as? Int {
            self.barButtonItems.changeHeartCount(heartsCount)
        } else {
            self.barButtonItems.changeHeartCount(0)
        }
    }

    func reload(with modelDict: [String: AnyObject]) {
//        let newMessage = SSChatViewModel(modelDict: modelDict)
        
        self.loadData()
    }

    @IBAction func switchView(_ sender: AnyObject) {
        var originX: CGFloat = 0.0
        var buttonTitle: String = kMapButtonTitle
        if let segmentControl = self.navigationItem.titleView as? UISegmentedControl, segmentControl.selectedSegmentIndex == 1 {
            originX = CGFloatWithScreenRatio(175-97, axis: Axis.x, criteria: .iPhone6Plus)
            buttonTitle = kListButtonTitle

            self.segButton1.isSelected = false
            self.segButton2.isSelected = true
        } else {
            originX = 0

            self.segButton1.isSelected = true
            self.segButton2.isSelected = false
        }

        self.lbButtonTitle.text = buttonTitle

        UIView.animate(withDuration: 0.3,
                                   delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0.5,
                                   options: .curveEaseOut,
                                   animations: {
                                    self.buttonBackgroundView.frame.origin.x = originX
        }) { (finish) in

            self.mapView.isHidden = !self.segButton1.isSelected
            self.listView.isHidden = !self.segButton2.isSelected

            let mapVC: MapViewController = self.childViewControllers[0] as! MapViewController
            let listVC: ListViewController = self.childViewControllers[1] as! ListViewController
            if !self.listView.isHidden {
                let nowLocation: CLLocationCoordinate2D = mapVC.currentLocation != nil ? mapVC.currentLocation : mapVC.mainView.camera.target
                listVC.mainViewModel = SSMainViewModel(datas: mapVC.datasOfAllSsom, isSell: (mapVC.filterModel?.ssomType)! == [.SSOM], nowLatitude: nowLocation.latitude, nowLongitude: nowLocation.longitude)
                listVC.filterModel = mapVC.filterModel
                listVC.initView()
            } else {
                mapVC.filterModel = listVC.filterModel
                mapVC.initView()
            }
        }
    }

    func tapMenu() {
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.drawerController?.setMainState(.open, inDirection: .Left, animated: true, allowUserInterruption: true, completion: nil)
        }
    }

    func tapHeart() {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveLinear, animations: { 
            self.barButtonItems.imgViewHeart.transform = CGAffineTransform.identity
            }) { (finish) in
                if SSAccountManager.sharedInstance.isAuthorized {

                    let storyboard = UIStoryboard(name: "Menu", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "HeartNaviController")
                    if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController {
                        presentedViewController.present(vc, animated: true, completion: nil)
                    }

                } else {
                    SSAccountManager.sharedInstance.openSignIn(self, completion: { (finish) in
                        if finish {
                            let storyboard = UIStoryboard(name: "Menu", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "HeartNaviController")
                            if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController {
                                if presentedViewController is SSDrawerViewController {
                                    (presentedViewController as! SSDrawerViewController).mainViewController?.present(vc, animated: true, completion: nil)
                                } else {
                                    presentedViewController.present(vc, animated: true, completion: nil)
                                }
                            }
                        }
                    })
                }
        }
    }

    func tapChat() {
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveLinear, animations: { 
            self.barButtonItems.imgViewMessage.transform = CGAffineTransform.identity
        }) { (finish) in
            if SSAccountManager.sharedInstance.isAuthorized {

                let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
                let vc = chatStoryboard.instantiateViewController(withIdentifier: "chatListViewController") as! SSChatListViewController

                self.navigationController?.pushViewController(vc, animated: true)

            } else {
                SSAccountManager.sharedInstance.openSignIn(self, completion: { (finish) in
                    if finish {
                        let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
                        let vc = chatStoryboard.instantiateViewController(withIdentifier: "chatListViewController") as! SSChatListViewController

                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
    }

    // MARK: - UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0, 1:
            self.mapView.isHidden = item.tag != 0
            self.listView.isHidden = item.tag != 1

            let mapVC: MapViewController = self.childViewControllers[0] as! MapViewController
            let listVC: ListViewController = self.childViewControllers[1] as! ListViewController
            if !self.listView.isHidden {
                let nowLocation: CLLocationCoordinate2D = mapVC.currentLocation != nil ? mapVC.currentLocation : mapVC.mainView.camera.target
                listVC.mainViewModel = SSMainViewModel(datas: mapVC.datasOfAllSsom, isSell: (mapVC.filterModel?.ssomType)! == [.SSOM], nowLatitude: nowLocation.latitude, nowLongitude: nowLocation.longitude)
                listVC.filterModel = mapVC.filterModel
                listVC.initView()
            } else {
                mapVC.filterModel = listVC.filterModel
                mapVC.initView()
            }
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }
}
