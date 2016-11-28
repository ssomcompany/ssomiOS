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
    static func convertScreenSize(_ isWidth:Bool, size:Float, fromWidth:CGFloat, fromHeight:CGFloat) -> CGFloat {

        let bounds: CGRect = UIScreen.main.bounds;

        if (isWidth) {
            return CGFloat(size)*bounds.width/CGFloat(fromWidth);
        } else {
            return CGFloat(size)*bounds.height/CGFloat(fromHeight);
        }
        
    }

    static func convertScreenCGSize(_ size:CGSize, fromWidth:CGFloat, fromHeight:CGFloat) -> CGSize {
        let width:CGFloat = convertScreenSize(true, size: Float(size.width), fromWidth: fromWidth, fromHeight: fromHeight)
        let height:CGFloat = convertScreenSize(false, size: Float(size.height), fromWidth: fromWidth, fromHeight: fromHeight)

        return CGSize(width: width, height: height)
    }

    static func getDateString(_ date: Date) -> String {
        let nowDate: Date = Date()

        let userCalendar = Calendar.current
        let calendarComponents: NSCalendar.Unit = [.year, .day, .minute]
        let dateDifference = (userCalendar as NSCalendar).components(calendarComponents, from: date, to: nowDate, options: [])
        let dateComponents = (userCalendar as NSCalendar).components(calendarComponents, from: date)
        let nowDateComponents = (userCalendar as NSCalendar).components(calendarComponents, from: nowDate)

        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "kr_KR")
        dateFormatter.amSymbol = "오전"
        dateFormatter.pmSymbol = "오후"
        if dateComponents.day == nowDateComponents.day {
            if dateDifference.minute! <= 1 {
                return "방금 전"
            } else {
                dateFormatter.dateFormat = "a h:mm"
                return dateFormatter.string(from: date)
            }
        } else {
            if dateComponents.year == nowDateComponents.year {
                dateFormatter.dateFormat = "M월 d일"
                return dateFormatter.string(from: date)
            } else {
                dateFormatter.dateFormat = "yyyy년 M월 d일"
                return dateFormatter.string(from: date)
            }
        }
    }

    static func getTimeIntervalString(from fromDate: Date, to toDate: Date = Date(), format: String = "HH:mm") -> (String, Int, Int) {

        let userCalendar = Calendar.current
        let calendarComponents: NSCalendar.Unit = [.hour, .minute, .second]
        let expiredDate = Date(timeInterval: SSDefaultHeartRechargeTimeInterval, since: fromDate)
        let expiredDateDifference = (userCalendar as NSCalendar).components(calendarComponents, from: toDate, to: expiredDate, options: [])

        return  ("\(String(format: "%02d", expiredDateDifference.hour!)):\(String(format: "%02d", expiredDateDifference.minute!))", expiredDateDifference.hour!, expiredDateDifference.minute!)
    }

    static func getDistanceString(_ distance: Int) -> String {
        if distance > 1000 {
            let kilometerOfDistance: Double = Double(distance)/1000

            return String(format: "%.2fkm", kilometerOfDistance)
        } else {
            return "\(distance)m";
        }
    }

    static func getDistance(locationFrom: CLLocationCoordinate2D, locationTo: CLLocationCoordinate2D) -> Double {

        let location1: CLLocation = CLLocation(latitude: locationFrom.latitude, longitude: locationFrom.longitude)
        let location2: CLLocation = CLLocation(latitude: locationTo.latitude, longitude: locationTo.longitude)

        return location2.distance(from: location1)
    }

    static func getAgeArea(_ age: UInt) -> SSAgeType {
        if age >= SSAgeType.ageEarly20.rawValue && (age < SSAgeType.ageMiddle20.rawValue) {
            return .ageEarly20
        }
        if age >= SSAgeType.ageMiddle20.rawValue && age < SSAgeType.ageLate20.rawValue {
            return .ageMiddle20
        }
        if age >= SSAgeType.ageLate20.rawValue && age < SSAgeType.age30.rawValue {
            return .ageLate20
        }
        if age >= SSAgeType.age30.rawValue && age < SSAgeType.unknown.rawValue {
            return .age30
        }
        return .unknown
    }

    static func getAgeArea(_ age: UInt) -> SSAgeAreaType {
        if age >= SSAgeType.ageEarly20.rawValue && (age < SSAgeType.ageMiddle20.rawValue) {
            return .AgeEarly20
        }
        if age >= SSAgeType.ageMiddle20.rawValue && age < SSAgeType.ageLate20.rawValue {
            return .AgeMiddle20
        }
        if age >= SSAgeType.ageLate20.rawValue && age < SSAgeType.age30.rawValue {
            return .AgeLate20
        }
        if age >= SSAgeType.age30.rawValue && age < SSAgeType.unknown.rawValue {
            return .Age30
        }
        return .Unknown
    }

    static func isValidEmail(_ testStr:String) -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        let result = emailTest.evaluate(with: testStr)

        return result
        
    }

    enum SSByteUnit: UInt {
        case giga = 0, mega, kilo, byte
    }

    static func getImageCacheSize(_ option: SSByteUnit) -> String {
        let size: UInt = SDImageCache.shared().getSize()

        switch option {
        case .giga:
            return String(format: "%.2f GB", (Double(size) / 1024.0 / 1024.0 / 1024.0))
        case .mega:
            return String(format: "%.2f MB", (Double(size) / 1024.0 / 1024.0))
        case .kilo:
            return String(format: "%.2f kB", (Double(size) / 1024.0))
        case .byte:
            return "\(Double(size)) bytes"
        }
    }

    static func getFBLoginButtonTitle(_ button: UIButton) -> String? {
        
        if button.parentViewController is SSSignInViewController {
            return "로그인"
        }

        if button.parentViewController is SSSignUpViewController {
            return "가입하기"
        }

        return nil
    }
}
