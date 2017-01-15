//
//  UIImage+Crop.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 30..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

extension UIImage {
    class func resizeImage(_ image: UIImage, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        let scaleFactorX = frame.size.width / image.size.width
        let scaleFactorY = frame.size.height / image.size.height

        context.scaleBy(x: scaleFactorX, y: scaleFactorY)

        let myRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: myRect)

        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }

    class func cropInCircle(_ image: UIImage, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        let scaleFactorX = frame.size.width / image.size.width
        let scaleFactorY = frame.size.height / image.size.height

        context.beginPath()
        context.addArc(center: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: frame.size.width/2, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: false)
        context.closePath()
        context.clip()

        if scaleFactorX > scaleFactorY {
            context.scaleBy(x: scaleFactorX, y: scaleFactorX)

            let myRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            image.draw(in: myRect)
        } else if scaleFactorX < scaleFactorY {
            context.scaleBy(x: scaleFactorY, y: scaleFactorY)

            let myRect: CGRect = CGRect(x: (image.size.height - image.size.width) / 2.0, y: 0, width: image.size.width, height: image.size.height)
            image.draw(in: myRect)
        } else {
            context.scaleBy(x: scaleFactorX, y: scaleFactorY)

            let myRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            image.draw(in: myRect)
        }

        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }

    class func mergeImages(firstImage: UIImage, secondImage: UIImage, x: CGFloat, y: CGFloat, isFirstPoint: Bool = true, isKeepFirstSize: Bool = false) -> UIImage {

        let firstImageWidth: CGFloat = firstImage.size.width
        let firstImageHeight: CGFloat = firstImage.size.height

        let secondImageWidth: CGFloat = secondImage.size.width
        let secondImageHeight: CGFloat = secondImage.size.height

        if isKeepFirstSize {
            UIGraphicsBeginImageContextWithOptions(firstImage.size, false, UIScreen.main.scale)
        } else {
            let mergedSize: CGSize = CGSize(width: firstImageWidth >= secondImageWidth ? firstImageWidth : secondImageWidth
                , height: firstImageHeight >= secondImageHeight ? firstImageHeight : secondImageHeight)

            UIGraphicsBeginImageContextWithOptions(mergedSize, false, UIScreen.main.scale)
        }

        if isFirstPoint {
            firstImage.draw(in: CGRect(x: x, y: y, width: CGFloat(firstImageWidth), height: CGFloat(firstImageHeight)))
            secondImage.draw(in: CGRect(x: 0, y: 0, width: CGFloat(secondImageWidth), height: CGFloat(secondImageHeight)))
        } else {
            firstImage.draw(in: CGRect(x: 0, y: 0, width: CGFloat(firstImageWidth), height: CGFloat(firstImageHeight)))
            secondImage.draw(in: CGRect(x: x, y: y, width: CGFloat(secondImageWidth), height: CGFloat(secondImageHeight)))
        }

        let mergedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        return mergedImage
    }
}
