//
//  MapViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 1..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import GoogleMaps
import SDWebImage

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, SSFilterViewDelegate, SSScrollViewDelegate {
    @IBOutlet var mainView: GMSMapView!
    @IBOutlet var writeButton: UIButton!
    @IBOutlet var myLocationButton: UIButton!
    @IBOutlet var btnIPay: UIButton!
    @IBOutlet var viewPayButtonLine: UIView!
    @IBOutlet var constViewPayButtonLineLeadingToButtonIPay: NSLayoutConstraint!
    @IBOutlet var btnYouPay: UIButton!

    @IBOutlet var viewBottomInfo: UIView!
    @IBOutlet var viewFilterBackground: UIView!
    @IBOutlet var lbFilteredAgePeople: UILabel!
    @IBOutlet var constBottomInfoViewHeight: NSLayoutConstraint!
    @IBOutlet var constBottomInfoViewTrailingToSuper: NSLayoutConstraint!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D!

    var datasOfAllSsom: [SSViewModel]
    lazy var _datasOfFilteredSsom: [SSViewModel] = []
    var datas: [SSViewModel] {
        get {
            return self._datasOfFilteredSsom
        }
        set {
            if self.filterModel != nil && self.filterModel.ageType != .AgeAll && self.filterModel.peopleCountType != .All {
                var filteredData = [SSViewModel]()

                for model: SSViewModel in newValue {
                    if model.minAge == self.filterModel.ageType.toInt() && model.userCount == self.filterModel.peopleCountType.toInt() {
                        filteredData.append(model)
                    } else {
                        if self.filterModel.ageType == .AgeAll && model.userCount == self.filterModel.peopleCountType.toInt() {
                            filteredData.append(model)
                        }
                        if model.minAge == self.filterModel.ageType.toInt() && self.filterModel.peopleCountType == .All {
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
    var datasForSsom: [SSViewModel]
    var datasForSsoseyo: [SSViewModel]

    var isAlreadyWrittenMySsom: Bool = false
    var mySsom: SSViewModel!

    var filterView: SSFilterView!
    var filterModel: SSFilterViewModel!
    var scrollDetailView: SSScrollView!

    init() {
        self.datasOfAllSsom = []
        self.datasForSsom = []
        self.datasForSsoseyo = []

        super.init(nibName: nil, bundle: nil)
    }

    convenience init(datas:[[String: AnyObject!]]) {
        self.init()

        for data in datas {
            let viewModel = SSViewModel.init(modelDict: data)

            self.datasOfAllSsom.append(viewModel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.datasOfAllSsom = []
        self.datasForSsom = []
        self.datasForSsoseyo = []

        super.init(coder: aDecoder)
    }

    func initView() {

        self.isAlreadyWrittenMySsom = false
        self.mySsom = nil

        self.viewBottomInfo.transform = CGAffineTransformMakeTranslation(0, 200)
        self.writeButton.transform = CGAffineTransformMakeTranslation(0, 200)

        self.viewBottomInfo.layoutIfNeeded()
        self.viewFilterBackground.layer.cornerRadius = self.viewFilterBackground.bounds.size.height / 2

        self.btnIPay.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
        self.btnIPay.layer.shadowOffset = CGSizeMake(0, 2)
        self.btnIPay.layer.shadowRadius = 1
        self.btnIPay.layer.shadowOpacity = 1

        self.btnYouPay.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
        self.btnYouPay.layer.shadowOffset = CGSizeMake(0, 2)
        self.btnYouPay.layer.shadowRadius = 1
        self.btnYouPay.layer.shadowOpacity = 1

        self.initMapView()

        self.closeFilterView()
        self.closeScrollView(false)

        self.loadingData()
    }

    func initMapView() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.startUpdatingLocation()
        }

        mainView.myLocationEnabled = true

        mainView.delegate = self
    }

    func loadingData() {
        SSNetworkAPIClient
            .getPosts(latitude: self.currentLocation != nil ? self.currentLocation.latitude : 0,
                      longitude: self.currentLocation != nil ? self.currentLocation.longitude : 0,
                      completion: { [unowned self] (viewModels, error) -> Void in

                        if let err = error {
                            print("error is : \(err.localizedDescription)")

                            SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)

                        } else {
                            if let models = viewModels {
                                self.datasOfAllSsom = models
                                self.datas = models
                                print("result is : \(self.datasOfAllSsom)")
                                
                                self.showMarkers()
                            }
                        }
                        
                        self.showOpenAnimation()
                })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.viewBottomInfo.transform = CGAffineTransformMakeTranslation(0, 200)
        self.writeButton.transform = CGAffineTransformMakeTranslation(0, 200)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showOpenAnimation() {

        self.setMySsomButton()

        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {

            self.viewBottomInfo.transform = CGAffineTransformIdentity
            self.writeButton.transform = CGAffineTransformIdentity
        }) { (finish) in
            //
        }
    }

    func setMySsomButton() {

        if self.isAlreadyWrittenMySsom {
            self.writeButton.setImage(UIImage(named: "myBtn"), forState: UIControlState.Normal)
        } else {
            self.writeButton.setImage(UIImage(named: "writeBtn"), forState: UIControlState.Normal)
        }
    }

    func showCurrentLocation() {
        locationManager.startUpdatingLocation()
    }

    func showMarkers() {

        mainView.clear()
        self.datasForSsom = []
        self.datasForSsoseyo = []

        var index: Int = 0;
        for data in self.datas {
            if let loginedUserId = SSAccountManager.sharedInstance.userModel?.userId {
                if loginedUserId == data.userId {
                    self.isAlreadyWrittenMySsom = true
                    self.mySsom = data
                } else {
                    self.isAlreadyWrittenMySsom = self.isAlreadyWrittenMySsom || false
                }
            }

            let latitude: Double = data.latitude 
            let longitude: Double = data.longitude 

            print("position is \(latitude), \(longitude)")

            let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let nowLocation: CLLocationCoordinate2D = self.currentLocation != nil ? self.currentLocation : mainView.camera.target

            let distance: Int = Int(Util.getDistance(locationFrom: nowLocation, locationTo: tempLocation))

            let dataWithDistance: SSViewModel = data
            dataWithDistance.distance = distance
            self.datas[index] = dataWithDistance
            
            index += 1

            let sellString: String = data.ssomType.rawValue
            let isSell = sellString == SSType.SSOM.rawValue

            if self.btnIPay.selected {
                if isSell {
                    self.datasForSsom.append(data)
                    if let imageUrl:String = data.imageUrl {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: imageUrl)
                    } else {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: nil)
                    }
                }
            }

            if self.btnYouPay.selected {
                if !isSell {
                    self.datasForSsoseyo.append(data)
                    if let imageUrl:String = data.imageUrl {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: imageUrl)
                    } else {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: nil)
                    }
                }
            }
        }
    }

    func setMarker(data: SSViewModel,_ isSell: Bool, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, imageUrl: String!) {
        let marker = GMSMarker()
        marker.userData = data;
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)

        let maskOfProfileImage: UIImage = UIImage.resizeImage(UIImage.init(named: isSell ? "minigreen.png" : "minired.png")!, frame: CGRectMake(0, 0, 56.2, 64.9))

        if imageUrl != nil && imageUrl.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imageUrl), options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, error, cacheType, finish, imageURL) in
                marker.icon = maskOfProfileImage

                if image != nil {
                    let croppedProfileImage: UIImage = UIImage.cropInCircle(image, frame: CGRectMake(0, 0, 51.6, 51.6))

                    marker.icon = UIImage.mergeImages(firstImage: croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)
                }
            })
        } else {
            marker.icon = maskOfProfileImage
        }
        marker.map = self.mainView
    }

    @IBAction func tapMyLocationButton(sender: AnyObject) {
        self.showCurrentLocation()
    }

    @IBAction func tapFilter(sender: AnyObject) {

        self.filterView = UIView.loadFromNibNamed("SSFilterView") as! SSFilterView
        self.filterView.delegate = self
        self.filterView.alpha = 0.0
        self.view.addSubview(self.filterView)
        self.filterView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.filterView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.filterView]))

        self.constBottomInfoViewHeight.constant = 283.0
        self.constBottomInfoViewTrailingToSuper.constant = 64.0

        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {

            self.viewBottomInfo.layoutIfNeeded()

            self.lbFilteredAgePeople.alpha = 0.2
            self.viewFilterBackground.backgroundColor = UIColor(white: 1, alpha: 1)

            self.filterView.alpha = 1.0

        }) { (finish) in
            
            self.constBottomInfoViewHeight.constant = 69.0
            self.constBottomInfoViewTrailingToSuper.constant = 154.0

            self.lbFilteredAgePeople.alpha = 1.0
            self.viewFilterBackground.backgroundColor = UIColor(white: 1, alpha: 0.8)
        }
    }

    @IBAction func tapIPayButton(sender: AnyObject) {

        self.constViewPayButtonLineLeadingToButtonIPay.constant = 0

        UIView.animateWithDuration(0.3, animations: {

            self.btnIPay.selected = true
            self.viewPayButtonLine.backgroundColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 143.0/255.0, alpha: 1.0)
            self.view.layoutIfNeeded()
            self.btnYouPay.selected = false
        }) { (finish) in
            self.showMarkers()
        }

    }

    @IBAction func tapYouPayButton(sender: AnyObject) {

        self.constViewPayButtonLineLeadingToButtonIPay.constant = self.btnIPay.bounds.width

        UIView.animateWithDuration(0.3, animations: {

            self.btnYouPay.selected = true
            self.viewPayButtonLine.backgroundColor = UIColor(red: 237.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            self.view.layoutIfNeeded()
            self.btnIPay.selected = false
        }) { (finish) in
            self.showMarkers()
        }

    }

    @IBAction func tapWriteButton(sender: AnyObject) {

        if self.isAlreadyWrittenMySsom {
            let transformZ: CATransform3D = CATransform3DMakeTranslation(0.0, 0.0, -self.writeButton.bounds.width * 2)
            let transform: CATransform3D = CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 1.0, 0.0)

            UIView.animateWithDuration(0.3, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
                self.writeButton.layer.transform = CATransform3DConcat(transformZ, transform)
                }, completion: { (finish) in
                    self.openDetailView(self.mySsom)
                    self.writeButton.layer.transform = CATransform3DIdentity
            })
        } else {
            let transform: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI * 45.0 / 180.0))

            UIView.animateWithDuration(0.3, animations: {
                self.writeButton.transform = transform
            }) { (finish) in
                self.performSegueWithIdentifier("SSWriteViewSegueFromMain", sender: nil)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "SSListViewSegue") {
            let vc: ListViewController = segue.destinationViewController as! ListViewController

            let nowLocation: CLLocationCoordinate2D = self.currentLocation
            vc.mainViewModel = SSMainViewModel(datas: self.datasOfAllSsom, isSell: self.btnIPay.selected, nowLatitude: nowLocation.latitude, nowLongitude: nowLocation.longitude)
        }

        if (segue.identifier == "SSWriteViewSegueFromMain") {
            let vc: SSWriteViewController = segue.destinationViewController as! SSWriteViewController

            let nowLocation: CLLocationCoordinate2D = self.currentLocation != nil ? self.currentLocation : self.mainView.camera.target
            vc.writeViewModel.myLatitude = nowLocation.latitude
            vc.writeViewModel.myLongitude = nowLocation.longitude
        }
    }

    @IBAction func switchListViewController(sender: UIStoryboardSegue) {
        print(self.navigationItem.titleView)

        let seg: UISegmentedControl = (self.navigationItem.titleView as? UISegmentedControl)!
        seg.selectedSegmentIndex = 0
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
            self.scrollDetailView.configureWithDatas(self.datasForSsom, currentViewModel: model)
            self.scrollDetailView.changeTheme(.SSOM)
        }
        if self.btnYouPay.selected {
            self.scrollDetailView.ssomType = .SSOSEYO
            self.scrollDetailView.configureWithDatas(self.datasForSsoseyo, currentViewModel: model)
            self.scrollDetailView.changeTheme(.SSOSEYO)
        }

        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.view.addSubview(self.scrollDetailView)
    }

// MARK: - GMSMapViewDelegate

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        locationManager.stopUpdatingLocation()
    }

    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        print("now finished to move the map camera! : \(position)")
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if let model = marker.userData as? SSViewModel {
            self.openDetailView(model)
        }

        return true
    }

// MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let camera: GMSCameraPosition = GMSCameraPosition(target: locations.last!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

        self.currentLocation = camera.target
        mainView.animateToCameraPosition(camera)

        var index: Int = 0;
        for data in self.datasOfAllSsom {
            let latitude: Double = data.latitude
            let longitude: Double = data.longitude

            let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let nowLocation: CLLocationCoordinate2D = camera.target

            let distance: Int = Int(Util.getDistance(locationFrom: nowLocation, locationTo: tempLocation))

            let dataWithDistance: SSViewModel = data
            dataWithDistance.distance = distance
            self.datasOfAllSsom[index] = dataWithDistance

            index += 1
        }

        locationManager.stopUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print(error)
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false

        switch status {
        case CLAuthorizationStatus.Restricted:
            print("Restricted Access to location!!")
        case .Denied:
            print("User denied access to location!!")
        case .NotDetermined:
            print("Status not determined!!")
            locationManager.requestWhenInUseAuthorization()
        default:
            print("Allowed to location access!!")
            shouldIAllow = true
        }

        if (shouldIAllow == true) {
            locationManager.startUpdatingLocation()
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
        self.datas = self.datasOfAllSsom
        self.showMarkers()

        self.lbFilteredAgePeople.text = filterViewModel.ageType.rawValue + ", " + filterViewModel.peopleCountType.rawValue
    }

// MARK: - SSScrollViewDelegate
    func closeScrollView(needToReload: Bool) {

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        if let view = self.scrollDetailView {
            self.navigationController?.navigationBar.barStyle = .Default
            view.removeFromSuperview()

            if needToReload {
                self.initView()
            }
        }
    }

    func openSignIn(completion: ((finish:Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: nil)
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
}

