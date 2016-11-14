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

class SSMasterViewController: UIViewController {

    var barButtonItems: SSNavigationBarItems!
    var segButton1: UIButton!
    var segButton2: UIButton!

    @IBOutlet var mapView: UIView!
    @IBOutlet var listView: UIView!

    var buttonBackgroundView: UIImageView!
    var lbButtonTitle: UILabel!

    var unreadCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        self.setNavigationBarView()

        NSNotificationCenter.defaultCenter().addObserverForName(SSInternalNotification.PurchasedHeart.rawValue, object: nil, queue: nil) { [weak self] (notification) in

            guard let wself = self else { return }

            if let userInfo = notification.userInfo {
                if let heartsCount = userInfo["heartsCount"] as? Int {
                    wself.barButtonItems.changeHeartCount(heartsCount)
                }
            }
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func setNavigationBarView() {
        var naviTitleViewFrame:CGRect = self.navigationItem.titleView!.frame
        naviTitleViewFrame = CGRectMake(naviTitleViewFrame.origin.x, naviTitleViewFrame.origin.y
            , naviTitleViewFrame.size.width, CGFloatWithScreenRatio(38, axis: Axis.Y, criteria: .IPhone6Plus))
        self.navigationItem.titleView!.frame = naviTitleViewFrame

        let titleBackgroundView: UIImageView = UIImageView(image: UIImage(named: "1DepToggleOn.png"))
        titleBackgroundView.frame = CGRectMakeWithScreenRatio(0, 0, 175, 38, criteria: .IPhone6Plus)
        self.navigationItem.titleView!.addSubview(titleBackgroundView)

        self.buttonBackgroundView = UIImageView(image: UIImage(named: "1DepToggleOff.png"))
        self.buttonBackgroundView.frame = CGRectMakeWithScreenRatio(0, 0, 97, 38, criteria: .IPhone6Plus)
        self.navigationItem.titleView!.addSubview(self.buttonBackgroundView)

        self.lbButtonTitle = UILabel()
        self.lbButtonTitle.text = kMapButtonTitle
        self.lbButtonTitle.textColor = UIColor.whiteColor()
        self.buttonBackgroundView.addSubview(self.lbButtonTitle)

        self.lbButtonTitle.translatesAutoresizingMaskIntoConstraints = false
        self.buttonBackgroundView.addConstraint(NSLayoutConstraint(item: self.buttonBackgroundView, attribute: .CenterX, relatedBy: .Equal, toItem: self.lbButtonTitle, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        self.buttonBackgroundView.addConstraint(NSLayoutConstraint(item: self.buttonBackgroundView, attribute: .CenterY, relatedBy: .Equal, toItem: self.lbButtonTitle, attribute: .CenterY, multiplier: 1.0, constant: 0.0))

        self.segButton1 = UIButton(frame: CGRectMakeWithScreenRatio(0, 0, 97, 38, criteria: .IPhone6Plus))
        self.segButton1.setTitle(kMapButtonTitle, forState: .Normal)
        self.segButton1.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1), forState: .Normal)
        self.segButton1.setTitleColor(UIColor.clearColor(), forState: .Selected)
//        self.segButton1.setTitleColor(UIColor.whiteColor(), forState: .Selected)
//        self.segButton1.setBackgroundImage(UIImage(named: "1DepToggleOff.png"), forState: .Selected)
        self.segButton1.selected = true
        self.navigationItem.titleView!.addSubview(self.segButton1)

        self.segButton2 = UIButton(frame: CGRectMakeWithScreenRatio(CGFloat(175-97), 0, 97, 38, criteria: .IPhone6Plus))
        self.segButton2.setTitle(kListButtonTitle, forState: .Normal)
        self.segButton2.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1), forState: .Normal)
        self.segButton2.setTitleColor(UIColor.clearColor(), forState: .Selected)
//        self.segButton2.setTitleColor(UIColor.whiteColor(), forState: .Selected)
//        self.segButton2.setBackgroundImage(UIImage(named: "1DepToggleOff.png"), forState: .Selected)
        self.segButton2.selected = false
        self.navigationItem.titleView!.addSubview(self.segButton2)

        if #available(iOS 8.2, *) {
            self.segButton1.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
            self.segButton2.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)

            self.lbButtonTitle.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
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
        leftBarButtonItem.image = UIImage.resizeImage(UIImage(named: "manu.png")!, frame: CGRectMake(0, 0, 21, 14))
        leftBarButtonItem.target = self
        leftBarButtonItem.action = #selector(tapMenu)

        let rightBarButtonItems: Array = self.navigationItem.rightBarButtonItems!
        if rightBarButtonItems.count == 2 {
            self.barButtonItems = SSNavigationBarItems(animated: true)

            let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            barButtonSpacer.width = 20

            self.barButtonItems.btnHeartBar.addTarget(self, action: #selector(tapHeart), forControlEvents: UIControlEvents.TouchUpInside)
            let heartBarButton = UIBarButtonItem(customView: barButtonItems.heartBarButtonView!)

            self.barButtonItems.btnMessageBar.addTarget(self, action: #selector(tapChat), forControlEvents: UIControlEvents.TouchUpInside)
            let messageBarButton = UIBarButtonItem(customView: barButtonItems.messageBarButtonView!)

            self.navigationItem.rightBarButtonItems = [messageBarButton, barButtonSpacer, heartBarButton]
        }
    }

    override func viewWillAppear(animated: Bool) {
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

    @IBAction func switchView(sender: AnyObject) {
        var originX: CGFloat = 0.0
        var buttonTitle: String = kMapButtonTitle
        if let segmentControl = self.navigationItem.titleView as? UISegmentedControl where segmentControl.selectedSegmentIndex == 1 {
            originX = CGFloatWithScreenRatio(175-97, axis: Axis.X, criteria: .IPhone6Plus)
            buttonTitle = kListButtonTitle

            self.segButton1.selected = false
            self.segButton2.selected = true
        } else {
            originX = 0

            self.segButton1.selected = true
            self.segButton2.selected = false
        }

        self.lbButtonTitle.text = buttonTitle

        UIView.animateWithDuration(0.3,
                                   delay: 0.0,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0.5,
                                   options: .CurveEaseOut,
                                   animations: {
                                    self.buttonBackgroundView.frame.origin.x = originX
        }) { (finish) in

            self.mapView.hidden = !self.segButton1.selected
            self.listView.hidden = !self.segButton2.selected

            let mapVC: MapViewController = self.childViewControllers[0] as! MapViewController
            let listVC: ListViewController = self.childViewControllers[1] as! ListViewController
            if !self.listView.hidden {
                let nowLocation: CLLocationCoordinate2D = mapVC.currentLocation != nil ? mapVC.currentLocation : mapVC.mainView.camera.target
                listVC.mainViewModel = SSMainViewModel(datas: mapVC.datasOfAllSsom, isSell: mapVC.btnIPay.selected, nowLatitude: nowLocation.latitude, nowLongitude: nowLocation.longitude)
                listVC.filterModel = mapVC.filterModel
                listVC.initView()
            } else {
                mapVC.filterModel = listVC.filterModel
                mapVC.initView()
            }
        }
    }

    func tapMenu() {
        if let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.drawerController?.setMainState(.Open, inDirection: .Left, animated: true, allowUserInterruption: true, completion: nil)
        }
    }

    func tapHeart() {
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveLinear, animations: { 
            self.barButtonItems.imgViewHeart.transform = CGAffineTransformIdentity
            }) { (finish) in
                if SSAccountManager.sharedInstance.isAuthorized {

                    let storyboard = UIStoryboard(name: "Menu", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("HeartNaviController")
                    if let presentedViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                        presentedViewController.presentViewController(vc, animated: true, completion: nil)
                    }

                } else {
                    SSAccountManager.sharedInstance.openSignIn(self, completion: { (finish) in
                        if finish {
                            let storyboard = UIStoryboard(name: "Menu", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("HeartNaviController")
                            if let presentedViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                                presentedViewController.presentViewController(vc, animated: true, completion: nil)
                            }
                        }
                    })
                }
        }
    }

    func tapChat() {
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveLinear, animations: { 
            self.barButtonItems.imgViewMessage.transform = CGAffineTransformIdentity
        }) { (finish) in
            if SSAccountManager.sharedInstance.isAuthorized {

                let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
                let vc = chatStoryboard.instantiateViewControllerWithIdentifier("chatListViewController") as! SSChatListViewController

                self.navigationController?.pushViewController(vc, animated: true)

            } else {
                SSAccountManager.sharedInstance.openSignIn(self, completion: { (finish) in
                    if finish {
                        let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
                        let vc = chatStoryboard.instantiateViewControllerWithIdentifier("chatListViewController") as! SSChatListViewController

                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
    }
}
