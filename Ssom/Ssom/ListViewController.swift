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
import Toast_Swift

class ListViewController: UIViewController, Reloadable, UITableViewDelegate, UITableViewDataSource, SSListTableViewCellDelegate, SSPhotoViewDelegate, SSFilterViewDelegate, SSScrollViewDelegate {
    @IBOutlet var ssomListTableView: UITableView!
    @IBOutlet var viewNoSsom: UIView!

    @IBOutlet var btnWrite: UIButton!

    var mainViewModel: SSMainViewModel
    lazy var _datasOfFilteredSsom: [SSViewModel] = []
    var datas: [SSViewModel] {
        get {
            return self._datasOfFilteredSsom
        }
        set {
            // check if my ssom exists
            for model: SSViewModel in newValue {
                if let loginedUserId = SSAccountManager.sharedInstance.userUUID {
                    if loginedUserId == model.userId {
                        self.isAlreadyWrittenMySsom = true
                        self.mySsom = model
                        break
                    } else {
                        self.isAlreadyWrittenMySsom = self.isAlreadyWrittenMySsom || false
                    }
                }
            }

            if let filterViewModel = self.filterModel, filterViewModel.ssomType != [.SSOM, .SSOSEYO] || filterViewModel.ageTypes != [.AgeAll] || filterViewModel.peopleCountTypes != [.All] {
                var filteredData = [SSViewModel]()

                for model: SSViewModel in newValue {
                    if let mySsom = self.mySsom, mySsom === model {
                        filteredData.append(model)
                    } else {
                        if filterViewModel.includedSsomTypes(model.ssomType) &&
                            filterViewModel.includedAgeAreaTypes(model.minAge) &&
                            filterViewModel.includedPeopleCountStringTypes(model.userCount) {
                            filteredData.append(model)
                        } else {
                            if filterViewModel.includedSsomTypes(model.ssomType) &&
                                filterViewModel.ageTypes == [.AgeAll] &&
                                filterViewModel.includedPeopleCountStringTypes(model.userCount) {
                                filteredData.append(model)
                            }
                            if filterViewModel.includedSsomTypes(model.ssomType) &&
                                filterViewModel.includedAgeAreaTypes(model.minAge) &&
                                filterViewModel.peopleCountTypes == [.All] {
                                filteredData.append(model)
                            }
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
    var filterModel: SSFilterViewModel! {
        didSet {
            if let tabBarController = self.tabBarController as? SSTabBarController {
                tabBarController.filterModel = self.filterModel
            }
        }
    }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func getMainViewModel() {
        if let tabBarController = self.tabBarController as? SSTabBarController {
            if let mainViewModel = tabBarController.mainViewModel {
                self.mainViewModel = mainViewModel
            }

            if let filterModel = tabBarController.filterModel {
                self.filterModel = filterModel
            }
        }
    }

    func initView() {

        self.isAlreadyWrittenMySsom = false
        self.mySsom = nil

        self.ssomListTableView.register(UINib(nibName: "SSListTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")

        if let filterView = self.filterView {
            filterView.tapCloseButton()
        }
        self.closeScrollView(false)

        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        self.getMainViewModel()

        self.initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let filterView = self.filterView {
            filterView.tapCloseButton()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.btnWrite.transform = CGAffineTransform(translationX: 0, y: 200)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "SSWriteViewSegueFromList") {
            let vc: SSWriteViewController = segue.destination as! SSWriteViewController

            vc.writeViewModel.myLatitude = self.mainViewModel.nowLatitude
            vc.writeViewModel.myLongitude = self.mainViewModel.nowLongitude
        }
    }

    func showOpenAnimation() {

        self.setMySsomButton()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.btnWrite.transform = CGAffineTransform.identity
        }) { (finish) in
            //
        }
    }

    func setMySsomButton() {

        if self.isAlreadyWrittenMySsom {
            self.btnWrite.setImage(UIImage(named: "myBtn"), for: UIControlState())
        } else {
            self.btnWrite.setImage(UIImage(named: "writeBtn"), for: UIControlState())
        }
    }

    @IBAction func tapFilterButton(_ sender: AnyObject? = nil) {

        self.filterView = UIView.loadFromNibNamed("SSFilterView") as! SSFilterView
        self.filterView.delegate = self
        if let filterViewModel = self.filterModel {
            self.filterView.model = filterViewModel
        }
        self.filterView.configView()
        
        self.filterView.alpha = 0.0
        self.navigationController?.view.addSubview(self.filterView)
        self.filterView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.filterView]))
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[view]-44-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.filterView]))

        self.filterView.openAnimation()
    }

    @IBAction func tapWriteButton(_ sender: AnyObject) {

        if self.isAlreadyWrittenMySsom {
            let transformZ: CATransform3D = CATransform3DMakeTranslation(0.0, 0.0, -self.btnWrite.bounds.width * 2)
            let transform: CATransform3D = CATransform3DMakeRotation(.pi, 0.0, 1.0, 0.0)

            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.btnWrite.layer.transform = CATransform3DConcat(transformZ, transform)
                }, completion: { (finish) in
                    self.openDetailView(self.mySsom)
                    self.btnWrite.layer.transform = CATransform3DIdentity
            })
        } else {
            let transform: CGAffineTransform = CGAffineTransform(rotationAngle: CGFloat(.pi * -135.0 / 180.0))

            UIView.animate(withDuration: 0.3, animations: {
                self.btnWrite.transform = transform
            }, completion: { (finish) in
                if SSAccountManager.sharedInstance.isAuthorized {
                    self.performSegue(withIdentifier: "SSWriteViewSegueFromList", sender: nil)
                } else {
                    SSAccountManager.sharedInstance.openSignIn(self, completion: { (finish) in
                        if finish {
                            self.loadData()
                        } else {
                            self.showOpenAnimation()
                        }
                    })
                }
            }) 
        }
    }

// MARK: private
    var loadCompletionBlock: (() -> Void)?

    func loadData() {
        SSNetworkAPIClient.getPosts(latitude: self.mainViewModel.nowLatitude, longitude: self.mainViewModel.nowLongitude, completion: { [weak self] (viewModels, error) -> Void in
            guard let wself = self else { return }

            if let models = viewModels {
                wself.mainViewModel.datas = models
                wself.datas = models
                print("result is : \(wself.mainViewModel.datas)")

                wself.filterData()
            } else {
                print("error is : \(error.debugDescription)")
            }
        })
    }

    func filterData() {
        self.showOpenAnimation()

        if self.datas.count > 0 {
            self.ssomListTableView.backgroundColor = UIColor.white
        } else {
            self.ssomListTableView.backgroundColor = UIColor.clear
        }

        self.ssomListTableView.reloadData()

        guard let completion = self.loadCompletionBlock else { return }
        completion()
    }

    func openDetailView(_ model: SSViewModel) {

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = false
        }
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

        self.scrollDetailView = UIView.loadFromNibNamed("SSDetailView", className: SSScrollView.self) as! SSScrollView
        self.scrollDetailView.frame = UIScreen.main.bounds
        self.scrollDetailView.delegate = self

        if let filterModel = self.filterModel {
            self.scrollDetailView.ssomTypes = filterModel.ssomType
            self.scrollDetailView.configureWithDatas(self.datas, currentViewModel: model)
            self.scrollDetailView.changeTheme(filterModel.ssomType)
        } else {
            self.scrollDetailView.ssomTypes = [.SSOM, .SSOSEYO]
            self.scrollDetailView.configureWithDatas(self.datas, currentViewModel: model)
            self.scrollDetailView.changeTheme([.SSOM, .SSOSEYO])
        }

        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.view.addSubview(self.scrollDetailView)
    }

// MARK:- SSListTableViewCellDelegate
    func tapProfileImage(_ sender: AnyObject, imageUrl: String) {
        self.navigationController?.isNavigationBarHidden = true;
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

        self.profileImageView = UIView.loadFromNibNamed("SSPhotoView") as? SSPhotoView
        self.profileImageView!.loadImage(self.view.bounds, imageUrl: imageUrl)
        self.profileImageView!.delegate = self

        self.navigationController?.view.addSubview(self.profileImageView!)
    }

    func deleteCell(_ cell: UITableViewCell) {
        if let indexPath: IndexPath = self.ssomListTableView.indexPath(for: cell) {
            if let token = SSAccountManager.sharedInstance.sessionToken {
                let data = self.datas[indexPath.row]

                SSNetworkAPIClient.deletePost(token, postId: data.postId, completion: { [weak self] (error) in
                    if let err = error {
                        SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                    } else {
                        guard let wself = self else { return }

                        wself.datas.remove(at: indexPath.row)
                        wself.ssomListTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)

                        wself.isAlreadyWrittenMySsom = false
                        wself.mySsom = nil

                        wself.setMySsomButton()

                        SSAlertController.showAlertConfirm(title: "알림", message: "성공적으로 삭제 되었쏨!", completion: { (action) in
                            //
                        })
                    }
                })
            }
        }
    }

// MARK:- SSPhotoViewDelegate
    func tapPhotoViewClose() {
        self.navigationController?.isNavigationBarHidden = false;
        UIApplication.shared.setStatusBarStyle(.default, animated: false)

        self.profileImageView!.removeFromSuperview()
    }

// MARK:- UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SSListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SSListTableViewCell

        let model: SSViewModel = self.datas[indexPath.row]
        cell.configView(model, isMySsom: self.mySsom === model, ssomType: model.ssomType, withCoordinate: CLLocationCoordinate2DMake(self.mainViewModel.nowLatitude, self.mainViewModel.nowLongitude))

        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell: SSListTableViewCell = tableView.cellForRow(at: indexPath) as? SSListTableViewCell {
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
    func applyFilter(_ filterViewModel: SSFilterViewModel?) {
        self.filterView.tapCloseButton()

        // apply filter value to get the ssom list
        if let _filterViewModel = filterViewModel {
            self.filterModel = _filterViewModel

            if let tabBarController = self.tabBarController as? SSTabBarController {
                tabBarController.barButtonItems.changeFilter(ssomTypes: _filterViewModel.ssomType)
            }
        } else {
            if let tabBarController = self.tabBarController as? SSTabBarController {
                tabBarController.barButtonItems.changeFilter()
            }
        }
        self.datas = self.mainViewModel.datas
        self.ssomListTableView.reloadData()

        self.view.makeToast("쏨 필터가 적용 되었습니다 =)", duration: 2.0, position: CGPoint(x: UIScreen.main.bounds.width / 2.0, y: 104))
    }

// MARK: - SSScrollViewDelegate
    func closeScrollView(_ needToReload: Bool) {

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }
        UIApplication.shared.setStatusBarStyle(.default, animated: false)

        if let view = self.scrollDetailView {
            self.navigationController?.navigationBar.barStyle = .default
            view.removeFromSuperview()

            self.loadCompletionBlock = nil

            if needToReload {
                self.loadData()
            }
        }
    }

    func openSignIn(_ completion: ((_ finish:Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: completion)
    }

    func doSsom(_ ssomType: SSType, model: SSViewModel) {
        if let token = SSAccountManager.sharedInstance.sessionToken {
            if model.postId != "" {
                // 나랑 채팅중인 쏨이면..
                if let chatroomId = model.assignedChatroomId {
                    self.goChat(chatroomId: chatroomId, model: model, ssomType: ssomType)
                } else {
                    SSNetworkAPIClient.postChatroom(token, postId: model.postId, latitude: self.mainViewModel.nowLatitude, longitude: self.mainViewModel.nowLongitude, completion: { (chatroomId, error) in

                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                        } else {
                            // heart count
                            guard let tabBarController = self.tabBarController as? SSTabBarController else { return }
                            if let heartsCount = SSNetworkContext.sharedInstance.getSharedAttribute("heartsCount") as? Int {
                                tabBarController.barButtonItems.changeHeartCount(heartsCount)
                            } else {
                                tabBarController.barButtonItems.changeHeartCount(2)
                            }

                            if let createdChatroomId = chatroomId {
                                self.goChat(chatroomId: createdChatroomId, model: model, ssomType: ssomType)
                            }
                        }
                    })
                }
            }
        }
    }

    func goChat(chatroomId: String, model: SSViewModel, ssomType: SSType) {
        let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
        let vc: SSChatViewController = chatStoryboard.instantiateViewController(withIdentifier: "chatViewController") as! SSChatViewController
        vc.ssomType = ssomType
        vc.ageArea = Util.getAgeArea(model.minAge)
        if let userCount = model.userCount {
            vc.peopleCount = SSPeopleCountType(rawValue: userCount)!.toSting()
        }
        vc.chatRoomId = chatroomId
        vc.partnerImageUrl = model.imageUrl

        vc.ssomLatitude = model.latitude
        vc.ssomLongitude = model.longitude

        vc.meetRequestUserId = model.meetRequestUserId
        vc.meetRequestStatus = model.meetRequestStatus

        self.navigationController?.pushViewController(vc, animated: true)
    }
}
