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

    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D!

    var datasOfAllSsom: [SSViewModel]
    lazy var _datasOfFilteredSsom: [SSViewModel] = []
    var datas: [SSViewModel] {
        get {
            return self._datasOfFilteredSsom
        }
        set {
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
    var datasForSsom: [SSViewModel]
    var datasForSsoseyo: [SSViewModel]

    var isAlreadyWrittenMySsom: Bool = false
    var mySsom: SSViewModel!

    var filterView: SSFilterView!
    var filterModel: SSFilterViewModel? {
        didSet {
            if let tabBarController = self.tabBarController as? SSTabBarController {
                tabBarController.filterModel = self.filterModel
            }
        }
    }
    var scrollDetailView: SSScrollView!

    init() {
        self.datasOfAllSsom = []
        self.datasForSsom = []
        self.datasForSsoseyo = []

        super.init(nibName: nil, bundle: nil)
    }

    convenience init(datas:[[String: AnyObject?]]) {
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

    override func initView() {

        self.isAlreadyWrittenMySsom = false
        self.mySsom = nil

        self.writeButton.transform = CGAffineTransform(translationX: 0, y: 200)

        self.initMapView()

        if let filterView = self.filterView {
            filterView.tapCloseButton()
        }
        self.closeScrollView(false)
    }

    func initMapView() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.startUpdatingLocation()
        }

        mainView.isMyLocationEnabled = true

        mainView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let filterView = self.filterView {
            filterView.tapCloseButton()
        }
    }

    func loadingData(_ completion: ((_ finish: Bool) -> Void)?) {
        print(#function)

        SSNetworkAPIClient
            .getPosts(latitude: self.currentLocation != nil ? self.currentLocation.latitude : 0,
                      longitude: self.currentLocation != nil ? self.currentLocation.longitude : 0,
                      completion: { [weak self] (viewModels, error) -> Void in

                        guard let wself = self else { return }

                        if let err = error {
                            print("error is : \(err.localizedDescription)")

                            wself.showOpenAnimation()

                            SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: wself, completion: { (action) in
                                guard let block = completion else { return }
                                block(false)
                            })

                        } else {
                            if let models = viewModels {
                                wself.datasOfAllSsom = models
                                wself.datas = models
                                print("result is : \(wself.datasOfAllSsom)")
                                
                                wself.showMarkers()

                                wself.saveMainViewModel()
                            }

                            wself.showOpenAnimation()

                            guard let block = completion else { return }
                            block(true)
                        }
                })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        self.getMainViewModel()

        self.initView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.writeButton.transform = CGAffineTransform(translationX: 0, y: 200)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getMainViewModel() {
        if let tabBarController = self.tabBarController as? SSTabBarController {
            if let filterModel = tabBarController.filterModel {
                self.filterModel = filterModel
            }
        }
    }

    func saveMainViewModel() {
        let nowLocation: CLLocationCoordinate2D = self.currentLocation != nil ? self.currentLocation : self.mainView.camera.target
        var ssomTypes: [SSType] = []
        if let mainFilteredSsomTypes = self.filterModel?.ssomType {
            ssomTypes = mainFilteredSsomTypes
        }

        if let tabBarController = self.tabBarController as? SSTabBarController {
            tabBarController.mainViewModel = SSMainViewModel(datas: self.datasOfAllSsom, ssomTypes: ssomTypes, nowLatitude: nowLocation.latitude, nowLongitude: nowLocation.longitude)

            if let filterModel = self.filterModel {
                tabBarController.filterModel = filterModel
            }
        }
    }

    func showOpenAnimation() {

        self.setMySsomButton()

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.writeButton.transform = CGAffineTransform.identity
        }) { (finish) in
            //
        }
    }

    func setMySsomButton() {

        if self.isAlreadyWrittenMySsom {
            self.writeButton.setImage(UIImage(named: "myBtn"), for: UIControlState())
        } else {
            self.writeButton.setImage(UIImage(named: "writeBtn"), for: UIControlState())
        }
    }

    func showCurrentLocation() {
        locationManager.startUpdatingLocation()
    }

    var loadCompletionBlock: (() -> Void)?

    func showMarkers() {

        self.mainView.clear()
        self.datasForSsom = []
        self.datasForSsoseyo = []

        var index: Int = 0;
        for data in self.datas {
            if let loginedUserId = SSAccountManager.sharedInstance.userUUID {
                if loginedUserId == data.userId {
                    self.isAlreadyWrittenMySsom = true
                    self.mySsom = data
                } else {
                    self.isAlreadyWrittenMySsom = self.isAlreadyWrittenMySsom || false
                }
            }

            let latitude: Double = data.latitude 
            let longitude: Double = data.longitude 

            let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let nowLocation: CLLocationCoordinate2D = self.currentLocation != nil ? self.currentLocation : mainView.camera.target

            let distance: Int = Int(Util.getDistance(locationFrom: nowLocation, locationTo: tempLocation))

            let dataWithDistance: SSViewModel = data
            dataWithDistance.distance = distance
            self.datas[index] = dataWithDistance
            
            index += 1

            let sellString: String = data.ssomType.rawValue
            let isSell = sellString == SSType.SSOM.rawValue

            let setMarkerBlock: () -> Void = {
                if isSell {
                    self.datasForSsom.append(data)
                    if let imageUrl:String = data.imageUrl {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: imageUrl)
                    } else {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: nil)
                    }
                } else {
                    self.datasForSsoseyo.append(data)
                    if let imageUrl:String = data.imageUrl {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: imageUrl)
                    } else {
                        self.setMarker(data, isSell, latitude, longitude, imageUrl: nil)
                    }
                }
            }

            if let filter = self.filterModel {
                if filter.ssomType == [.SSOM] {
                    setMarkerBlock()
                } else if filter.ssomType == [.SSOSEYO] {
                    setMarkerBlock()
                } else {
                    setMarkerBlock()
                }
            } else {
                setMarkerBlock()
            }
        }

        guard let completion = self.loadCompletionBlock else { return }
        completion()
    }

    func setMarker(_ data: SSViewModel, _ isSell: Bool, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, imageUrl: String!) {
        let marker = GMSMarker()
        marker.userData = data;
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)

        let maskOfProfileImage: UIImage = UIImage.resizeImage(UIImage.init(named: isSell ? "miniGreen" : "miniRed")!, frame: CGRect(x: 0, y: 0, width: 56.2, height: 64.9))

        if imageUrl != nil && imageUrl.lengthOfBytes(using: String.Encoding.utf8) != 0 {
            SDWebImageManager.shared().downloadImage(with: URL(string: imageUrl+"?thumbnail=200"), options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, error, cacheType, finish, imageURL) in
                marker.icon = maskOfProfileImage

                if image != nil {
                    let croppedProfileImage: UIImage = UIImage.cropInCircle(image!, frame: CGRect(x: 0, y: 0, width: 51.6, height: 51.6))

                    marker.icon = UIImage.mergeImages(firstImage: croppedProfileImage, secondImage: maskOfProfileImage, x:2.3, y:2.3)

                    if data.meetRequestStatus == .Accepted {
                        if isSell {
                            marker.icon = UIImage.mergeImages(firstImage: marker.icon!, secondImage: UIImage(named: "ssomIngGreen")!, x: 2.3, y: 2.3, isFirstPoint: false)
                        } else {
                            marker.icon = UIImage.mergeImages(firstImage: marker.icon!, secondImage: UIImage(named: "ssomIngRed")!, x: 2.3, y: 2.3, isFirstPoint: false)
                        }
                    }
                }
            })
        } else {
            marker.icon = maskOfProfileImage
        }
        marker.map = self.mainView
    }

    @IBAction func tapMyLocationButton(_ sender: AnyObject) {
        self.showCurrentLocation()
    }

    @IBAction func tapFilter(_ sender: AnyObject? = nil) {

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
            let transformZ: CATransform3D = CATransform3DMakeTranslation(0.0, 0.0, -self.writeButton.bounds.width * 2)
            let transform: CATransform3D = CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 1.0, 0.0)

            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.writeButton.layer.transform = CATransform3DConcat(transformZ, transform)
                }, completion: { (finish) in
                    self.openDetailView(self.mySsom)
                    self.writeButton.layer.transform = CATransform3DIdentity
            })
        } else {
            let transform: CGAffineTransform = CGAffineTransform(rotationAngle: CGFloat(M_PI * 45.0 / 180.0))

            UIView.animate(withDuration: 0.3, animations: {
                self.writeButton.transform = transform
            }, completion: { (finish) in
                if SSAccountManager.sharedInstance.isAuthorized {
                    self.performSegue(withIdentifier: "SSWriteViewSegueFromMain", sender: nil)
                } else {
                    SSAccountManager.sharedInstance.openSignIn(self, completion: { (finish) in
                        if finish {
                            self.loadingData(nil)
                        } else {
                            self.showOpenAnimation()
                        }
                    })
                }
            }) 
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "SSWriteViewSegueFromMain") {
            let vc: SSWriteViewController = segue.destination as! SSWriteViewController

            let nowLocation: CLLocationCoordinate2D = self.currentLocation != nil ? self.currentLocation : self.mainView.camera.target
            vc.writeViewModel.myLatitude = nowLocation.latitude
            vc.writeViewModel.myLongitude = nowLocation.longitude
        }
    }

    @IBAction func switchListViewController(_ sender: UIStoryboardSegue) {
        print(self.navigationItem.titleView!)

        let seg: UISegmentedControl = (self.navigationItem.titleView as? UISegmentedControl)!
        seg.selectedSegmentIndex = 0
    }

    func openDetailView(_ model: SSViewModel) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = false
        }

        self.scrollDetailView = UIView.loadFromNibNamed("SSDetailView", className: SSScrollView.self) as! SSScrollView
        self.scrollDetailView.frame = UIScreen.main.bounds
        self.scrollDetailView.delegate = self

        if let filter = self.filterModel {
            self.scrollDetailView.ssomTypes = filter.ssomType
            self.scrollDetailView.configureWithDatas(self.datas, currentViewModel: model)
            self.scrollDetailView.changeTheme(filter.ssomType)
        } else {
            self.scrollDetailView.ssomTypes = [.SSOM, .SSOSEYO]
            self.scrollDetailView.configureWithDatas(self.datasOfAllSsom, currentViewModel: model)
            self.scrollDetailView.changeTheme([.SSOM, .SSOSEYO])
        }

        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.view.addSubview(self.scrollDetailView)
    }

// MARK: - GMSMapViewDelegate

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        locationManager.stopUpdatingLocation()
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("now finished to move the map camera! : \(position)")
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let model = marker.userData as? SSViewModel {
            self.openDetailView(model)
        }

        return true
    }

// MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let camera: GMSCameraPosition = GMSCameraPosition(target: locations.last!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

        self.currentLocation = camera.target
        self.mainView.animate(to: camera)

        self.loadingData { (finish) in
            if finish {

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
            }
        }

        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        print(error)

        self.loadingData { (finish) in
            if finish {

                var index: Int = 0;
                for data in self.datasOfAllSsom {
                    let latitude: Double = data.latitude
                    let longitude: Double = data.longitude

                    let tempLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let nowLocation: CLLocationCoordinate2D = self.mainView.camera.target

                    let distance: Int = Int(Util.getDistance(locationFrom: nowLocation, locationTo: tempLocation))

                    let dataWithDistance: SSViewModel = data
                    dataWithDistance.distance = distance
                    self.datasOfAllSsom[index] = dataWithDistance

                    index += 1
                }
            }
        }
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
        self.datas = self.datasOfAllSsom
        self.showMarkers()

        self.view.makeToast("쏨 필터가 적용 되었습니다 =)", duration: 2.0, position: CGPoint(x: UIScreen.main.bounds.width / 2.0, y: 104))
    }

// MARK: - SSScrollViewDelegate
    func closeScrollView(_ needToReload: Bool) {

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isDrawable = true
        }

        if let view = self.scrollDetailView {
            self.navigationController?.navigationBar.barStyle = .default
            view.removeFromSuperview()

            self.loadCompletionBlock = nil

            if needToReload {
                self.initView()
            }
        }
    }

    func openSignIn(_ completion: ((_ finish:Bool) -> Void)?) {
        SSAccountManager.sharedInstance.openSignIn(self, completion: nil)
    }

    func doSsom(_ ssomType: SSType, model: SSViewModel) {
        if let token = SSAccountManager.sharedInstance.sessionToken {
            if model.postId != "" {
                // 나랑 채팅중인 쏨이면..
                if let chatroomId = model.assignedChatroomId {
                    self.goChat(chatroomId: chatroomId, model: model, ssomType: ssomType)
                } else {
                    SSNetworkAPIClient.postChatroom(token, postId: model.postId, latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude, completion: { (chatroomId, error) in

                        if let err = error {
                            print(err.localizedDescription)

                            SSAlertController.alertConfirm(title: "Error", message: err.localizedDescription, vc: self, completion: nil)
                        } else {
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

