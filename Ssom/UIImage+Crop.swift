//
//  UIImage+Crop.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 30..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

extension UIImage {
    class func cropInCircle(image: UIImage, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!

        let scaleFactorX = frame.size.width / image.size.width
        let scaleFactorY = frame.size.height / image.size.height

        CGContextBeginPath(context)
        CGContextAddArc(context, frame.size.width/2, frame.size.height/2, frame.size.width/2, 0, CGFloat(2.0 * M_PI), 0)
        CGContextClosePath(context)
        CGContextClip(context)

        CGContextScaleCTM(context, scaleFactorX, scaleFactorY)

        let myRect: CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        image.drawInRect(myRect)

        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}