//
//  UIImage+Crop.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 30..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

extension UIImage {
    class func resizeImage(image: UIImage, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.mainScreen().scale)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!

        let scaleFactorX = frame.size.width / image.size.width
        let scaleFactorY = frame.size.height / image.size.height

        CGContextScaleCTM(context, scaleFactorX, scaleFactorY)

        let myRect: CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        image.drawInRect(myRect)

        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    class func cropInCircle(image: UIImage, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.mainScreen().scale)
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

    class func mergeImages(firstImage: UIImage, secondImage: UIImage, x: CGFloat, y: CGFloat) -> UIImage {

        let firstImageWidth: CGFloat = firstImage.size.width
        let firstImageHeight: CGFloat = firstImage.size.height

        let secondImageWidth: CGFloat = secondImage.size.width
        let secondImageHeight: CGFloat = secondImage.size.height

        let mergedSize: CGSize = CGSizeMake(firstImageWidth >= secondImageWidth ? firstImageWidth : secondImageWidth
                                        , firstImageHeight >= secondImageHeight ? firstImageHeight : secondImageHeight)

        UIGraphicsBeginImageContextWithOptions(mergedSize, false, UIScreen.mainScreen().scale)

        firstImage.drawInRect(CGRectMake(x, y, CGFloat(firstImageWidth), CGFloat(firstImageHeight)))
        secondImage.drawInRect(CGRectMake(0, 0, CGFloat(secondImageWidth), CGFloat(secondImageHeight)))

        let mergedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()

        return mergedImage
    }
}