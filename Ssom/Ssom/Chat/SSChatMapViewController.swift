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

    var myMarker: GMSMarker!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarView()

        self.initView()
    }

    override func initView() {

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        self.initMapView()

        let dataObject = SSModelToObjectConverter<SSChatMapViewModel>(value: self.data)
        self.setMarker(dataObject, isSell: self.data.ssomType == .SSOM, self.data.partnerLatitude, self.data.partnerLongitude, imageUrl: self.data.partnerImageUrl)
    }

    func initMapView() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.startUpdatingLocation()
        }

        self.mapView.isMyLocationEnabled = true

        self.mapView.delegate = self
    }

    func setNavigationBarView() {

        self.barButtonItems = SSNavigationBarItems(animated: true)

        self.barButtonItems.btnBack.addTarget(self, action: #selector(tapBack), for: UIControlEvents.touchUpInside)
        self.barButtonItems.lbBackButtonTitle.text = "채팅으로 돌아가기"
        var backButtonFrame = self.barButtonItems.backBarButtonView.frame
        backButtonFrame.size.width = 165
        self.barButtonItems.backBarButtonView.frame = backButtonFrame

        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: barButtonItems.backBarButtonView), animated: true)

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

        let barButtonSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        barButtonSpacer.width = -10

        self.barButtonItems.btnMeetRequest.addTarget(self, action: #selector(tapCancelToMeetRequest), for: UIControlEvents.touchUpInside)
        self.barButtonItems.changeMeetRequest(self.data.meetRequestedStatus)
        let meetRequestButton = UIBarButtonItem(customView: barButtonItems.meetRequestButtonView!)

        self.navigationItem.rightBarButtonItems = [barButtonSpacer, meetRequestButton]
    }

    func applicationDidEnterBackground(_ sender: Notification?) {
        self.locationManager.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(_ sender: Notification?) {
        self.locationManager.startUpdatingLocation()
    }

    func setMarker(_ data: AnyObject?, isSell: Bool, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, imageUrl: String!) -> GMSMarker {
        let marker = GMSMarker()
        marker.userData = data;
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)

        let borderOfProfileImage: UIImage = UIImage.resizeImage(UIImage(named: isSell ? "miniGreen" : "miniRed")!, frame: CGRect(x: 0, y: 0, width: 56.2, height: 64.9))
        let coverOfProfileImage: UIImage = UIImage.resizeImage(UIImage(named: isSell ? "ssomIngGreen" : "ssomIngRed")!, frame: CGRect(x: 0, y: 0, width: 56.2, height: 56.2))
        let maskOfProfileImage: UIImage = UIImage.mergeImages(firstImage: coverOfProfileImage, secondImage: borderOfProfileImage, x: 0, y: 0)

        if imageUrl != nil && imageUrl.lengthOfBytes(using: String.Encoding.utf8) != 0 {
            SDWebImageManager.shared().downloadImage(with: URL(string: imageUrl+"?thumbnail=200"), options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, error, cacheType, finish, imageURL) in

                marker.icon = maskOfProfileImage

                if image != nil {
                    let croppedProfileImage: UIImage = UIImage.cropInCircle(image!, frame: CGRect(x: 0, y: 0, width: 51.6, height: 51.6))

                    marker.icon = UIImage.mergeImages(firstImage: croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)
                }
            })
        } else {
            marker.icon = maskOfProfileImage
        }
        marker.map = self.mapView

        return marker
    }

    func tapBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func tapCancelToMeetRequest() {
        print("tapped meet request!!")

        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.barButtonItems.imgViewMeetRequest.transform = CGAffineTransform.identity
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

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        locationManager.stopUpdatingLocation()
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("now finished to move the map camera! : \(position)")

        locationManager.startUpdatingLocation()
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // caculate the distance from partner to me
        let latitude: Double = self.data.partnerLatitude
        let longitude: Double = self.data.partnerLongitude

        let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let nowLocation: CLLocationCoordinate2D = locations.last!.coordinate

        if self.myMarker != nil {
            self.myMarker.map = nil
        }
        self.myMarker = self.setMarker(nil, isSell: self.data.ssomType != .SSOM, nowLocation.latitude, nowLocation.longitude, imageUrl: nil)

        let distance: Int = Int(Util.getDistance(locationFrom: nowLocation, locationTo: tempLocation))

        self.lbDistance.text = Util.getDistanceString(distance)

        let middleLocation = CLLocationCoordinate2D(latitude: (latitude + nowLocation.latitude) / 2.0, longitude: (longitude + nowLocation.longitude) / 2.0)
//        let camera: GMSCameraPosition = GMSCameraPosition(target: middleLocation, zoom: 15, bearing: 0, viewingAngle: 0)
//        mapView.animateToCameraPosition(camera)

        var mapBounds = GMSCoordinateBounds()
        mapBounds = mapBounds.includingCoordinate(tempLocation)
        mapBounds = mapBounds.includingCoordinate(middleLocation)
        mapBounds = mapBounds.includingCoordinate(nowLocation)
        mapView.animate(with: GMSCameraUpdate.fit(mapBounds, withPadding: 50.0))

        locationManager.stopUpdatingLocation()

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()

        print(error)
        
        self.lbDistance.text = "알 수 없음"
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false

        switch status {
        case CLAuthorizationStatus.restricted:
            print("Restricted Access to location!!")
        case .denied:
            print("User denied access to location!!")
        case .notDetermined:
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
