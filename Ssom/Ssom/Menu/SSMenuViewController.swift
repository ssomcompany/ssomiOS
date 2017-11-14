//
//  SSMenuViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSMenuViewController: UIViewController, Reloadable, SSMenuHeadViewDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var menuTableView: UITableView!

    weak var drawerViewController: SSDrawerViewController?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    func initView() {

        self.menuTableView.register(UINib(nibName: "SSMenuHeadView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MenuHeader")
        self.menuTableView.register(UINib(nibName: "SSMenuBottomView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MenuFooter")
        self.menuTableView.register(UINib(nibName: "SSMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuCell")

        self.edgesForExtendedLayout = UIRectEdge()
    }

    func transitionToViewController() -> Void {
        let animateTransition: Bool = self.drawerViewController?.mainViewController != nil

        let mainNavigationController: UINavigationController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MasterNavigationController") as? UINavigationController)!

        self.drawerViewController?.setMainViewController(mainNavigationController, animated: animateTransition, completion: nil)
    }

// MARK: - UITableViweDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height * (56.0 / 736.0)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height * (56.0 / 736.0)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UIScreen.main.bounds.size.height * (366.0 / 736.0)
    }

//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
//        return UIScreen.mainScreen().bounds.size.height * (69.0 / 736.0)
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell: SSMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? SSMenuTableViewCell {
            cell.configCell(SSMenuType(rawValue: indexPath.row)!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as? SSMenuTableViewCell

            return cell!
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: SSMenuHeadView = SSMenuHeadView(reuseIdentifier: "MenuHeader")
        view.delegate = self

        view.blockLogin = { [weak self] (finish) in
            guard let wself = self else { return }
            wself.menuTableView.reloadData()

            (wself.drawerViewController?.mainViewController as? Reloadable)?.needToReload = finish
        }
        
        view.blockLogout = { [weak self] (finish) in
            guard let wself = self else { return }
            SSAccountManager.sharedInstance.doSignOut(wself, completion: { (finish) in
                wself.menuTableView.reloadData()

                (wself.drawerViewController?.mainViewController as? Reloadable)?.needToReload = finish


            })
        }

        view.configView()

//        if let view: SSMenuHeadView = (tableView.dequeueReusableHeaderFooterViewWithIdentifier("MenuHeader") as? SSMenuHeadView) {
//            view.delegate = self
//            view.configView()
//            return view
//        }

        return view
    }

//    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if SSAccountManager.sharedInstance.isAuthorized {
//            let view: SSMenuBottomView = SSMenuBottomView(reuseIdentifier: "MenuFooter")
//
//            view.blockLogout = { [weak self] (finish) in
//                if let wself = self {
//                    SSAccountManager.sharedInstance.doSignOut(wself, completion: { (finish) in
//                        wself.tableView.reloadData()
//
//                        wself.drawerViewController?.mainViewController?.needToReload = finish
//                    })
//                }
//            }
//
//            view.configView()
//
//            return view
//        } else {
//            let view = UIView()
//            view.backgroundColor = UIColor.whiteColor()
//
//            return view
//        }
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath) as? SSMenuTableViewCell {
            if let url = cell.menuType.url {
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.openURL(url as URL)
                }
            } else if cell.menuType == .withdraw {
                SSAlertController.alertConfirm(title: "알림", message: "쏨 서비스에 가입된 메일로\n탈퇴신청 메일을 아래 주소로 보내주세요.\nssomcompany@gmail.com", vc: self, completion: nil)
            }
        }
    }

// MARK: - SSMenuHeadViewDelegate
    func openSignIn(_ completion: ((_ finish: Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: completion)
    }

    func showProfilePhoto() {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TodayPhotoNaviController") as? UINavigationController
        if let topViewController = vc?.topViewController as? SSTodayPhotoViewController {
            topViewController.photoSaveCompletion = { [weak self] in
                if let wself = self {
                    if let headerView = wself.menuTableView.headerView(forSection: 0) as? SSMenuHeadView {
                        headerView.showProfileImage()
                    }
                }
            }
        }

        self.present(vc!, animated: true, completion: nil)
    }
}
