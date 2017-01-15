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

    var unreadCount: Int {
        var count: Int = 0
        for data: SSChatroomViewModel in datas {
            count = count + data.unreadCount
        }

        return count
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.setNavigationBarView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.initView()
    }

    func setNavigationBarView() {

        self.barButtonItems = SSNavigationBarItems()

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), for: UIControlEvents.touchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = ""
        var backButtonFrame = self.barButtonItems.backBarButtonView.frame
        backButtonFrame.size.width = 60
        self.barButtonItems.backBarButtonView.frame = backButtonFrame

        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

        let naviTitleView: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        if #available(iOS 8.2, *) {
            naviTitleView.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 18) {
                naviTitleView.font = font
            }
        }
        naviTitleView.textAlignment = .center
        naviTitleView.text = "Chat list"
        naviTitleView.sizeToFit()
        self.navigationItem.titleView = naviTitleView;

        var rightBarButtonItems: Array = self.navigationItem.rightBarButtonItems!

        let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        barButtonSpacer.width = 20

        self.barButtonItems.btnMessageBar.addTarget(rightBarButtonItems[0].target, action: rightBarButtonItems[0].action!, for: UIControlEvents.touchUpInside)
        let messageBarButton = UIBarButtonItem(customView: barButtonItems.messageBarButtonView!)

        self.navigationItem.rightBarButtonItems = [messageBarButton]

        self.setChattingCount(0)
    }

    func setChattingCount(_ count: Int) {
        self.barButtonItems.changeMessageCount(count, hiddenIfZero: true)
    }

    override func initView() {
        self.chatListTableView.register(UINib(nibName: "SSChatListTableCell", bundle: nil), forCellReuseIdentifier: "chatListCell")

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.startUpdatingLocation()
        }
    }

    func tapBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func loadData() {
        if let token: String = SSNetworkContext.sharedInstance.getSharedAttribute("token") as? String {
            SSNetworkAPIClient.getChatroomList(token, latitude: self.nowLocationCoordinate2D.latitude, longitude: self.nowLocationCoordinate2D.longitude, completion: { [weak self] (models, error) in
                guard let wself = self else { return }

                if let err = error {
                    print(err.localizedDescription)

                    SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: nil)

                } else {
                    if let datas = models {

                        wself.datas = datas

                        if wself.datas.count > 0 {
                            wself.chatListTableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                        } else {
                            wself.chatListTableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                        }

                        wself.setChattingCount(wself.unreadCount)

                        wself.showChatroomCountOnNavigation()
                        wself.chatListTableView.reloadData()
                    }
                }
            })
        }
    }

    func reload(with modelDict: [String: AnyObject], needRecount: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let wself = self else { return }

            let newMessage = SSChatroomViewModel(modelDict: modelDict)

            for (index, var data) in wself.datas.enumerated() {
                if data.chatroomId == newMessage.chatroomId {
                    wself.datas.remove(at: index)

                    if needRecount {
                        data.unreadCount += 1
                    }
                    if newMessage.meetRequestStatus == .Received {
                        data.meetRequestUserId = newMessage.meetRequestUserId
                        data.meetRequestStatus = .Received
                    } else if newMessage.meetRequestStatus == .Cancelled {
                        data.lastMessage = SSMeetRequestOptions.Cancelled.rawValue
                        data.meetRequestStatus = .Cancelled
                    } else {
                        data.lastMessage = newMessage.lastMessage
                    }

                    wself.datas.insert(data, at: 0)

                    break
                }
            }
            
            wself.setChattingCount(wself.unreadCount)
            
            wself.chatListTableView.reloadData()
        }
    }

    func showChatroomCountOnNavigation() {
        if let naviTitleView = self.navigationItem.titleView as? UILabel {
            naviTitleView.text = "Chat list (\(self.datas.count))"
            naviTitleView.sizeToFit()
        }
    }

// MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SSChatListTableCell = tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath) as! SSChatListTableCell
        cell.delegate = self
        cell.configView(self.datas[indexPath.row], withCoordinate: self.nowLocationCoordinate2D)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let cell: SSChatListTableCell = tableView.cellForRow(at: indexPath) as? SSChatListTableCell {
            if cell.isCellOpened {
                cell.closeCell(true)
            } else {
                if cell.isCellClosed {
                    let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
                    let vc = chatStoryboard.instantiateViewController(withIdentifier: "chatViewController") as! SSChatViewController

                    let model = self.datas[indexPath.row]
                    vc.chatRoomId = model.chatroomId
                    vc.ssomType = model.ssomViewModel.ssomType
                    vc.postId = model.ssomViewModel.postId
                    vc.ageArea = Util.getAgeArea(model.ssomViewModel.minAge)
                    if let userCount = model.ssomViewModel.userCount {
                        vc.peopleCount = SSPeopleCountType(rawValue: userCount)!.toSting()
                    }

                    if cell.isOwnerUser {
                        vc.myImageUrl = model.ownerImageUrl
                        vc.partnerImageUrl = model.participantImageUrl
                    } else {
                        vc.myImageUrl = model.participantImageUrl
                        vc.partnerImageUrl = model.ownerImageUrl
                    }

                    vc.ssomLatitude = model.ssomViewModel.latitude
                    vc.ssomLongitude = model.ssomViewModel.longitude

                    if let requestUserId = model.meetRequestUserId {
                        vc.meetRequestUserId = requestUserId
                    }
                    vc.meetRequestStatus = model.meetRequestStatus

                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

// MARK: - SSChatListTableCellDelegate
    func deleteCell(_ cell: SSChatListTableCell) {
        if let token = SSAccountManager.sharedInstance.sessionToken {
            if let model: SSChatroomViewModel = cell.model {
                SSNetworkAPIClient.deleteChatroom(token, chatroomId: model.chatroomId, completion: { (data, error) in
                    if let err = error {
                        SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: { (action) in
                            //
                        })
                    }
                })
                if let indexPath: IndexPath = self.chatListTableView.indexPath(for: cell) {
                    self.datas.remove(at: indexPath.row)
                    self.chatListTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    self.showChatroomCountOnNavigation()
                }
            }
        }
    }

// MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.nowLocationCoordinate2D = locations.last!.coordinate

        self.locationManager.stopUpdatingLocation()

        self.loadData()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        print(error)

        self.nowLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)

        self.loadData()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false

        switch status {
        case CLAuthorizationStatus.restricted:
            print("Restricted Access to location!!")
        case .denied:
            print("User denied access to location!!")
        case .notDetermined:
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
    func tapProfileImage(_ imageUrl: String) {
        self.navigationController?.isNavigationBarHidden = true;

        self.profileImageView = UIView.loadFromNibNamed("SSPhotoView") as? SSPhotoView
        self.profileImageView!.loadingImage(self.view.bounds, imageUrl: imageUrl)
        self.profileImageView!.delegate = self

        self.view.addSubview(self.profileImageView!)
    }

// MARK:- SSPhotoViewDelegate
    func tapPhotoViewClose() {
        self.navigationController?.isNavigationBarHidden = false;

        self.profileImageView!.removeFromSuperview()
    }
}
