//
//  SSChatListViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 23..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import CoreLocation

class SSChatListViewController : SSDetailViewController, UITableViewDelegate, UITableViewDataSource, SSChatListTableCellDelegate, CLLocationManagerDelegate, SSPhotoViewDelegate {

    var locationManager: CLLocationManager!
    var nowLocationCoordinate2D: CLLocationCoordinate2D!

    var profileImageView: SSPhotoView?

    @IBOutlet var chatListTableView: UITableView!

    var barButtonItems: SSNavigationBarItems!

    var datas: [SSChatroomViewModel] = [SSChatroomViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.setNavigationBarView()

        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setNavigationBarView() {

        self.barButtonItems = SSNavigationBarItems()

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), forControlEvents: UIControlEvents.TouchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = ""

        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        let naviTitleView: UILabel = UILabel(frame: CGRectMake(0, 0, 200, 44))
        if #available(iOS 8.2, *) {
            naviTitleView.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            naviTitleView.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        }
        naviTitleView.textAlignment = .Center
        naviTitleView.text = "Chat list"
        naviTitleView.sizeToFit()
        self.navigationItem.titleView = naviTitleView;

        var rightBarButtonItems: Array = self.navigationItem.rightBarButtonItems!

        let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        barButtonSpacer.width = 20

        barButtonItems.btnMessageBar.addTarget(rightBarButtonItems[0].target, action: rightBarButtonItems[0].action, forControlEvents: UIControlEvents.TouchUpInside)
        let messageBarButton = UIBarButtonItem(customView: barButtonItems.messageBarButtonView!)

        self.navigationItem.rightBarButtonItems = [messageBarButton]
    }

    func initView() {
        self.chatListTableView.registerNib(UINib(nibName: "SSChatListTableCell", bundle: nil), forCellReuseIdentifier: "chatListCell")

        self.edgesForExtendedLayout = UIRectEdge.None

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.startUpdatingLocation()
        }
    }

    func tapBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func loadData() {
        if let token: String = SSNetworkContext.sharedInstance.getSharedAttribute("token") as? String {
            SSNetworkAPIClient.getChatroomList(token, completion: { (models, error) in
                if error != nil {
                    print(error?.localizedDescription)

                    SSAlertController.alertConfirm(title: "Error", message: (error?.localizedDescription)!, vc: self, completion: nil)

                } else {
                    if let datas = models {

                        self.datas = datas

                        self.chatListTableView.reloadData()
                    }
                }
            })
        }
    }

// MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell: SSChatListTableCell = tableView.dequeueReusableCellWithIdentifier("chatListCell", forIndexPath: indexPath) as? SSChatListTableCell {
            cell.delegate = self
            cell.configView(self.datas[indexPath.row], withCoordinate: self.nowLocationCoordinate2D)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("chatListCell") as? SSChatListTableCell
            cell!.delegate = self
            cell!.configView(self.datas[indexPath.row], withCoordinate: self.nowLocationCoordinate2D)

            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let cell: SSChatListTableCell = tableView.cellForRowAtIndexPath(indexPath) as? SSChatListTableCell {
            if cell.isCellOpened {
                cell.closeCell(true)
            } else {
                if cell.isCellClosed {
                    let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
                    let vc = chatStoryboard.instantiateViewControllerWithIdentifier("chatViewController") as! SSChatViewController
                    if let model: SSChatroomViewModel = self.datas[indexPath.row] {
                        vc.chatRoomId = model.chatroomId
                        vc.ssomType = model.ssomViewModel.ssomType
                        vc.partnerImageUrl = model.ssomViewModel.imageUrl
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

// MARK: - SSChatListTableCellDelegate
    func deleteCell(cell: UITableViewCell) {
        if let indexPath: NSIndexPath = self.chatListTableView.indexPathForCell(cell) {
            self.datas.removeAtIndex(indexPath.row)
            self.chatListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

// MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.nowLocationCoordinate2D = locations.last!.coordinate

        self.locationManager.stopUpdatingLocation()

        self.loadData()
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.locationManager.stopUpdatingLocation()
        print(error)

        self.nowLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)

        self.loadData()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false

        switch status {
        case CLAuthorizationStatus.Restricted:
            print("Restricted Access to location!!")
        case .Denied:
            print("User denied access to location!!")
        case .NotDetermined:
            print("Status not determined!!")
            self.locationManager.requestWhenInUseAuthorization()
        default:
            print("Allowed to location access!!")
            shouldIAllow = true
        }

        if (shouldIAllow == true) {
            self.locationManager.startUpdatingLocation()
        }
    }

// MARK:- SSChatListTableCellDelegate
    func tapProfileImage(imageUrl: String) {
        self.navigationController?.navigationBarHidden = true;

        self.profileImageView = UIView.loadFromNibNamed("SSPhotoView") as? SSPhotoView
        self.profileImageView!.loadingImage(self.view.bounds, imageUrl: imageUrl)
        self.profileImageView!.delegate = self

        self.view.addSubview(self.profileImageView!)
    }

// MARK:- SSPhotoViewDelegate
    func tapClose() {
        self.navigationController?.navigationBarHidden = false;

        self.profileImageView!.removeFromSuperview()
    }
}
