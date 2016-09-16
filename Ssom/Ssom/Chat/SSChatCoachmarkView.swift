//
//  SSChatCoachmarkView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 24..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSChatCoachmarkView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var viewHeartRound: UIView!
    @IBOutlet var lbGuideText: UILabel!
    @IBOutlet var imgViewLineToUpArrow: UIImageView!
    @IBOutlet var viewChatCoachmarkLine: SSChatCoachmarkLineView!
    @IBOutlet var imgViewUpArrow: UIImageView!

    var closeBlock: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.configView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.animateDraw(0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

//        NSBundle.mainBundle().loadNibNamed("SSChatCoachmarkView", owner: self, options: nil)
    }

    func configView() {
        self.layoutIfNeeded()
        self.viewHeartRound.layer.cornerRadius = self.viewHeartRound.bounds.height / 2.0
    }

    func animateDraw(duration: NSTimeInterval) {
        self.layoutIfNeeded()
        self.viewChatCoachmarkLine.animateLine(duration)

        let radius = self.imgViewUpArrow.bounds.height / 2.0
        let startingRect = CGRect(x: radius, y: radius, width: 0, height: 0)
        let startingPath = UIBezierPath(ovalInRect: startingRect)
        let finishingPath = UIBezierPath(ovalInRect: CGRectInset(startingRect, -radius, -radius))
//        let startingRect = CGRect(x: self.imgViewUpArrow.bounds.minX, y: self.imgViewUpArrow.bounds.maxY, width: self.imgViewUpArrow.bounds.width, height: 0)
//        let startingPath = UIBezierPath(rect: startingRect)
//        let finishingPath = UIBezierPath(rect: CGRectInset(startingRect, 0, -self.imgViewUpArrow.bounds.height))

        let maskLayer = CAShapeLayer()

        self.imgViewUpArrow.layer.mask = maskLayer

        let animation = CABasicAnimation(keyPath: "path")

        animation.fromValue = startingPath.CGPath
        animation.toValue = finishingPath.CGPath

        animation.duration = duration
//        animation.mass = 1.0
//        animation.stiffness = 100.0
//        animation.damping = 100
//        animation.initialVelocity = 1.0

        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)

        maskLayer.path = finishingPath.CGPath

        maskLayer.addAnimation(animation, forKey: "animationMaskForImageUpArrow")

        self.imgViewUpArrow.layoutIfNeeded()

        let finishingPoint = self.imgViewUpArrow.layer.position

        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: finishingPoint.x - self.viewChatCoachmarkLine.bounds.width, y: finishingPoint.y + self.viewChatCoachmarkLine.bounds.height))
        path.addCurveToPoint(finishingPoint, controlPoint1: CGPoint(x: 295.6, y: 191.7), controlPoint2: CGPoint(x: finishingPoint.x, y: 145.3))

        let movingAnimation = CAKeyframeAnimation(keyPath: "position")
//            let movingAnimation = CABasicAnimation(keyPath: "position")

        movingAnimation.path = path.CGPath
//            movingAnimation.fromValue = NSValue(CGPoint: CGPoint(x: finishingPoint.x - self.viewChatCoachmarkLine.bounds.width, y: finishingPoint.y + self.viewChatCoachmarkLine.bounds.height))
//            movingAnimation.toValue = NSValue(CGPoint: finishingPoint)

        movingAnimation.duration = 0.5

        movingAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)

        self.imgViewUpArrow.layer.addAnimation(movingAnimation, forKey: "animationMovingForImageUpArrow")
    }

    @IBAction func tapStartChat(sender: AnyObject) {
        self.removeFromSuperview()

        guard let close = self.closeBlock else {
            return
        }

        close()
    }
}
