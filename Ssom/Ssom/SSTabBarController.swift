//
//  SSTabBarController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2017. 1. 3..
//  Copyright © 2017년 SsomCompany. All rights reserved.
//

import UIKit
import CoreLocation

enum SSTabBarMode {
    case basic
    case noFilter
    case chatList
}

class SSTabBarController: UITabBarController, UITabBarControllerDelegate {

    var barButtonItems: SSNavigationBarItems!

    var imgViewSsomIcon: UIImageView!
    var lbTitle: UILabel!

    var unreadCount: Int = 0 {
        didSet {
            if let barItems = self.tabBar.items, let barItemForChat = barItems.last {
                print("bar item is : \(barItemForChat)")

                let barButtons = self.tabBar.subviews
                if barButtons.last != nil {
                    if self.unreadCount > 0 {
                        if #available(iOS 10.0, *) {
                            barItemForChat.badgeColor = #colorLiteral(red: 0.9294117647, green: 0.2039215686, blue: 0.2941176471, alpha: 1)
                        }
                        barItemForChat.badgeValue = "\(self.unreadCount)"
                    } else {
                        barItemForChat.badgeValue = nil
                    }
                }
            }
        }
    }

    var mainViewModel: SSMainViewModel!
    var filterModel: SSFilterViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        self.delegate = self

        self.setNavigationBarView()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: SSInternalNotification.PurchasedHeart.rawValue), object: nil, queue: nil) { [weak self] (notification) in

            guard let wself = self else { return }

            if let userInfo = notification.userInfo {
                if let heartsCount = userInfo["heartsCount"] as? Int {
                    wself.barButtonItems.changeHeartCount(heartsCount)
                }
            }
        }

        let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
        let heartVC = menuStoryboard.instantiateViewController(withIdentifier: "HeartViewController")
        self.addChildViewController(heartVC)

        if let tabBarItem = heartVC.tabBarItem {
            tabBarItem.image = #imageLiteral(resourceName: "footIconHeartOff")
            tabBarItem.selectedImage = #imageLiteral(resourceName: "footIconHeartOn")

            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }

        let chatStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
        let chatListVC = chatStoryboard.instantiateViewController(withIdentifier: "chatListViewController")
        self.addChildViewController(chatListVC)

        if let tabBarItem = chatListVC.tabBarItem {
            tabBarItem.image = #imageLiteral(resourceName: "footIconChatOff")
            tabBarItem.selectedImage = #imageLiteral(resourceName: "footIconChatOn")

            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setNavigationBarView(configMode: SSTabBarMode = .basic, userInfo: [String: Any]? = nil) {
        self.navigationItem.titleView = UIView(frame: CGRect(x: UIScreen.main.bounds.width / 2.0 - 50, y: 0, width: 100, height: 44))
        self.navigationItem.titleView?.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleWidth, .flexibleHeight]
        self.navigationItem.titleView?.clipsToBounds = false

        let leftBarButtonItem: UIBarButtonItem = self.navigationItem.leftBarButtonItem!
        leftBarButtonItem.title = ""
        leftBarButtonItem.image = UIImage.resizeImage(UIImage(named: "manu")!, frame: CGRect(x: 0, y: 0, width: 21, height: 14))
        leftBarButtonItem.target = self
        leftBarButtonItem.action = #selector(tapMenu)

        let configTitleForUserCount: () -> Void = {
            if let _lbTitle = self.lbTitle, let _ = _lbTitle.superview {
                self.lbTitle.removeFromSuperview()
            }
            
            self.imgViewSsomIcon = UIImageView(image: #imageLiteral(resourceName: "iconSsomMapMini"))
            self.navigationItem.titleView!.addSubview(self.imgViewSsomIcon)
            self.imgViewSsomIcon.translatesAutoresizingMaskIntoConstraints = false

            self.lbTitle = UILabel()
            self.lbTitle.text = "현재 5,021명 접속 중"
            self.lbTitle.textColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
            self.navigationItem.titleView!.addSubview(self.lbTitle)
            self.lbTitle.translatesAutoresizingMaskIntoConstraints = false

            self.navigationItem.titleView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[icon]-5-[title]", options: .alignAllCenterY, metrics: nil, views: ["icon" : self.imgViewSsomIcon, "title": self.lbTitle]))
            self.navigationItem.titleView!.addConstraint(NSLayoutConstraint(item: self.navigationItem.titleView!, attribute: .centerY, relatedBy: .equal, toItem: self.lbTitle, attribute: .centerY, multiplier: 1, constant: 0))
            self.navigationItem.titleView!.addConstraint(NSLayoutConstraint(item: self.navigationItem.titleView!, attribute: .centerX, relatedBy: .equal, toItem: self.lbTitle, attribute: .centerX, multiplier: 1, constant: -(#imageLiteral(resourceName: "iconSsomMapMini").size.width / 2.0)))

            if #available(iOS 8.2, *) {
                self.lbTitle.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
                if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 13) {
                    self.lbTitle.font = font
                }
            }
        }

        let configTitleForChatList: () -> Void = {
            if let _lbTitle = self.lbTitle, let _ = _lbTitle.superview {
                self.lbTitle.removeFromSuperview()
            }

            self.lbTitle = UILabel()
            self.lbTitle.text = "Chat list"
            if let _userInfo = userInfo, let chatListCount = _userInfo["count"] {
                self.lbTitle.text = "Chat list (\(chatListCount))"
            }
            self.lbTitle.textColor = UIColor(red: 77.0/255.0, green: 77.0/255.0, blue: 77.0/255.0, alpha: 1.0)
            self.navigationItem.titleView!.addSubview(self.lbTitle)
            self.lbTitle.translatesAutoresizingMaskIntoConstraints = false

            self.navigationItem.titleView!.addConstraint(NSLayoutConstraint(item: self.navigationItem.titleView!, attribute: .centerX, relatedBy: .equal, toItem: self.lbTitle, attribute: .centerX, multiplier: 1, constant: 0))
            self.navigationItem.titleView!.addConstraint(NSLayoutConstraint(item: self.navigationItem.titleView!, attribute: .centerY, relatedBy: .equal, toItem: self.lbTitle, attribute: .centerY, multiplier: 1, constant: 0))

            if #available(iOS 8.2, *) {
                self.lbTitle.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
                if let font = UIFont.init(name: "HelveticaNeue-Medium", size: 16) {
                    self.lbTitle.font = font
                }
            }
        }

        let configFilterButton: () -> Void = {
            let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            barButtonSpacer.width = -4

            self.barButtonItems = SSNavigationBarItems(animated: true)

            self.barButtonItems.btnFilterBar.addTarget(self, action: #selector(self.tapFilter), for: UIControlEvents.touchUpInside)
            let btnFilterBar = UIBarButtonItem(customView: self.barButtonItems.filterBarButtonView!)

            self.navigationItem.rightBarButtonItems = [barButtonSpacer, btnFilterBar]

            if let filterModel = self.filterModel {
                self.barButtonItems.changeFilter(ssomTypes: filterModel.ssomType)
            }
        }

        let removeFilterButton: () -> Void = {
            self.navigationItem.rightBarButtonItems = nil
        }

        switch configMode {
        case .basic:
            configTitleForUserCount()
            configFilterButton()
        case .noFilter:
            configTitleForUserCount()
            removeFilterButton()
        case .chatList:
            configTitleForChatList()
            removeFilterButton()
        }
    }

    func loadData() {
        SSNetworkAPIClient.getConnectedUsersCount { [weak self] (count, error) in
            guard let wself = self else { return }

            if let err = error {
                print("error is : \(err.localizedDescription)")

                SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: nil)
            } else {
                if let viewController = wself.selectedViewController, viewController is SSChatListViewController {

                } else {
                    wself.lbTitle.text = "현재 \(count)명 접속 중"
                }
            }
        }

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

            SSNetworkAPIClient.getHearts(token, completion: { (heartsCount, error) in
                if let err = error {
                    print(err.localizedDescription)

                    // heart count
                    if let heartsCount = SSNetworkContext.sharedInstance.getSharedAttribute("heartsCount") as? Int {
                        self.barButtonItems.changeHeartCount(heartsCount)
                    } else {
                        self.barButtonItems.changeHeartCount(2)
                    }
                } else {
                    self.barButtonItems.changeHeartCount(heartsCount)
                }
            })
        }
    }

    func tapMenu() {
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.drawerController?.setMainState(.open, inDirection: .Left, animated: true, allowUserInterruption: true, completion: nil)
        }
    }

    func tapFilter() {
        if let vc = self.selectedViewController as? MapViewController {
            vc.tapFilter()
        } else if let vc = self.selectedViewController as? ListViewController {
            vc.tapFilterButton()
        }
    }

    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is SSChatListViewController {
            let chatListCount = (viewController as! SSChatListViewController).datas.count
            self.setNavigationBarView(configMode: .chatList, userInfo: ["count": chatListCount])
        } else if viewController is MapViewController || viewController is ListViewController {
            self.setNavigationBarView()
        } else if viewController is SSHeartViewController {
            self.setNavigationBarView(configMode: .noFilter)
        }

        self.loadData()
    }
}
