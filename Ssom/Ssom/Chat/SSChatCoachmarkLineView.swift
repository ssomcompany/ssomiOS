//
//  SSChatCoachmarkLineView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 8. 16..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatCoachmarkLineView: UIView {

    var lineColor: UIColor = UIColor.white
    var lineWidth: CGFloat = 1.2

    var circleLayer: CAShapeLayer!

    init() {
        super.init(frame: CGRect.zero)
    }

    convenience init(lineColor: UIColor) {
        self.init()

        self.lineColor = lineColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let path = UIBezierPath(ovalIn: CGRect(x: -bounds.width, y: -bounds.height, width: bounds.width * 2.0 - self.lineWidth / 2.0, height: bounds.height * 2.0 - self.lineWidth / 2.0))

        self.circleLayer = CAShapeLayer()
        self.circleLayer.path = path.reversing().cgPath
        self.circleLayer.fillColor = UIColor.clear.cgColor
        self.circleLayer.strokeColor = self.lineColor.cgColor
        self.circleLayer.lineWidth = self.lineWidth

        self.circleLayer.strokeEnd = 0.75

        self.layer.addSublayer(self.circleLayer)
        self.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(ovalIn: CGRect(x: -bounds.width, y: -bounds.height, width: bounds.width * 2.0 - self.lineWidth / 2.0, height: bounds.height * 2.0 - self.lineWidth / 2.0))

        self.circleLayer = CAShapeLayer()
        self.circleLayer.path = path.reversing().cgPath
        self.circleLayer.fillColor = UIColor.clear.cgColor
        self.circleLayer.strokeColor = self.lineColor.cgColor
        self.circleLayer.lineWidth = self.lineWidth

        self.circleLayer.strokeEnd = 0.75

        self.layer.addSublayer(self.circleLayer)
        self.layer.masksToBounds = true
    }

    func animateLine(_ duration: TimeInterval) {
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
        self.circleLayer.add(animation, forKey: "animateLine")
    }

//    override func drawRect(rect: CGRect) {
//        let path = UIBezierPath(ovalInRect: CGRectMake(-bounds.width, -bounds.height, bounds.width * 2.0, bounds.height * 2.0))
//
//        path.lineWidth = lineWidth
//        self.lineColor.setStroke()
//        path.stroke()
//    }
}
