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
    @IBOutlet var bottomInfoView: UIView!

    @IBOutlet var btnIPay: UIButton!
    @IBOutlet var iPayButtonBottomLineView: UIImageView!
    @IBOutlet var btnYouPay: UIButton!
    @IBOutlet var youPayButtonBottomLineView: UIImageView!

    var mainViewModel: SSMainViewModel
    var profileImageView: SSPhotoView?

    var filterView: SSFilterView!
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        ssomListTableView.registerNib(UINib.init(nibName: "SSListTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "cell")

        self.edgesForExtendedLayout = UIRectEdge.None

        self.initView()
    }

    func initView() {
        self.needReload = false

        if self.mainViewModel.isSell {
            self.tapIPayButton(self.btnIPay);
        } else {
            self.tapYouPayButton(self.btnYouPay);
        }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "SSWriteViewSegueFromList") {
            let vc: SSWriteViewController = segue.destinationViewController as! SSWriteViewController

            vc.writeViewModel.myLatitude = self.mainViewModel.nowLatitude
            vc.writeViewModel.myLongitude = self.mainViewModel.nowLongitude
        }
    }

    @IBAction func tapIPayButton(sender: AnyObject) {

        self.btnIPay.selected = true;
        self.iPayButtonBottomLineView.hidden = false;
        self.btnYouPay.selected = false;
        self.youPayButtonBottomLineView.hidden = true;

        self.mainViewModel.isSell = true;

        self.loadingData()
    }

    @IBAction func tapYouPayButton(sender: AnyObject) {

        self.btnIPay.selected = false;
        self.iPayButtonBottomLineView.hidden = true;
        self.btnYouPay.selected = true;
        self.youPayButtonBottomLineView.hidden = false;

        self.mainViewModel.isSell = false;

        self.loadingData()
    }

    @IBAction func tapFilterButton(sender: AnyObject) {

        self.filterView = UIView.loadFromNibNamed("SSFilterView") as! SSFilterView
        self.filterView.frame = self.view.bounds
        self.filterView.delegate = self
        self.view.addSubview(self.filterView)
    }

// MARK: private
    func loadingData() {
        if self.needReload {

            SSNetworkAPIClient.getPosts { [unowned self] (viewModels, error) -> Void in
                if let models = viewModels {
                    self.mainViewModel.datas = models
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
        }

        self.mainViewModel.datas = tempDatas

        self.ssomListTableView.reloadData()
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
    func tapClose() {
        self.navigationController?.navigationBarHidden = false;

        self.profileImageView!.removeFromSuperview()
    }

// MARK:- UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SSListTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! SSListTableViewCell

        let model:SSViewModel = mainViewModel.datas[indexPath.row]
        if let content = model.content {
            print("content is \(content.stringByRemovingPercentEncoding)")

            cell.descriptionLabel.text = content.stringByRemovingPercentEncoding
        }

        if let imageUrl = model.imageUrl {
            if imageUrl.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
                print("imageUrl is \(imageUrl)")

                cell.profileImageView!.sd_setImageWithURL(NSURL(string: imageUrl)
                    , placeholderImage: nil
                    , completed: { [unowned self] (image, error, cacheType, url) -> Void in

                        let croppedProfileImage: UIImage = UIImage.cropInCircle(image, frame: CGRectMake(0, 0, 72.2, 72.2))

                        let maskOfProfileImage: UIImage = UIImage.resizeImage(UIImage.init(named: self.mainViewModel.isSell ? "bigGreen.png" : "bigRed.png")!, frame: CGRectMake(0, 0, 89.2, 77.2))

                        cell.profileImageView!.image = UIImage.mergeImages(firstImage: croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)
                    })
                
                cell.profilImageUrl = imageUrl
            } else {
                let maskOfProfileImage: UIImage = UIImage.resizeImage(UIImage.init(named: self.mainViewModel.isSell ? "bigGreen.png" : "bigRed.png")!, frame: CGRectMake(0, 0, 89.2, 77.2))

                cell.profileImageView!.image = maskOfProfileImage
            }
        } else {
            let maskOfProfileImage: UIImage = UIImage.resizeImage(UIImage.init(named: self.mainViewModel.isSell ? "bigGreen.png" : "bigRed.png")!, frame: CGRectMake(0, 0, 89.2, 77.2))

            cell.profileImageView!.image = maskOfProfileImage
        }

        var memberInfoString:String = "";
        if let minAge = model.minAge {
            let ageArea: SSAgeAreaType = Util.getAgeArea(minAge)
            memberInfoString = memberInfoString.stringByAppendingFormat("\(ageArea.rawValue)")
        }
//        if let maxAge = model.maxAge {
//            memberInfoString = memberInfoString.stringByAppendingFormat("~\(maxAge)살")
//        }
        if let userCount = model.userCount {
            memberInfoString = memberInfoString.stringByAppendingFormat(" \(userCount)명 있어요.")
        }
        cell.memberInfoLabel.text = memberInfoString

        if let distance = model.distance where distance != 0 {
            cell.distanceLabel.text = Util.getDistanceString(distance)
        } else {
            let nowCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.mainViewModel.nowLatitude, longitude: self.mainViewModel.nowLongitude)
            let ssomCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)

            let distance: Int = Int(Util.getDistance(locationFrom: nowCoordinate, locationTo: ssomCoordinate))

            cell.distanceLabel.text = Util.getDistanceString(distance)
        }

        cell.delegate = self

        return cell;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainViewModel.datas.count;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.scrollDetailView = UIView.loadFromNibNamed("SSDetailView", className: SSScrollView.self) as! SSScrollView
        self.scrollDetailView.frame = UIScreen.mainScreen().bounds
        self.scrollDetailView.delegate = self

        let model = self.mainViewModel.datas[indexPath.row]
        if self.btnIPay.selected {
            self.scrollDetailView.ssomType = .SSOM
            self.scrollDetailView.configureWithDatas(self.mainViewModel.datas, currentViewModel: model)
            self.scrollDetailView.changeTheme(.SSOM)
        }
        if self.btnYouPay.selected {
            self.scrollDetailView.ssomType = .SSOSEYO
            self.scrollDetailView.configureWithDatas(self.mainViewModel.datas, currentViewModel: model)
            self.scrollDetailView.changeTheme(.SSOSEYO)
        }

        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.view.addSubview(self.scrollDetailView)
    }

// MARK: - SSFilterViewDelegate
    func closeFilterView() {
        self.filterView.removeFromSuperview()
    }

    func applyFilter(filterViewModel: SSFilterViewModel) {
        self.filterView.removeFromSuperview()

        // apply filter value to get the ssom list
        self.ssomListTableView .reloadData()
    }

// MARK: - SSScrollViewDelegate
    func closeScrollView() {
        self.navigationController?.navigationBar.barStyle = .Default
        self.scrollDetailView.removeFromSuperview()
    }

    func openSignIn(completion: ((finish:Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: completion)
    }

    func doSsom(ssomType: SSType) {
        let chatStoryboard: UIStoryboard = UIStoryboard(name: "SSChatStoryboard", bundle: nil)
        let vc = chatStoryboard.instantiateViewControllerWithIdentifier("chatViewController") as! SSChatViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}