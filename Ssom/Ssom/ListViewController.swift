//
//  ListViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 6..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SSListTableViewCellDelegate, SSPhotoViewDelegate, SSFilterViewDelegate, SSScrollViewDelegate {
    @IBOutlet var ssomListTableView: UITableView!
    @IBOutlet var viewBottomInfo: UIView!
//    @IBOutlet var constBottomInfoViewHeight: NSLayoutConstraint!
//    @IBOutlet var constBottomInfoViewTrailingToSuper: NSLayoutConstraint!
    @IBOutlet var viewFilterBackground: UIView!
    @IBOutlet var lbFilteredAgePeople: UILabel!

    @IBOutlet var btnWrite: UIButton!

    @IBOutlet var btnIPay: UIButton!
    @IBOutlet var viewPayButtonBottomLine: UIView!
    @IBOutlet var constViewPayButtonBottomLineLeadingToButtonIPay: NSLayoutConstraint!
    @IBOutlet var btnYouPay: UIButton!

    var mainViewModel: SSMainViewModel
    lazy var _datasOfFilteredSsom: [SSViewModel] = []
    var datas: [SSViewModel] {
        get {
            return self._datasOfFilteredSsom
        }
        set {
            if let filterViewModel = self.filterModel where self.filterModel.ageTypes != [.AgeAll] || self.filterModel.peopleCountTypes != [.All] {
                var filteredData = [SSViewModel]()

                for model: SSViewModel in newValue {

                    if filterViewModel.includedAgeAreaTypes(model.minAge) && filterViewModel.includedPeopleCountStringTypes(model.userCount) {
                        filteredData.append(model)
                    } else {
                        if filterViewModel.ageTypes == [.AgeAll] && filterViewModel.includedPeopleCountStringTypes(model.userCount) {
                            filteredData.append(model)
                        }
                        if filterViewModel.includedAgeAreaTypes(model.minAge) && filterViewModel.peopleCountTypes == [.All] {
                            filteredData.append(model)
                        }
                    }
                }

                self._datasOfFilteredSsom = filteredData
            } else {
                self._datasOfFilteredSsom = newValue
            }
        }
    }

    var isAlreadyWrittenMySsom: Bool = false
    var mySsom: SSViewModel!

    var profileImageView: SSPhotoView?

    var filterView: SSFilterView!
    var filterModel: SSFilterViewModel!
    var scrollDetailView: SSScrollView!

    var needReload: Bool = false

    init() {
        self.mainViewModel = SSMainViewModel()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.mainViewModel = SSMainViewModel()

        super.init(coder: aDecoder)
    }

    convenience init(datas:[SSViewModel], isSell: Bool) {
        self.init()

        self.mainViewModel = SSMainViewModel(datas: datas, isSell: isSell)
        self.datas = self.mainViewModel.datas
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func initView() {

        self.isAlreadyWrittenMySsom = false
        self.mySsom = nil

        ssomListTableView.registerNib(UINib.init(nibName: "SSListTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "cell")

        self.edgesForExtendedLayout = UIRectEdge.None

        self.viewFilterBackground.layer.cornerRadius = self.viewFilterBackground.bounds.height / 2

        self.btnIPay.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
        self.btnIPay.layer.shadowOffset = CGSizeMake(0, 2)
        self.btnIPay.layer.shadowRadius = 1
        self.btnIPay.layer.shadowOpacity = 1

        self.btnYouPay.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
        self.btnYouPay.layer.shadowOffset = CGSizeMake(0, 2)
        self.btnYouPay.layer.shadowRadius = 1
        self.btnYouPay.layer.shadowOpacity = 1

        if self.mainViewModel.isSell {
            self.tapIPayButton(self.btnIPay);
        } else {
            self.tapYouPayButton(self.btnYouPay);
        }

        self.closeFilterView()
        self.closeScrollView(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        self.initView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.showOpenAnimation()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.viewBottomInfo.transform = CGAffineTransformMakeTranslation(0, 200)
        self.btnWrite.transform = CGAffineTransformMakeTranslation(0, 200)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "SSWriteViewSegueFromList") {
            let vc: SSWriteViewController = segue.destinationViewController as! SSWriteViewController

            vc.writeViewModel.myLatitude = self.mainViewModel.nowLatitude
            vc.writeViewModel.myLongitude = self.mainViewModel.nowLongitude
        }
    }

    func showOpenAnimation() {

        self.setMySsomButton()
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {

            self.viewBottomInfo.transform = CGAffineTransformIdentity
            self.btnWrite.transform = CGAffineTransformIdentity
        }) { (finish) in
            //
        }
    }

    func setMySsomButton() {

        if self.isAlreadyWrittenMySsom {
            self.btnWrite.setImage(UIImage(named: "myBtn"), forState: UIControlState.Normal)
        } else {
            self.btnWrite.setImage(UIImage(named: "writeBtn"), forState: UIControlState.Normal)
        }
    }

    @IBAction func tapIPayButton(sender: AnyObject?) {

        self.constViewPayButtonBottomLineLeadingToButtonIPay.constant = 0

        UIView.animateWithDuration(0.3, animations: {

            self.btnIPay.selected = true;
            self.viewPayButtonBottomLine.backgroundColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1.0)
            self.btnYouPay.selected = false;

            self.view.layoutIfNeeded()
        }) { (finish) in

            self.mainViewModel.isSell = true;

            self.loadData()
        }
    }

    @IBAction func tapYouPayButton(sender: AnyObject?) {

        self.constViewPayButtonBottomLineLeadingToButtonIPay.constant = self.btnIPay.bounds.width

        UIView.animateWithDuration(0.3, animations: {
            
            self.btnIPay.selected = false;
            self.viewPayButtonBottomLine.backgroundColor = UIColor(red: 237.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            self.btnYouPay.selected = true;

            self.view.layoutIfNeeded()
        }) { (finish) in

            self.mainViewModel.isSell = false;

            self.loadData()
        }
    }

    @IBAction func tapFilterButton(sender: AnyObject) {

        self.filterView = UIView.loadFromNibNamed("SSFilterView") as! SSFilterView
        self.filterView.delegate = self
        if let filterViewModel = self.filterModel {
            self.filterView.model = filterViewModel
        }
        self.filterView.configView()
        
        self.filterView.alpha = 0.0
        self.view.addSubview(self.filterView)
        self.filterView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.filterView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.filterView]))

//        self.view.layoutIfNeeded()

//        self.constBottomInfoViewHeight.constant = 283.0
//        self.constBottomInfoViewTrailingToSuper.constant = 64.0

        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {

//            self.view.layoutIfNeeded()

            self.lbFilteredAgePeople.alpha = 0.2
            self.viewFilterBackground.backgroundColor = UIColor(white: 1, alpha: 1)

            self.filterView.alpha = 1.0

        }) { (finish) in
            
//            self.constBottomInfoViewHeight.constant = 69.0
//            self.constBottomInfoViewTrailingToSuper.constant = 154.0

            self.lbFilteredAgePeople.alpha = 1.0
            self.viewFilterBackground.backgroundColor = UIColor(white: 1, alpha: 0.8)
        }
    }

    @IBAction func tapWriteButton(sender: AnyObject) {

        if self.isAlreadyWrittenMySsom {
            let transformZ: CATransform3D = CATransform3DMakeTranslation(0.0, 0.0, -self.btnWrite.bounds.width * 2)
            let transform: CATransform3D = CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 1.0, 0.0)

            UIView.animateWithDuration(0.3, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
                self.btnWrite.layer.transform = CATransform3DConcat(transformZ, transform)
                }, completion: { (finish) in
                    if self.btnIPay.selected && self.mySsom.ssomType != .SSOM {
                        self.tapYouPayButton(nil)

                        self.loadCompletionBlock = { [weak self] in
                            if let wself = self {
                                wself.openDetailView(wself.mySsom)
                                wself.btnWrite.layer.transform = CATransform3DIdentity
                            }
                        }
                    } else if self.btnYouPay.selected && self.mySsom.ssomType != .SSOSEYO {
                        self.tapIPayButton(nil)

                        self.loadCompletionBlock = { [weak self] in
                            if let wself = self {
                                wself.openDetailView(wself.mySsom)
                                wself.btnWrite.layer.transform = CATransform3DIdentity
                            }
                        }
                    } else {
                        self.openDetailView(self.mySsom)
                        self.btnWrite.layer.transform = CATransform3DIdentity
                    }
            })
        } else {
            let transform: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI * 45.0 / 180.0))

            UIView.animateWithDuration(0.3, animations: {
                self.btnWrite.transform = transform
            }) { (finish) in
                self.performSegueWithIdentifier("SSWriteViewSegueFromList", sender: nil)
            }
        }
    }

// MARK: private
    var loadCompletionBlock: (() -> Void)?

    func loadData() {
        if self.needReload {

            SSNetworkAPIClient.getPosts { [unowned self] (viewModels, error) -> Void in
                if let models = viewModels {
                    self.mainViewModel.datas = models
                    self._datasOfFilteredSsom = models
                    print("result is : \(self.mainViewModel.datas)")

                    self.filterData()
                } else {
                    print("error is : \(error?.localizedDescription)")
                }
            }
        } else {
            // initially loading
            self.filterData()

            self.needReload = true;
        }
    }

    func filterData() {
        var tempDatas: [SSViewModel] = []

        let ssomType: SSType
        if self.mainViewModel.isSell {
            ssomType = .SSOM
        } else {
            ssomType = .SSOSEYO
        }

        for data: SSViewModel in self.mainViewModel.datas {
            let ssomString = data.ssomType.rawValue
            if ssomString == ssomType.rawValue {
                tempDatas.append(data)
            }

            // check if my ssom exists
            if let loginedUserId = SSAccountManager.sharedInstance.userModel?.userId {
                if loginedUserId == data.userId {
                    self.isAlreadyWrittenMySsom = true
                    self.mySsom = data
                } else {
                    self.isAlreadyWrittenMySsom = self.isAlreadyWrittenMySsom || false
                }
            }
        }

        self.setMySsomButton()

        self.mainViewModel.datas = tempDatas
        self.datas = tempDatas

        self.ssomListTableView.reloadData()

        guard let completion = self.loadCompletionBlock else { return }
        completion()
    }

    func openDetailView(model: SSViewModel) {

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.isDrawable = false
        }

        self.scrollDetailView = UIView.loadFromNibNamed("SSDetailView", className: SSScrollView.self) as! SSScrollView
        self.scrollDetailView.frame = UIScreen.mainScreen().bounds
        self.scrollDetailView.delegate = self

        if self.btnIPay.selected {
            self.scrollDetailView.ssomType = .SSOM
            self.scrollDetailView.configureWithDatas(self.datas, currentViewModel: model)
            self.scrollDetailView.changeTheme(.SSOM)
        }
        if self.btnYouPay.selected {
            self.scrollDetailView.ssomType = .SSOSEYO
            self.scrollDetailView.configureWithDatas(self.datas, currentViewModel: model)
            self.scrollDetailView.changeTheme(.SSOSEYO)
        }

        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.view.addSubview(self.scrollDetailView)
    }

// MARK:- SSListTableViewCellDelegate
    func tapProfileImage(sender: AnyObject, imageUrl: String) {
        self.navigationController?.navigationBarHidden = true;

        self.profileImageView = UIView.loadFromNibNamed("SSPhotoView") as? SSPhotoView
        self.profileImageView!.loadingImage(self.view.bounds, imageUrl: imageUrl)
        self.profileImageView!.delegate = self

        self.view.addSubview(self.profileImageView!)
    }

// MARK:- SSPhotoViewDelegate
    func tapPhotoViewClose() {
        self.navigationController?.navigationBarHidden = false;

        self.profileImageView!.removeFromSuperview()
    }

// MARK:- UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SSListTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! SSListTableViewCell

        let model:SSViewModel = datas[indexPath.row]
        cell.configView(model, isMySsom: self.mySsom === model, isSsom: self.mainViewModel.isSell, withCoordinate: CLLocationCoordinate2DMake(self.mainViewModel.nowLatitude, self.mainViewModel.nowLongitude))

        cell.delegate = self

        return cell;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell: SSListTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as? SSListTableViewCell {
            if cell.isCellOpened {
                cell.closeCell(true)
            } else {
                if cell.isCellClosed {

                    let model = self.datas[indexPath.row]

                    self.openDetailView(model)

                }
            }
        }
    }

// MARK: - SSFilterViewDelegate
    func closeFilterView() {
        if let view = self.filterView {
            view.removeFromSuperview()
        }
    }

    func applyFilter(filterViewModel: SSFilterViewModel) {
        self.filterView.removeFromSuperview()

        // apply filter value to get the ssom list
        self.filterModel = filterViewModel
        self.datas = self.mainViewModel.datas
        self.ssomListTableView.reloadData()
        
//        self.lbFilteredAgePeople.text = filterViewModel.ageType.rawValue + ", " + filterViewModel.peopleCountType.rawValue
    }

// MARK: - SSScrollViewDelegate
    func closeScrollView(needToReload: Bool) {

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        if let view = self.scrollDetailView {
            self.navigationController?.navigationBar.barStyle = .Default
            view.removeFromSuperview()

            self.loadCompletionBlock = nil

            if needToReload {
                self.loadData()
            }
        }
    }

    func openSignIn(completion: ((finish:Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: completion)
    }

    func doSsom(ssomType: SSType, postId: String, partnerImageUrl: String?, ssomLatitude: Double, ssomLongitude: Double) {
        if let token = SSAccountManager.sharedInstance.sessionToken {
            if postId != "" {
                SSNetworkAPIClient.postChatroom(token, postId: postId, completion: { (chatroomId, error) in

                    if let err = error {
                        print(err.localizedDescription)

                        SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                    } else {
                        if let createdChatroomId = chatroomId {
                            let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
                            let vc: SSChatViewController = chatStoryboard.instantiateViewControllerWithIdentifier("chatViewController") as! SSChatViewController
                            vc.ssomType = ssomType
                            vc.chatRoomId = createdChatroomId
                            vc.myImageUrl = SSAccountManager.sharedInstance.profileImageUrl
                            vc.partnerImageUrl = partnerImageUrl

                            vc.ssomLatitude = ssomLatitude
                            vc.ssomLongitude = ssomLongitude

                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                })
            }
        }
    }

// MARK: - SSListTableViewCellDelegate
    func deleteCell(cell: UITableViewCell) {
        if let indexPath: NSIndexPath = self.ssomListTableView.indexPathForCell(cell) {
            if let token = SSAccountManager.sharedInstance.sessionToken {
                let data = self.datas[indexPath.row]

                SSNetworkAPIClient.deletePost(token, postId: data.postId, completion: { [weak self] (error) in
                    if let err = error {
                        SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                    } else {
                        if let wself = self {
                            wself.datas.removeAtIndex(indexPath.row)
                            wself.ssomListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

                            wself.isAlreadyWrittenMySsom = false
                            wself.mySsom = nil

                            wself.setMySsomButton()

                            SSAlertController.showAlertConfirm(title: "알림", message: "성공적으로 삭제 되었쏨!", completion: { (action) in
                                //
                            })
                        }
                    }
                })
            }
        }
    }
}
