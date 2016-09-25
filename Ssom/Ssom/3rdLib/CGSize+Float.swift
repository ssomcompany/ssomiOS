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

public func CGRectMakeWithScreenRatio(x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, criteria: DeviceType) -> CGRect {
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    switch criteria {
    case .IPhone4, .IPhone4S:
        let factorWidth = UIScreen.mainScreen().bounds.width / 320.0
        let factorHeight = UIScreen.mainScreen().bounds.height / 480.0
        return CGRectMake(x * factorWidth, y * factorHeight, width * factorWidth, height * factorHeight)
    case .IPhone5, .IPhone5C, .IPhone5S:
        let factorWidth = UIScreen.mainScreen().bounds.width / 320.0
        let factorHeight = UIScreen.mainScreen().bounds.height / 568.0
        return CGRectMake(x * factorWidth, y * factorHeight, width * factorWidth, height * factorHeight)
    case .IPhone6, .IPhone6S:
        let factorWidth = UIScreen.mainScreen().bounds.width / 375.0
        let factorHeight = UIScreen.mainScreen().bounds.height / 667.0
        return CGRectMake(x * factorWidth, y * factorHeight, width * factorWidth, height * factorHeight)
    case .IPhone6Plus, .IPhone6SPlus:
        let factorWidth = UIScreen.mainScreen().bounds.width / 414.0
        let factorHeight = UIScreen.mainScreen().bounds.height / 736.0
        return CGRectMake(x * factorWidth, y * factorHeight, width * factorWidth, height * factorHeight)
    default:
        return CGRectMake(x, y, width, height)
    }
}

public enum Axis {
    case X
    case Y
}

public func CGFloatWithScreenRatio(point: CGFloat, axis: Axis, criteria: DeviceType) -> CGFloat {
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        return point
    }

    switch criteria {
    case .IPhone4, .IPhone4S:
        if axis == .X {
            return point * UIScreen.mainScreen().bounds.width / 320.0
        } else {
            return point * UIScreen.mainScreen().bounds.height / 480.0
        }
    case .IPhone5, .IPhone5C, .IPhone5S:
        if axis == .X {
            return point * UIScreen.mainScreen().bounds.width / 320.0
        } else {
            return point * UIScreen.mainScreen().bounds.height / 568.0
        }
    case .IPhone6, .IPhone6S:
        if axis == .X {
            return point * UIScreen.mainScreen().bounds.width / 375.0
        } else {
            return point * UIScreen.mainScreen().bounds.height / 667.0
        }
    case .IPhone6Plus, .IPhone6SPlus:
        if axis == .X {
            return point * UIScreen.mainScreen().bounds.width / 414.0
        } else {
            return point * UIScreen.mainScreen().bounds.height / 736.0
        }
    default:
        return point
    }
}
