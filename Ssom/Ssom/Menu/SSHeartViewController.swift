//
//  SSHeartViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 10. 10..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

enum SSHeartGoods: Int {
    case heart2Package
    case heart8Package
    case heart17Package
    case heart28Package

    var heartCount: Int {
        switch self {
        case .heart2Package:
            return 2
        case .heart8Package:
            return 8
        case .heart17Package:
            return 17
        case .heart28Package:
            return 28
        }
    }

    var isEconomyPackage: Bool {
        switch self {
        case .heart8Package:
            return true
        default:
            return false
        }
    }

    var isHotPackage: Bool {
        switch  self {
        case .heart28Package:
            return true
        default:
            return false
        }
    }

    var tagIconImage: UIImage? {
        switch self {
        case .heart2Package:
            return nil
        case .heart8Package:
            return UIImage(named: "greenRibSmall")
        case .heart17Package:
            return nil
        case .heart28Package:
            return UIImage(named: "redRibSmall")
        }
    }

    var tagName: String? {
        switch self {
        case .heart2Package:
            return nil
        case .heart8Package:
            return "실속"
        case .heart17Package:
            return nil
        case .heart28Package:
            return "인기"
        }
    }

    var price: String {
        switch self {
        case .heart2Package:
            return "$ 3.99"
        case .heart8Package:
            return "$ 12.99"
        case .heart17Package:
            return "$ 23.99"
        case .heart28Package:
            return "$ 32.99"
        }
    }

    var sale: String? {
        switch self {
        case .heart2Package:
            return nil
        case .heart8Package:
            return "19%"
        case .heart17Package:
            return "29%"
        case .heart28Package:
            return "41%"
        }
    }

    var saleIconImage: UIImage? {
        switch self {
        case .heart2Package:
            return nil
        case .heart8Package:
            return UIImage(named: "saleGray")
        case .heart17Package:
            return UIImage(named: "saleGray")
        case .heart28Package:
            return UIImage(named: "salePink")
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .heart2Package:
            return UIImage(named: "heartShadowX2")!
        case .heart8Package:
            return UIImage(named: "heartShadowX8")!
        case .heart17Package:
            return UIImage(named: "heartX17")!
        case .heart28Package:
            return UIImage(named: "heartX28")!
        }
    }

    var boundaryColor: UIColor {
        switch self {
        case .heart2Package:
            return UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        case .heart8Package:
            return UIColor(red: 0.0/255.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1.0)
        case .heart17Package:
            return UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        case .heart28Package:
            return UIColor(red: 237.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
        }
    }
}

class SSHeartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
    }

    override func initView() {
    }

    @IBAction func tapNaviClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK:- UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 81
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("heartTableViewCell", forIndexPath: indexPath) as! SSHeartTableViewCell

        cell.configView(SSHeartGoods(rawValue: indexPath.row)!)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // purchase
    }
}
