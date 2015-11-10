//
//  ViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 1..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet var mainView: UIView!
    var mapView: MTMapView!

    func initView() {
        mapView = MTMapView(frame: CGRect(x: 0, y: 0, width: mainView.frame.size.width, height: mainView.frame.size.height));
        mapView.setDaumMapApiKey("44b94066997fabf50c91f08311aefc43");
        
        mainView.addSubview(mapView);
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
}

