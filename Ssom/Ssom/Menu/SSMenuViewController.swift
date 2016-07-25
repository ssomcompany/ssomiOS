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

        self.menuTableView.registerNib(UINib(nibName: "SSMenuHeadView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MenuHeader")
        self.menuTableView.registerNib(UINib(nibName: "SSMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        self.menuTableView.rowHeight = UITableViewAutomaticDimension
        self.menuTableView.sectionHeaderHeight = UITableViewAutomaticDimension

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

    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height * (495 / 736)
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height * (56 / 736)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if let cell: SSMenuTableViewCell = (tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as? SSMenuTableViewCell)! {
            cell.configCell(SSMenuType(rawValue: indexPath.row)!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as? SSMenuTableViewCell

            return cell!
        }

    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let view: SSMenuHeadView = (tableView.dequeueReusableHeaderFooterViewWithIdentifier("MenuHeader") as? SSMenuHeadView) {
            view.delegate = self
            view.configView()
            return view
        }

        return nil
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

// MARK: - SSMenuHeadViewDelegate
    func callSignOut(completion: ((finish: Bool) -> Void)?) {
        SSAccountManager.sharedInstance.doSignOut(self, completion: completion)
    }

    func openSignIn(completion: ((finish: Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: completion)
    }
}
