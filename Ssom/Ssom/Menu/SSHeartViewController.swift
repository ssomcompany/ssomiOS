//
//  SSHeartViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 10. 10..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import StoreKit
import UICountingLabel

enum SSHeartGoods: Int {
    case heart2Package
    case heart8Package
    case heart17Package
    case heart28Package

    static var AllProductIDs: [String] {
        return ["ssom2HeartPackage", "ssom8HeartPackage", "ssom17HeartPackage", "ssom28HeartPackage"]
    }

    var productID: String {
        return SSHeartGoods.AllProductIDs[self.rawValue]
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

class SSHeartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var heartTableView: UITableView!
    @IBOutlet var lbHeartCount: UICountingLabel!
    @IBOutlet var lbHeartRechargeTime: UILabel!

    var products: [SKProduct]!

    var indicator: SSIndicatorView!

    var purchasedProduct: SKProduct?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: SSInternalNotification.PurchasedHeart.rawValue), object: nil, queue: nil) { [weak self] (notification) in

            guard let wself = self else { return }

            if let userInfo = notification.userInfo {
                if let heartsCount = userInfo["heartsCount"] as? Int {
                    wself.changeHeartCount(heartsCount)
                }
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(pauseHeartRechageTimer), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeHeartRechargerTimer(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.initView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.scrollView.contentInset = UIEdgeInsets.zero
    }

    override func initView() {
        self.lbHeartCount.format = "%d"
        self.lbHeartCount.method = UILabelCountingMethod.linear

        if let heartsCount = SSNetworkContext.sharedInstance.getSharedAttribute("heartsCount") as? Int {
            self.changeHeartCount(heartsCount)
        }

        SKPaymentQueue.default().add(self)

        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: Set(SSHeartGoods.AllProductIDs))
            request.delegate = self

            self.indicator = SSIndicatorView()
            self.indicator.showIndicator()

            request.start()
        } else {
            SSAlertController.alertConfirm(title: "Error", message: "설정>일반>차단 메뉴에서 인앱결제를 활성화해주십시요!", vc: self, completion: nil)
        }
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    @IBAction func tapNaviClose(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapClose(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }

    func changeHeartCount(_ count: Int = 0) {
        let countNow = Int(self.lbHeartCount.text!)!
        self.lbHeartCount.count(from: CGFloat(countNow), to: CGFloat(count), withDuration: 0.3)

        if SSAccountManager.sharedInstance.isAuthorized {
            if count < SSDefaultHeartCount {
                self.startHeartRechargeTimer()
            } else {
                self.stopHeartRechageTimer()
            }
        } else {
            self.stopHeartRechageTimer()
        }
    }

    var heartRechargeTimer: Timer!

    func startHeartRechargeTimer(_ needRestart: Bool = false) {
        print(#function)

        if needRestart {
            let now = Date()
            SSNetworkContext.sharedInstance.saveSharedAttribute(now, forKey: "heartRechargeTimerStartedDate")

            self.lbHeartRechargeTime.text = Util.getTimeIntervalString(from: now).0
        } else {
            if let heartRechargeTimerStartedDate = SSNetworkContext.sharedInstance.getSharedAttribute("heartRechargeTimerStartedDate") as? Date {
                self.lbHeartRechargeTime.text = Util.getTimeIntervalString(from: heartRechargeTimerStartedDate).0
            } else {
                let now = Date()
                SSNetworkContext.sharedInstance.saveSharedAttribute(now, forKey: "heartRechargeTimerStartedDate")

                self.lbHeartRechargeTime.text = Util.getTimeIntervalString(from: now).0
            }
        }

        if let _ = self.heartRechargeTimer {
        } else {
            self.heartRechargeTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(changeHeartRechargerTimer(_:)), userInfo: nil, repeats: true)
        }
    }

    func pauseHeartRechageTimer() {
        print(#function)

        if let timer = self.heartRechargeTimer {
            timer.invalidate()
        }
    }

    func stopHeartRechageTimer(_ needToSave: Bool = false) {
        print(#function)

        if let timer = self.heartRechargeTimer {
            timer.invalidate()
            self.heartRechargeTimer = nil

            SSNetworkContext.sharedInstance.deleteSharedAttribute("heartRechargeTimerStartedDate")
        }

        self.lbHeartRechargeTime.text = "00:00"

        if needToSave {
            // 타이머 값 서버에 저장
        }
    }

    func changeHeartRechargerTimer(_ sender: Timer?) {
        print(#function)

        if let heartsCount = SSNetworkContext.sharedInstance.getSharedAttribute("heartsCount") as? Int, heartsCount >= SSDefaultHeartCount {
            self.stopHeartRechageTimer()

            return
        }

        if let heartRechargeTimerStartedDate = SSNetworkContext.sharedInstance.getSharedAttribute("heartRechargeTimerStartedDate") as? Date {
            print("heartRechargeTimerStartedDate is \(heartRechargeTimerStartedDate), now is \(Date()), time after 4hours is \(Date(timeInterval: SSDefaultHeartRechargeTimeInterval, since: heartRechargeTimerStartedDate))")

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            let timeIntervalString = Util.getTimeIntervalString(from: heartRechargeTimerStartedDate)
            self.lbHeartRechargeTime.text = timeIntervalString.0

            if timeIntervalString.1 <= 0 && timeIntervalString.2 <= 0 {
                // 하트 1개 구매 처리
                if let token = SSAccountManager.sharedInstance.sessionToken {

                    SSNetworkAPIClient.postPurchaseHearts(token, purchasedHeartCount: 1, completion: { [weak self] (heartsCount, error) in

                        guard let wself = self else { return }

                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                        } else {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: SSInternalNotification.PurchasedHeart.rawValue), object: nil, userInfo: ["purchasedHeartCount": 1,
                                                                                                                                                                       "heartsCount": heartsCount])

                            // 하트가 2개 이상이면, time 종료 처리
                            if heartsCount >= SSDefaultHeartCount {
                                wself.stopHeartRechageTimer()

                                SSAlertController.showAlertConfirm(title: "알림", message: String(format: "%d시간이 지나서 하트가 1개 충전되었습니다!!", SSDefaultHeartRechargeHour), completion: nil)
                            } else { // 하트가 2개 미만이면, time restart 처리
                                wself.startHeartRechargeTimer(true)
                            }
                        }
                    })
                }
            }
        } else {
            self.pauseHeartRechageTimer()
        }
    }

    // MARK:- UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products == nil ? 0 : self.products.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "heartTableViewCell", for: indexPath) as! SSHeartTableViewCell

        let heartGood = SSHeartGoods(rawValue: indexPath.row)!
        var priceWithTax: String = "$"
        var heartCount: String = ""
        for product in self.products {
            if product.productIdentifier == heartGood.productID {
                priceWithTax.append("\(product.price)")
                heartCount = product.localizedTitle.replacingOccurrences(of: "하트", with: "")
                break
            }
        }
        cell.configView(SSHeartGoods(rawValue: indexPath.row)!, priceWithTax: priceWithTax, heartCount: heartCount)
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        // purchase
        if let cell = tableView.cellForRow(at: indexPath) as? SSHeartTableViewCell {
            cell.showTapAnimation()

            self.indicator = SSIndicatorView()
            self.indicator.showIndicator()

            for product in self.products {
                if product.productIdentifier == cell.heartGood.productID {
                    self.purchasedProduct = product
                    let payment = SKPayment(product: self.purchasedProduct!)
                    SKPaymentQueue.default().add(payment)
                    break
                }
            }
        }
    }

    // MARK:- SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products

        if self.products.count != 0 {
            self.heartTableView.reloadData()
        } else {
            SSAlertController.alertConfirm(title: "Error", message: "유효한 상품이 없습니다!\n관리자에게 문의바랍니다.", vc: self, completion: nil)
        }

        self.indicator.hideIndicator()
    }

    // MARK:- SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        self.indicator.hideIndicator()

        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                if let token = SSAccountManager.sharedInstance.sessionToken {
                    let purchasedHeartCount: Int = Int(self.purchasedProduct!.localizedTitle.replacingOccurrences(of: "하트", with: ""))!
                    SSNetworkAPIClient.postPurchaseHearts(token, purchasedHeartCount: purchasedHeartCount, completion: { (heartsCount, error) in
                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                        } else {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: SSInternalNotification.PurchasedHeart.rawValue), object: nil, userInfo: ["purchasedHeartCount": purchasedHeartCount,
                                "heartsCount": heartsCount])
                        }
                    })
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                self.tapClose(nil)
            case SKPaymentTransactionState.failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
