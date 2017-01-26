//
//  SSIndicatorView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 27..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

public struct SSIndicatorView {
    let indicatorView: UIActivityIndicatorView
    let indicatorBackgroundView: UIView
    let indicatorRoundView: UIView

    init() {
        self.indicatorBackgroundView = UIView(frame: UIScreen.main.bounds)
        self.indicatorBackgroundView.backgroundColor = UIColor.clear

        self.indicatorRoundView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        self.indicatorRoundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.indicatorRoundView.layer.cornerRadius = 10

        self.indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)

        self.indicatorBackgroundView.addSubview(self.indicatorRoundView)
        self.indicatorBackgroundView.addSubview(self.indicatorView)

        self.indicatorRoundView.center = self.indicatorBackgroundView.center
        self.indicatorView.center = self.indicatorBackgroundView.center
    }

    func showIndicator() -> Void {
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {

            self.indicatorBackgroundView.removeFromSuperview()

            if let window = appDelegate.window {
                window.addSubview(self.indicatorBackgroundView)
                self.indicatorBackgroundView.center = window.center
                self.indicatorBackgroundView.bringSubview(toFront: (window.rootViewController?.view)!)
            }

            self.indicatorView.startAnimating()
        }
    }

    func hideIndicator() -> Void {
        self.indicatorView.stopAnimating()

        self.indicatorBackgroundView.removeFromSuperview()
    }
}
