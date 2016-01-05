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

enum SStype : String {
    case SSOM = "ssom"
    case SSOSEYO = "ssoseyo"
}

class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, SSFilterViewDelegate {
    @IBOutlet var mainView: GMSMapView!
    @IBOutlet var writeButton: UIButton!
    @IBOutlet var myLocationButton: UIButton!
    @IBOutlet var btnIPay: UIButton!
    @IBOutlet var imageIPayButtonLineView: UIImageView!
    @IBOutlet var btnYouPay: UIButton!
    @IBOutlet var imageYouPayButtonLineView: UIImageView!
    
    var locationManager: CLLocationManager!
    var dataArray: [[String: AnyObject]]

    var filterView: SSFilterView!

    init() {
        self.dataArray = []

        super.init(nibName: nil, bundle: nil)
    }

    convenience init(dataArray:[[String: AnyObject]]) {
        self.init()

        self.dataArray = dataArray
    }

    required init?(coder aDecoder: NSCoder) {
        self.dataArray = []

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
        SSNetworkAPIClient.getPosts { (responseObject) -> Void in
            wSelf!.dataArray = responseObject as! [[String: AnyObject]]
            print("result is : \(wSelf!.dataArray)")

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
        let titleBackgroundView: UIImageView = UIImageView(image: UIImage(named: "toggle_bg_w.png"))
        titleBackgroundView.frame = CGRectMake(0, 0, 263.7/2.0, 57.3/2.0)

        self.navigationItem.titleView!.addSubview(titleBackgroundView)
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

        for dataDict in self.dataArray {
            let latitude: Double = dataDict["latitude"] as! CLLocationDegrees
            let longitude: Double = dataDict["longitude"] as! CLLocationDegrees

            print("position is \(latitude), \(longitude)")

            let sellString: String = dataDict["ssom"] as! String
            var isSell = false;
            if sellString == SStype.SSOM.rawValue {
                isSell = true
            } else {
                isSell = false
            }

            if self.btnIPay.selected {
                if isSell {
                    self.setMarker(isSell, latitude, longitude, imageUrl: dataDict["imageUrl"] as! String)
                }
            }

            if self.btnYouPay.selected {
                if !isSell {
                    self.setMarker(isSell, latitude, longitude, imageUrl: dataDict["imageUrl"] as! String)
                }
            }
        }
    }

    func setMarker(isSell: Bool, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, imageUrl: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)

        Alamofire.request(.GET, imageUrl)
            .responseData { (response) -> Void in
                let profileImage: UIImage = UIImage(data: response.data!)!
                let croppedProfileImage: UIImage = UIImage.cropInCircle(profileImage, frame: CGRectMake(0, 0, 51.6, 51.6))

                let maskOfProfileImage: UIImage = UIImage.resizeImage(UIImage.init(named: isSell ? "miniRed.png" : "miniGreen.png")!, frame: CGRectMake(0, 0, 56.2, 64.9))

                marker.icon = UIImage.mergeImages(croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)
                marker.map = self.mainView
        }
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

            vc.dataArray = self.dataArray
        }
    }

    func getDistance(locationFrom: CLLocationCoordinate2D, locationTo: CLLocationCoordinate2D) -> Double {

        let location1: CLLocation = CLLocation(latitude: locationFrom.latitude, longitude: locationFrom.longitude)
        let location2: CLLocation = CLLocation(latitude: locationTo.latitude, longitude: locationTo.longitude)

        return location2.distanceFromLocation(location1)
    }

// MARK: - GMSMapViewDelegate
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        locationManager.stopUpdatingLocation()
    }

    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        print("now finished to move the map camera! : \(position)")

        var index: Int = 0;
        for dataDict in self.dataArray {
            let latitude: Double = dataDict["latitude"] as! CLLocationDegrees
            let longitude: Double = dataDict["longitude"] as! CLLocationDegrees

            let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let nowLocation: CLLocationCoordinate2D = self.mainView.camera.target

            let distance: Int = Int(self.getDistance(nowLocation, locationTo: tempLocation))

            var dataDictWithDistance: Dictionary = dataDict
            dataDictWithDistance["distance"] = distance
            self.dataArray[index] = dataDictWithDistance
            
            index++
        }
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
}

