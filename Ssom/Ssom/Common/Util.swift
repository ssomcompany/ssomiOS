//
//  Util.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 8..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation
import UIKit

public class Util {
    class func convertScreenSize(isWidth:Bool, size:Float, fromWidth:Float, fromHeight:Float) -> CGFloat {

        let bounds: CGRect = UIScreen.mainScreen().bounds;

        if (isWidth) {
            return CGFloat(size)*bounds.width/CGFloat(fromWidth);
        } else {
            return CGFloat(size)*bounds.height/CGFloat(fromHeight);
        }
        
    }

    class func getDistanceString(distance: Int) -> String {
        if distance > 1000 {
            let kilometerOfDistance: Double = Double(distance)/1000

            return "\(kilometerOfDistance)km";
        } else {
            return "\(distance)m";
        }
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}