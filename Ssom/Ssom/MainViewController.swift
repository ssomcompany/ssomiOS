//
//  ViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 1..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, SSFilterViewDelegate, SSDetailViewDelegate {
    @IBOutlet var mainView: GMSMapView!
    @IBOutlet var writeButton: UIButton!
    @IBOutlet var myLocationButton: UIButton!
    @IBOutlet var btnIPay: UIButton!
    @IBOutlet var imageIPayButtonLineView: UIImageView!
    @IBOutlet var btnYouPay: UIButton!
    @IBOutlet var imageYouPayButtonLineView: UIImageView!
    
    var locationManager: CLLocationManager!
    var datas: [SSViewModel]

    var filterView: SSFilterView!
    var detailView: SSDetailView!

    var barButtonItems: SSNavigationBarItems!

    init() {
        self.datas = []

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

        super.init(coder: aDecoder)
    }

    func initView() {

        initMapView()

        loadingData()
    }

    func initMapView() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.startUpdatingLocation()
        }

        mainView.myLocationEnabled = true
//        mainView.settings.myLocationButton = true

        mainView.delegate = self
    }

    func showCurrentLocation() {
        locationManager.startUpdatingLocation()
    }

    func loadingData() {
        weak var wSelf: MainViewController? = self
        SSNetworkAPIClient.getPosts { (viewModels) -> Void in
            wSelf!.datas = viewModels
            print("result is : \(wSelf!.datas)")

            wSelf!.showMarkers()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.setNavigationBarView()
    }

    func setNavigationBarView() {
        var naviTitleViewFrame:CGRect = self.navigationItem.titleView!.frame
        naviTitleViewFrame = CGRectMake(naviTitleViewFrame.origin.x, naviTitleViewFrame.origin.y
                                        , naviTitleViewFrame.size.width, 38)
        self.navigationItem.titleView!.frame = naviTitleViewFrame

        let titleBackgroundView: UIImageView = UIImageView(image: UIImage(named: "1dep_toggle_on.png"))
        titleBackgroundView.frame = CGRectMake(0, 0, 175, 38)
        self.navigationItem.titleView!.addSubview(titleBackgroundView)

        let btnNavi1: UIButton = UIButton(frame: CGRectMake(0, 0, 97, 38))
        btnNavi1.setTitle("MAP", forState: .Normal)
        btnNavi1.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        btnNavi1.setBackgroundImage(UIImage(named: "1dep_toggle_off.png"), forState: .Selected)
        btnNavi1.selected = true
        self.navigationItem.titleView!.addSubview(btnNavi1)

        let btnNavi2: UIButton = UIButton(frame: CGRectMake(175-97, 0, 97, 38))
        btnNavi2.setTitle("LIST", forState: .Normal)
        btnNavi2.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1), forState: .Normal)
        btnNavi2.selected = false
        self.navigationItem.titleView!.addSubview(btnNavi2)

        if #available(iOS 8.2, *) {
            btnNavi1.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
            btnNavi2.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        } else {
            // Fallback on earlier versions
            btnNavi1.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
            btnNavi2.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        }

        self.navigationItem.leftBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem?.image = UIImage.resizeImage(UIImage(named: "manu.png")!, frame: CGRectMake(0, 0, 21, 14))

        var rightBarButtonItems: Array = self.navigationItem.rightBarButtonItems!
        if rightBarButtonItems.count == 2 {
            self.barButtonItems = SSNavigationBarItems()

            let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            barButtonSpacer.width = 20

            barButtonItems.btnHeartBar.addTarget(rightBarButtonItems[1].target, action: rightBarButtonItems[1].action, forControlEvents: UIControlEvents.TouchUpInside)
            let heartBarButton = UIBarButtonItem(customView: barButtonItems.heartBarButtonView!)

            barButtonItems.btnMessageBar.addTarget(rightBarButtonItems[0].target, action: rightBarButtonItems[0].action, forControlEvents: UIControlEvents.TouchUpInside)
            let messageBarButton = UIBarButtonItem(customView: barButtonItems.messageBarButtonView!)

            self.navigationItem.rightBarButtonItems = [messageBarButton, barButtonSpacer, heartBarButton]
        }
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

        for data in self.datas {
            let latitude: Double = data.latitude 
            let longitude: Double = data.longitude 

            print("position is \(latitude), \(longitude)")

            let sellString: String = data.ssomType.rawValue
            var isSell = false;
            if sellString == SSType.SSOM.rawValue {
                isSell = true
            } else {
                isSell = false
            }

            if self.btnIPay.selected {
                if isSell {
                    if let imageUrl:String = data.imageUrl {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: imageUrl)
                    } else {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: nil)
                    }
                }
            }

            if self.btnYouPay.selected {
                if !isSell {
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

        if imageUrl != nil {
            Alamofire.request(.GET, imageUrl)
                .responseData { (response) -> Void in

                    if let profileImage: UIImage = UIImage(data: response.data!)! {
                        let croppedProfileImage: UIImage = UIImage.cropInCircle(profileImage, frame: CGRectMake(0, 0, 51.6, 51.6))

                        marker.icon = UIImage.mergeImages(firstImage: croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)
                    } else {
                        marker.icon = maskOfProfileImage
                    }
            }
        } else {
            marker.icon = maskOfProfileImage
        }
        marker.map = self.mainView
    }

    @IBAction func tapMyLocationButton(sender: AnyObject) {
        showCurrentLocation()
    }

    @IBAction func tapFilter(sender: AnyObject) {

        self.filterView = UIView.loadFromNibNamed("SSFilterView") as! SSFilterView
        self.filterView.frame = self.view.bounds
        self.filterView.delegate = self
        self.view.addSubview(self.filterView)
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

// MARK: - GMSMapViewDelegate
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        locationManager.stopUpdatingLocation()
    }

    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        print("now finished to move the map camera! : \(position)")

        var index: Int = 0;
        for data in self.datas {
            let latitude: Double = data.latitude
            let longitude: Double = data.longitude

            let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let nowLocation: CLLocationCoordinate2D = self.mainView.camera.target

            let distance: Int = Int(Util.getDistance(locationFrom: nowLocation, locationTo: tempLocation))

            var dataWithDistance: SSViewModel = data
            dataWithDistance.distance = distance
            self.datas[index] = dataWithDistance
            
            index++
        }
    }

    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        self.detailView = UIView.loadFromNibNamed("SSDetailView") as! SSDetailView
        self.detailView.frame = self.view.bounds
        self.detailView.delegate = self
        if self.btnIPay.selected {
            self.detailView.changeTheme(.SSOM)
        }
        if self.btnYouPay.selected {
            self.detailView.changeTheme(.SSOSEYO)
        }
        self.detailView.configureWithViewModel(marker.userData as! SSViewModel)

        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.view.addSubview(self.detailView)

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

// MARK: - SSDetailViewDelegate
    func closeDetailView() {
        self.navigationController?.navigationBar.barStyle = .Default
        self.detailView.removeFromSuperview()
    }
}
