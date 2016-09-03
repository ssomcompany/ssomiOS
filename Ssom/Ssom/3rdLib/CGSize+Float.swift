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
    switch criteria {
    case .IPhone4, .IPhone4S:
        let factorWidth = UIScreen.mainScreen().bounds.width / 320.0
        let factorHeight = UIScreen.mainScreen().bounds.height / 480.0
        return CGRectMake(x * factorWidth, y * factorHeight, width * factorWidth, height * factorHeight)
    case .IPhone5, .IPhone5C, .IPhone5S:
        return CGRectMake(x, y, UIScreen.mainScreen().bounds.width * width / 320.0, UIScreen.mainScreen().bounds.height * height / 568.0)
    case .IPhone6, .IPhone6S:
        return CGRectMake(x, y, UIScreen.mainScreen().bounds.width * width / 375.0, UIScreen.mainScreen().bounds.height * height / 667.0)
    case .IPhone6Plus, .IPhone6SPlus:
        return CGRectMake(x, y, UIScreen.mainScreen().bounds.width * width / 414.0, UIScreen.mainScreen().bounds.height * height / 736.0)
    default:
        return CGRectMake(x, y, width, height)
    }
}

public enum Axis {
    case X
    case Y
}

public func CGFloatWithScreenRatio(point: CGFloat, axis: Axis, criteria: DeviceType) -> CGFloat {
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