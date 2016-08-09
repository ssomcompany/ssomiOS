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
import SDWebImage

public struct Util {
    static func convertScreenSize(isWidth:Bool, size:Float, fromWidth:CGFloat, fromHeight:CGFloat) -> CGFloat {

        let bounds: CGRect = UIScreen.mainScreen().bounds;

        if (isWidth) {
            return CGFloat(size)*bounds.width/CGFloat(fromWidth);
        } else {
            return CGFloat(size)*bounds.height/CGFloat(fromHeight);
        }
        
    }

    static func convertScreenCGSize(size:CGSize, fromWidth:CGFloat, fromHeight:CGFloat) -> CGSize {
        let width:CGFloat = convertScreenSize(true, size: Float(size.width), fromWidth: fromWidth, fromHeight: fromHeight)
        let height:CGFloat = convertScreenSize(false, size: Float(size.height), fromWidth: fromWidth, fromHeight: fromHeight)

        return CGSizeMake(width, height)
    }

    static func getDateString(date: NSDate) -> String {
        let nowDate: NSDate = NSDate()

        let userCalendar = NSCalendar.currentCalendar()
        let calendarComponents: NSCalendarUnit = [.Year, .Day, .Minute]
        let dateDifference = userCalendar.components(calendarComponents, fromDate: date, toDate: nowDate, options: [])
        let dateComponents = userCalendar.components(calendarComponents, fromDate: date)
        let nowDateComponents = userCalendar.components(calendarComponents, fromDate: nowDate)

        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "kr_KR")
        dateFormatter.AMSymbol = "오전"
        dateFormatter.PMSymbol = "오후"
        if dateComponents.day == nowDateComponents.day {
            if dateDifference.minute <= 1 {
                return "방금 전"
            } else {
                dateFormatter.dateFormat = "a h:mm"
                return dateFormatter.stringFromDate(date)
            }
        } else {
            if dateComponents.year == nowDateComponents.year {
                dateFormatter.dateFormat = "M월 d일"
                return dateFormatter.stringFromDate(date)
            } else {
                dateFormatter.dateFormat = "yyyy년 M월 d일"
                return dateFormatter.stringFromDate(date)
            }
        }
    }

    static func getDistanceString(distance: Int) -> String {
        if distance > 1000 {
            let kilometerOfDistance: Double = Double(distance)/1000

            return String(format: "%.2fkm", kilometerOfDistance)
        } else {
            return "\(distance)m";
        }
    }

    static func getDistance(locationFrom locationFrom: CLLocationCoordinate2D, locationTo: CLLocationCoordinate2D) -> Double {

        let location1: CLLocation = CLLocation(latitude: locationFrom.latitude, longitude: locationFrom.longitude)
        let location2: CLLocation = CLLocation(latitude: locationTo.latitude, longitude: locationTo.longitude)

        return location2.distanceFromLocation(location1)
    }

    static func getAgeArea(age: Int) -> SSAgeType {
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

    static func getAgeArea(age: Int) -> SSAgeAreaType {
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

    static func isValidEmail(testStr:String) -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        let result = emailTest.evaluateWithObject(testStr)

        return result
        
    }

    enum SSByteUnit: UInt {
        case Giga = 0, Mega, Kilo, Byte
    }

    static func getImageCacheSize(option: SSByteUnit) -> String {
        let size: UInt = SDImageCache.sharedImageCache().getSize()

        switch option {
        case .Giga:
            return String(format: "%.2f GB", (Double(size) / 1024.0 / 1024.0 / 1024.0))
        case .Mega:
            return String(format: "%.2f MB", (Double(size) / 1024.0 / 1024.0))
        case .Kilo:
            return String(format: "%.2f kB", (Double(size) / 1024.0))
        case .Byte:
            return "\(Double(size)) bytes"
        }
    }
}