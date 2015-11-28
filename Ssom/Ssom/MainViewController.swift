//
//  ViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 1..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import GoogleMaps

class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet var mainView: GMSMapView!
    var locationManager: CLLocationManager!
    var dataArray: [[String: AnyObject]]

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
        mainView.settings.myLocationButton = true

        showCurrentLocation()
    }

    func showCurrentLocation() {
        locationManager.startUpdatingLocation()
    }

    func loadingData() {
        weak var wSelf = self
        SSNetworkAPIClient.getPosts { (responseObject) -> Void in
            wSelf!.dataArray = responseObject as! [[String: AnyObject]]
            print("result is : \(wSelf!.dataArray)")

            for dataDict in wSelf!.dataArray {
                print("position is \(dataDict["latitude"]), \(dataDict["longitude"])")
                wSelf!.setMarker(dataDict["latitude"] as! CLLocationDegrees, dataDict["longitude"] as! CLLocationDegrees)
            }
        }
    }

    func setMarker(latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
        marker.map = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

// MARK: - GMSMapViewDelegate
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        locationManager.stopUpdatingLocation()
    }

// MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let camera: GMSCameraPosition = GMSCameraPosition(target: locations.last!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

        mainView.camera = camera

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
}

