//
//  SSChatMapViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 9. 3..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit
import GoogleMaps
import SDWebImage

class SSChatMapViewController: SSDetailViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var lbDistance: UILabel!

    var barButtonItems: SSNavigationBarItems!

    var locationManager: CLLocationManager!
    var data: SSChatMapViewModel!

    var blockCancelToMeet: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarView()

        self.initView()
    }

    func initView() {
        self.initMapView()

        let dataObject = SSModelToObjectConverter<SSChatMapViewModel>(value: self.data)
        self.setMarker(dataObject, isSell: self.data.ssomType == .SSOM, self.data.partnerLatitude, self.data.partnerLongitude, imageUrl: self.data.partnerImageUrl)
    }

    func initMapView() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.startUpdatingLocation()
        }

        mapView.myLocationEnabled = true

        mapView.delegate = self
    }

    func setNavigationBarView() {

        self.barButtonItems = SSNavigationBarItems(animated: true)

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), forControlEvents: UIControlEvents.TouchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = "채팅으로 돌아가기"
        var backButtonFrame = self.barButtonItems.backBarButtonView.frame
        backButtonFrame.size.width = 165
        self.barButtonItems.backBarButtonView.frame = backButtonFrame

        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

//        let naviTitleView: UILabel = UILabel(frame: CGRectMake(0, 0, 150, 44))
//        if #available(iOS 8.2, *) {
//            naviTitleView.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
//        } else {
//            // Fallback on earlier versions
//            naviTitleView.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
//        }
//        naviTitleView.textAlignment = .Center
//        naviTitleView.text = "Chat"
//        naviTitleView.sizeToFit()
//        self.navigationItem.titleView = naviTitleView;

        let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        barButtonSpacer.width = -10

        self.barButtonItems.btnMeetRequest.addTarget(self, action: #selector(tapCancelToMeetRequest), forControlEvents: UIControlEvents.TouchUpInside)
        var isRequestedToMeet: Bool = false
        self.barButtonItems.changeMeetRequest(&isRequestedToMeet)
        let meetRequestButton = UIBarButtonItem(customView: barButtonItems.meetRequestButtonView!)

        self.navigationItem.rightBarButtonItems = [barButtonSpacer, meetRequestButton]
    }

    func setMarker(data: AnyObject?, isSell: Bool, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, imageUrl: String!) {
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
        marker.map = self.mapView
    }

    func tapBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func tapCancelToMeetRequest() {
        print("tapped meet request!!")

        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .CurveLinear, animations: {
            self.barButtonItems.imgViewMeetRequest.transform = CGAffineTransformIdentity
        }) { (finish) in
            SSAlertController.alertTwoButton(title: "알림", message: "만남을 정말 취소하시겠어요?\n취소시 채팅방으로 돌아갑니다.", vc: self, button1Title: "만남 취소", button2Title: "닫기", button1Completion: { (action) in

                guard let block = self.blockCancelToMeet else {
                    self.tapBack()
                    return
                }

                block()

                self.tapBack()

            }) { (action) in
                //
            }
        }
    }

    // MARK: - GMSMapViewDelegate

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        locationManager.stopUpdatingLocation()
    }

    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        print("now finished to move the map camera! : \(position)")

        locationManager.startUpdatingLocation()
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        return true
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let camera: GMSCameraPosition = GMSCameraPosition(target: locations.last!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

        mapView.animateToCameraPosition(camera)

        locationManager.stopUpdatingLocation()

        // caculate the distance from partner to me
        let latitude: Double = self.data.partnerLatitude
        let longitude: Double = self.data.partnerLongitude

        let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let nowLocation: CLLocationCoordinate2D = camera.target

        let distance: Int = Int(Util.getDistance(locationFrom: nowLocation, locationTo: tempLocation))

        self.lbDistance.text = Util.getDistanceString(distance)
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()

        print(error)
        
        self.lbDistance.text = "알 수 없음"
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
