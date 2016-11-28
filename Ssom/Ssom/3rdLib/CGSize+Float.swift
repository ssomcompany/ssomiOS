//
//  CGSize+Float.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 27..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

extension CGSize {
    init(width: Float, height: Float) {
        self.width = CGFloat(width)
        self.height = CGFloat(height)
    }
}

public func CGRectMakeWithScreenRatio(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, criteria: DeviceType) -> CGRect {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    switch criteria {
    case .iPhone4, .iPhone4S:
        let factorWidth = UIScreen.main.bounds.width / 320.0
        let factorHeight = UIScreen.main.bounds.height / 480.0
        return CGRect(x: x * factorWidth, y: y * factorHeight, width: width * factorWidth, height: height * factorHeight)
    case .iPhone5, .iPhone5C, .iPhone5S:
        let factorWidth = UIScreen.main.bounds.width / 320.0
        let factorHeight = UIScreen.main.bounds.height / 568.0
        return CGRect(x: x * factorWidth, y: y * factorHeight, width: width * factorWidth, height: height * factorHeight)
    case .iPhone6, .iPhone6S:
        let factorWidth = UIScreen.main.bounds.width / 375.0
        let factorHeight = UIScreen.main.bounds.height / 667.0
        return CGRect(x: x * factorWidth, y: y * factorHeight, width: width * factorWidth, height: height * factorHeight)
    case .iPhone6Plus, .iPhone6SPlus:
        let factorWidth = UIScreen.main.bounds.width / 414.0
        let factorHeight = UIScreen.main.bounds.height / 736.0
        return CGRect(x: x * factorWidth, y: y * factorHeight, width: width * factorWidth, height: height * factorHeight)
    default:
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

public enum Axis {
    case x
    case y
}

public func CGFloatWithScreenRatio(_ point: CGFloat, axis: Axis, criteria: DeviceType) -> CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return point
    }

    switch criteria {
    case .iPhone4, .iPhone4S:
        if axis == .x {
            return point * UIScreen.main.bounds.width / 320.0
        } else {
            return point * UIScreen.main.bounds.height / 480.0
        }
    case .iPhone5, .iPhone5C, .iPhone5S:
        if axis == .x {
            return point * UIScreen.main.bounds.width / 320.0
        } else {
            return point * UIScreen.main.bounds.height / 568.0
        }
    case .iPhone6, .iPhone6S:
        if axis == .x {
            return point * UIScreen.main.bounds.width / 375.0
        } else {
            return point * UIScreen.main.bounds.height / 667.0
        }
    case .iPhone6Plus, .iPhone6SPlus:
        if axis == .x {
            return point * UIScreen.main.bounds.width / 414.0
        } else {
            return point * UIScreen.main.bounds.height / 736.0
        }
    default:
        return point
    }
}
