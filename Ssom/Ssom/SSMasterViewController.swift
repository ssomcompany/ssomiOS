//
//  SSMasterViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 4..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import GoogleMaps

class SSMasterViewController: UIViewController {

    var barButtonItems: SSNavigationBarItems!
    var segButton1: UIButton!
    var segButton2: UIButton!

    @IBOutlet var mapView: UIView!
    @IBOutlet var listView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.setNavigationBarView()
    }

    func setNavigationBarView() {
        var naviTitleViewFrame:CGRect = self.navigationItem.titleView!.frame
        naviTitleViewFrame = CGRectMake(naviTitleViewFrame.origin.x, naviTitleViewFrame.origin.y
            , naviTitleViewFrame.size.width, 38)
        self.navigationItem.titleView!.frame = naviTitleViewFrame

        let titleBackgroundView: UIImageView = UIImageView(image: UIImage(named: "1DepToggleOn.png"))
        titleBackgroundView.frame = CGRectMake(0, 0, 175, 38)
        self.navigationItem.titleView!.addSubview(titleBackgroundView)

        self.segButton1 = UIButton(frame: CGRectMake(0, 0, 97, 38))
        self.segButton1.setTitle("MAP", forState: .Normal)
        self.segButton1.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1), forState: .Normal)
        self.segButton1.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.segButton1.setBackgroundImage(UIImage(named: "1DepToggleOff.png"), forState: .Selected)
        self.segButton1.selected = true
        self.navigationItem.titleView!.addSubview(self.segButton1)

        self.segButton2 = UIButton(frame: CGRectMake(CGFloat(175-97), 0, 97, 38))
        self.segButton2.setTitle("LIST", forState: .Normal)
        self.segButton2.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1), forState: .Normal)
        self.segButton2.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.segButton2.setBackgroundImage(UIImage(named: "1DepToggleOff.png"), forState: .Selected)
        self.segButton2.selected = false
        self.navigationItem.titleView!.addSubview(self.segButton2)

        if #available(iOS 8.2, *) {
            self.segButton1.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
            self.segButton2.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            self.segButton1.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
            self.segButton2.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        }

        let leftBarButtonItem: UIBarButtonItem = self.navigationItem.leftBarButtonItem!
        leftBarButtonItem.title = ""
        leftBarButtonItem.image = UIImage.resizeImage(UIImage(named: "manu.png")!, frame: CGRectMake(0, 0, 21, 14))
        leftBarButtonItem.target = self
        leftBarButtonItem.action = #selector(tapMenu)

        var rightBarButtonItems: Array = self.navigationItem.rightBarButtonItems!
        if rightBarButtonItems.count == 2 {
            self.barButtonItems = SSNavigationBarItems()

            let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            barButtonSpacer.width = 20

            barButtonItems.btnHeartBar.addTarget(rightBarButtonItems[1].target, action: rightBarButtonItems[1].action, forControlEvents: UIControlEvents.TouchUpInside)
            let heartBarButton = UIBarButtonItem(customView: barButtonItems.heartBarButtonView!)

            barButtonItems.btnMessageBar.addTarget(self, action: #selector(tapChat), forControlEvents: UIControlEvents.TouchUpInside)
            let messageBarButton = UIBarButtonItem(customView: barButtonItems.messageBarButtonView!)

            self.navigationItem.rightBarButtonItems = [messageBarButton, barButtonSpacer, heartBarButton]
        }
    }

    @IBAction func switchView(sender: AnyObject) {
        self.segButton1.selected = !self.segButton1.selected
        self.segButton2.selected = !self.segButton2.selected

        self.mapView.hidden = !self.segButton1.selected
        self.listView.hidden = !self.segButton2.selected

        if !self.listView.hidden {
            let mapVC: MapViewController = self.childViewControllers[0] as! MapViewController
            let listVC: ListViewController = self.childViewControllers[1] as! ListViewController

            let nowLocation: CLLocationCoordinate2D = mapVC.mainView.camera.target
            listVC.mainViewModel = SSMainViewModel(datas: mapVC.datas, isSell: mapVC.btnIPay.selected, nowLatitude: nowLocation.latitude, nowLongitude: nowLocation.longitude)
            listVC.initView()
        }
    }

    func tapMenu() {
        if let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.drawerController?.setMainState(.Open, inDirection: .Left, animated: true, allowUserInterruption: true, completion: nil)
        }
    }

    func tapChat() {
        let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
        let vc = chatStoryboard.instantiateViewControllerWithIdentifier("chatListViewController") as! SSChatListViewController

        self.navigationController?.pushViewController(vc, animated: true)
    }
}