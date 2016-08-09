//
//  MapViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 1..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, SSFilterViewDelegate, SSScrollViewDelegate {
    @IBOutlet var mainView: GMSMapView!
    @IBOutlet var writeButton: UIButton!
    @IBOutlet var myLocationButton: UIButton!
    @IBOutlet var btnIPay: UIButton!
    @IBOutlet var imageIPayButtonLineView: UIImageView!
    @IBOutlet var btnYouPay: UIButton!
    @IBOutlet var imageYouPayButtonLineView: UIImageView!

    @IBOutlet var viewBottomInfo: UIView!
    @IBOutlet var viewFilterBackground: UIView!
    @IBOutlet var lbFilteredAgePeople: UILabel!
    @IBOutlet var constBottomInfoViewHeight: NSLayoutConstraint!
    @IBOutlet var constBottomInfoViewTrailingToSuper: NSLayoutConstraint!
    
    var locationManager: CLLocationManager!
    var datas: [SSViewModel]
    var datasForSsom: [SSViewModel]
    var datasForSsoseyo: [SSViewModel]

    var filterView: SSFilterView!
    var scrollDetailView: SSScrollView!

    init() {
        self.datas = []
        self.datasForSsom = []
        self.datasForSsoseyo = []

        super.init(nibName: nil, bundle: nil)
    }

    convenience init(datas:[[String: AnyObject!]]) {
        self.init()

        for data in datas {
            let viewModel = SSViewModel.init(modelDict: data)

            self.datas.append(viewModel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.datas = []
        self.datasForSsom = []
        self.datasForSsoseyo = []

        super.init(coder: aDecoder)
    }

    func initView() {

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

    func showCurrentLocation() {
        locationManager.startUpdatingLocation()
    }

    func loadingData() {
        SSNetworkAPIClient.getPosts { [unowned self] (viewModels, error) -> Void in
            if let models = viewModels {
                self.datas = models
                print("result is : \(self.datas)")

                self.showMarkers()
            } else {
                print("error is : \(error?.localizedDescription)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        self.writeButton.transform = CGAffineTransformIdentity

        self.loadingData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func showMarkers() {

        mainView.clear()

        var index: Int = 0;
        for data in self.datas {
            let latitude: Double = data.latitude 
            let longitude: Double = data.longitude 

            print("position is \(latitude), \(longitude)")

            let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let nowLocation: CLLocationCoordinate2D = self.mainView.camera.target

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
            Alamofire.request(.GET, imageUrl)
                .responseData { (response) -> Void in

                    marker.icon = maskOfProfileImage

                    if let data = response.data {
                        if let profileImage: UIImage = UIImage(data: data) {
                            let croppedProfileImage: UIImage = UIImage.cropInCircle(profileImage, frame: CGRectMake(0, 0, 51.6, 51.6))

                            marker.icon = UIImage.mergeImages(firstImage: croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)
                        }
                    }
            }
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
        self.btnIPay.selected = true
        self.imageIPayButtonLineView.hidden = false
        self.btnYouPay.selected = false
        self.imageYouPayButtonLineView.hidden = true

        self.showMarkers()
    }

    @IBAction func tapYouPayButton(sender: AnyObject) {
        self.btnYouPay.selected = true
        self.imageIPayButtonLineView.hidden = true
        self.btnIPay.selected = false
        self.imageYouPayButtonLineView.hidden = false

        self.showMarkers()
    }

    @IBAction func tapWriteButton(sender: AnyObject) {

        let transform: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI * 45.0 / 180.0))

        UIView.animateWithDuration(0.3, animations: {
            self.writeButton.transform = transform
        }) { (finish) in
            self.performSegueWithIdentifier("SSWriteViewSegueFromMain", sender: nil)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "SSListViewSegue") {
            let vc: ListViewController = segue.destinationViewController as! ListViewController

            let nowLocation: CLLocationCoordinate2D = self.mainView.camera.target
            vc.mainViewModel = SSMainViewModel(datas: self.datas, isSell: self.btnIPay.selected, nowLatitude: nowLocation.latitude, nowLongitude: nowLocation.longitude)
        }

        if (segue.identifier == "SSWriteViewSegueFromMain") {
            let vc: SSWriteViewController = segue.destinationViewController as! SSWriteViewController

            let nowLocation: CLLocationCoordinate2D = self.mainView.camera.target
            vc.writeViewModel.myLatitude = nowLocation.latitude
            vc.writeViewModel.myLongitude = nowLocation.longitude
        }
    }

    @IBAction func switchListViewController(sender: UIStoryboardSegue) {
        print(self.navigationItem.titleView)

        let seg: UISegmentedControl = (self.navigationItem.titleView as? UISegmentedControl)!
        seg.selectedSegmentIndex = 0
    }

// MARK: - GMSMapViewDelegate

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        locationManager.stopUpdatingLocation()
    }

    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        print("now finished to move the map camera! : \(position)")

        var index: Int = 0;
        for data in self.datas {
            let latitude: Double = data.latitude
            let longitude: Double = data.longitude

            let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let nowLocation: CLLocationCoordinate2D = self.mainView.camera.target

            let distance: Int = Int(Util.getDistance(locationFrom: nowLocation, locationTo: tempLocation))

            let dataWithDistance: SSViewModel = data
            dataWithDistance.distance = distance
            self.datas[index] = dataWithDistance
            
            index += 1
        }
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        self.scrollDetailView = UIView.loadFromNibNamed("SSDetailView", className: SSScrollView.self) as! SSScrollView
        self.scrollDetailView.frame = UIScreen.mainScreen().bounds
        self.scrollDetailView.delegate = self

        if self.btnIPay.selected {
            self.scrollDetailView.ssomType = .SSOM
            self.scrollDetailView.configureWithDatas(self.datasForSsom, currentViewModel: marker.userData as? SSViewModel)
            self.scrollDetailView.changeTheme(.SSOM)
        }
        if self.btnYouPay.selected {
            self.scrollDetailView.ssomType = .SSOSEYO
            self.scrollDetailView.configureWithDatas(self.datasForSsoseyo, currentViewModel: marker.userData as? SSViewModel)
            self.scrollDetailView.changeTheme(.SSOSEYO)
        }

        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.view.addSubview(self.scrollDetailView)

        return true
    }

// MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let camera: GMSCameraPosition = GMSCameraPosition(target: locations.last!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

        mainView.animateToCameraPosition(camera)

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
        self.filterView.removeFromSuperview()
    }

    func applyFilter(filterViewModel: SSFilterViewModel) {
        self.filterView.removeFromSuperview()

        // apply filter value to get the ssom list
    }

// MARK: - SSScrollViewDelegate
    func closeScrollView() {
        self.navigationController?.navigationBar.barStyle = .Default
        self.scrollDetailView.removeFromSuperview()
    }

    func openSignIn(completion: ((finish:Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: nil)
    }

    func doSsom(ssomType: SSType, postId: String, partnerImageUrl: String?) {
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
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                })
            }
        }
    }
}

