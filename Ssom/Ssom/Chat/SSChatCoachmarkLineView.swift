//
//  SSChatCoachmarkLineView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 8. 16..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatCoachmarkLineView: UIView {

    var lineColor: UIColor = UIColor.whiteColor()
    var lineWidth: CGFloat = 1.2

    var circleLayer: CAShapeLayer!

    init() {
        super.init(frame: CGRectZero)
    }

    convenience init(lineColor: UIColor) {
        self.init()

        self.lineColor = lineColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let path = UIBezierPath(ovalInRect: CGRectMake(-bounds.width, -bounds.height, bounds.width * 2.0 - self.lineWidth / 2.0, bounds.height * 2.0 - self.lineWidth / 2.0))

        self.circleLayer = CAShapeLayer()
        self.circleLayer.path = path.bezierPathByReversingPath().CGPath
        self.circleLayer.fillColor = UIColor.clearColor().CGColor
        self.circleLayer.strokeColor = self.lineColor.CGColor
        self.circleLayer.lineWidth = self.lineWidth

        self.circleLayer.strokeEnd = 0.75

        self.layer.addSublayer(self.circleLayer)
        self.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(ovalInRect: CGRectMake(-bounds.width, -bounds.height, bounds.width * 2.0 - self.lineWidth / 2.0, bounds.height * 2.0 - self.lineWidth / 2.0))

        self.circleLayer = CAShapeLayer()
        self.circleLayer.path = path.bezierPathByReversingPath().CGPath
        self.circleLayer.fillColor = UIColor.clearColor().CGColor
        self.circleLayer.strokeColor = self.lineColor.CGColor
        self.circleLayer.lineWidth = self.lineWidth

        self.circleLayer.strokeEnd = 0.75

        self.layer.addSublayer(self.circleLayer)
        self.layer.masksToBounds = true
    }

    func animateLine(duration: NSTimeInterval) {
        // define the key path to be applied the animtaion
        let animation = CABasicAnimation(keyPath: "strokeEnd")

        // set animation duration
        animation.duration = duration

        // set animating values
        animation.fromValue = 0.75
        animation.toValue = 1.0

        // animatingOption
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        // comletion
        self.circleLayer.strokeEnd = 1.0

        // add animation
        self.circleLayer.addAnimation(animation, forKey: "animateLine")
    }

//    override func drawRect(rect: CGRect) {
//        let path = UIBezierPath(ovalInRect: CGRectMake(-bounds.width, -bounds.height, bounds.width * 2.0, bounds.height * 2.0))
//
//        path.lineWidth = lineWidth
//        self.lineColor.setStroke()
//        path.stroke()
//    }
}
