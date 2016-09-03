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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        self.setNavigationBarView()
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
            self.segButton1.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
            self.segButton2.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)

            self.lbButtonTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
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

    @IBAction func switchView(sender: AnyObject) {
        var originX: CGFloat = 0.0
        var buttonTitle: String = kMapButtonTitle
        if self.buttonBackgroundView.frame.origin.x == 0 {
            originX = CGFloatWithScreenRatio(175-97, axis: Axis.X, criteria: .IPhone6Plus)
            buttonTitle = kListButtonTitle
        } else {
            originX = 0
        }

        self.lbButtonTitle.text = buttonTitle

        self.segButton1.selected = !self.segButton1.selected
        self.segButton2.selected = !self.segButton2.selected

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

            if !self.listView.hidden {
                let mapVC: MapViewController = self.childViewControllers[0] as! MapViewController
                let listVC: ListViewController = self.childViewControllers[1] as! ListViewController

                let nowLocation: CLLocationCoordinate2D = mapVC.currentLocation
                listVC.mainViewModel = SSMainViewModel(datas: mapVC.datasOfAllSsom, isSell: mapVC.btnIPay.selected, nowLatitude: nowLocation.latitude, nowLongitude: nowLocation.longitude)
                listVC.initView()
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
                //
        }
    }

    func tapChat() {
        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveLinear, animations: { 
            self.barButtonItems.imgViewMessage.transform = CGAffineTransformIdentity
        }) { (finish) in
            let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
            let vc = chatStoryboard.instantiateViewControllerWithIdentifier("chatListViewController") as! SSChatListViewController

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}