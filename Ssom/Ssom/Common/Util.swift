//
//  Util.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 8..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

public class Util {
    class func convertScreenSize(isWidth:Bool, size:Float, fromWidth:CGFloat, fromHeight:CGFloat) -> CGFloat {

        let bounds: CGRect = UIScreen.mainScreen().bounds;

        if (isWidth) {
            return CGFloat(size)*bounds.width/CGFloat(fromWidth);
        } else {
            return CGFloat(size)*bounds.height/CGFloat(fromHeight);
        }
        
    }

    class func convertScreenCGSize(size:CGSize, fromWidth:CGFloat, fromHeight:CGFloat) -> CGSize {
        let width:CGFloat = convertScreenSize(true, size: Float(size.width), fromWidth: fromWidth, fromHeight: fromHeight)
        let height:CGFloat = convertScreenSize(false, size: Float(size.height), fromWidth: fromWidth, fromHeight: fromHeight)

        return CGSizeMake(width, height)
    }

    class func getDistanceString(distance: Int) -> String {
        if distance > 1000 {
            let kilometerOfDistance: Double = Double(distance)/1000

            return "\(kilometerOfDistance)km";
        } else {
            return "\(distance)m";
        }
    }

    class func getDistance(locationFrom locationFrom: CLLocationCoordinate2D, locationTo: CLLocationCoordinate2D) -> Double {

        let location1: CLLocation = CLLocation(latitude: locationFrom.latitude, longitude: locationFrom.longitude)
        let location2: CLLocation = CLLocation(latitude: locationTo.latitude, longitude: locationTo.longitude)

        return location2.distanceFromLocation(location1)
    }

    class func getAgeArea(age: Int) -> SSAgeType {
        if age >= SSAgeType.AgeEarly20.rawValue && (age < SSAgeType.AgeMiddle20.rawValue) {
            return .AgeEarly20
        }
        if age >= SSAgeType.AgeMiddle20.rawValue && age < SSAgeType.AgeLate20.rawValue {
            return .AgeMiddle20
        }
        if age >= SSAgeType.AgeLate20.rawValue && age < SSAgeType.Age30.rawValue {
            return .AgeLate20
        }
        return .Age30
    }

    class func getAgeArea(age: Int) -> SSAgeAreaType {
        if age >= SSAgeType.AgeEarly20.rawValue && (age < SSAgeType.AgeMiddle20.rawValue) {
            return .AgeEarly20
        }
        if age >= SSAgeType.AgeMiddle20.rawValue && age < SSAgeType.AgeLate20.rawValue {
            return .AgeMiddle20
        }
        if age >= SSAgeType.AgeLate20.rawValue && age < SSAgeType.Age30.rawValue {
            return .AgeLate20
        }
        return .Age30
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