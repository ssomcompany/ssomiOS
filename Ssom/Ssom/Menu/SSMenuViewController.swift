//
//  SSMenuViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 1..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSMenuViewController: UITableViewController, SSMenuHeadViewDelegate {
    @IBOutlet var menuTableView: UITableView!

    weak var drawerViewController: SSDrawerViewController?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    override func initView() {

        self.menuTableView.registerNib(UINib(nibName: "SSMenuHeadView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MenuHeader")
        self.menuTableView.registerNib(UINib(nibName: "SSMenuBottomView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MenuFooter")
        self.menuTableView.registerNib(UINib(nibName: "SSMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuCell")

        self.edgesForExtendedLayout = UIRectEdge.None
    }

    func transitionToViewController() -> Void {
        let animateTransition: Bool = self.drawerViewController?.mainViewController != nil

        let mainNavigationController: UINavigationController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MasterNavigationController") as? UINavigationController)!

        self.drawerViewController?.setMainViewController(mainNavigationController, animated: animateTransition, completion: nil)
    }

// MARK: - UITableViweDelegate & UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height * (56.0 / 736.0)
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height * (56.0 / 736.0)
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height * (456.0 / 736.0)
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height * (69.0 / 736.0)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if let cell: SSMenuTableViewCell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as? SSMenuTableViewCell {
            cell.configCell(SSMenuType(rawValue: indexPath.row)!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as? SSMenuTableViewCell

            return cell!
        }

    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: SSMenuHeadView = SSMenuHeadView(reuseIdentifier: "MenuHeader")
        view.delegate = self

        view.blockLogin = { [weak self] (finish) in
            guard let wself = self else { return }
            wself.tableView.reloadData()

            wself.drawerViewController?.mainViewController?.needToReload = finish
        }

        view.configView()

//        if let view: SSMenuHeadView = (tableView.dequeueReusableHeaderFooterViewWithIdentifier("MenuHeader") as? SSMenuHeadView) {
//            view.delegate = self
//            view.configView()
//            return view
//        }

        return view
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if SSAccountManager.sharedInstance.isAuthorized {
            let view: SSMenuBottomView = SSMenuBottomView(reuseIdentifier: "MenuFooter")

            view.blockLogout = { [weak self] (finish) in
                if let wself = self {
                    SSAccountManager.sharedInstance.doSignOut(wself, completion: { (finish) -> Void? in
                        wself.tableView.reloadData()

                        wself.drawerViewController?.mainViewController?.needToReload = finish
                    })
                }
            }

            view.configView()

            return view
        } else {
            let view = UIView()
            view.backgroundColor = UIColor.whiteColor()

            return view
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SSMenuTableViewCell {
            if let url = cell.menuType.url {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
    }

// MARK: - SSMenuHeadViewDelegate
    func openSignIn(completion: ((finish: Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: completion)
    }
}
