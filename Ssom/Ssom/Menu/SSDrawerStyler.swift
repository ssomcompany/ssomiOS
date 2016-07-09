//
//  SSDrawerStyler.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 18..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

protocol SSDrawerStyler {
    static func styler() -> SSDrawerStyler
    func styleDrawerViewController(drawerViewController: SSDrawerViewController, paneClosedFraction: CGFloat, forDirection: SSDrawerDirection) -> Void

    func stylerWasAddedToDynamicsDrawerViewController(drawerViewController: SSDrawerViewController, forDirection: SSDrawerDirection) -> Void
    func sylterWasRemovedFromDynamicDrawerViewController(drawerViewController: SSDrawerViewController, forDirection: SSDrawerDirection) -> Void
}

extension SSDrawerStyler {
    func stylerWasAddedToDynamicsDrawerViewController(drawerViewController: SSDrawerViewController, forDirection: SSDrawerDirection) -> Void {

    }
    func sylterWasRemovedFromDynamicDrawerViewController(drawerViewController: SSDrawerViewController, forDirection: SSDrawerDirection) -> Void {

    }
}

class SSDrawerParallaxStyler: SSDrawerStyler {
    var parallaxOffsetFraction: CGFloat = 0.0

    init() {
        self.parallaxOffsetFraction = 0.35
    }

    static func styler() -> SSDrawerStyler {
        return SSDrawerParallaxStyler()
    }

    func styleDrawerViewController(drawerViewController: SSDrawerViewController, paneClosedFraction: CGFloat, forDirection: SSDrawerDirection) {
        let mainRevealWidth: CGFloat = drawerViewController.revealWidthForDirection(forDirection)
        var translate: CGFloat = (mainRevealWidth * paneClosedFraction) * self.parallaxOffsetFraction
        if (forDirection & (SSDrawerDirection.Top | SSDrawerDirection.Left)) != SSDrawerDirection.None {
            translate = -translate;
        }
        var drawerViewTransform: CGAffineTransform = (drawerViewController.drawerView?.transform)!
        if (forDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            drawerViewTransform.tx = CGAffineTransformMakeTranslation(CGFloat(translate), 0).tx
        } else if (forDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            drawerViewTransform.ty = CGAffineTransformMakeTranslation(0.0, CGFloat(translate)).ty;
        } else {
            drawerViewTransform.tx = 0;
            drawerViewTransform.ty = 0;
        }
        drawerViewController.drawerView?.transform = drawerViewTransform;
    }

    func sylterWasRemovedFromDynamicDrawerViewController(drawerViewController: SSDrawerViewController, forDirection: SSDrawerDirection) {
        let translate: CGAffineTransform = CGAffineTransformMakeTranslation(0.0, 0.0)
        var drawerViewTransform: CGAffineTransform = (drawerViewController.drawerView?.transform)!
        drawerViewTransform.tx = translate.tx
        drawerViewTransform.ty = translate.ty
        drawerViewController.drawerView?.transform = drawerViewTransform
    }
}

class SSDrawerFadeStyler: SSDrawerStyler {
    var closeAlpha: CGFloat = 0.0

    static func styler() -> SSDrawerStyler {
        return SSDrawerFadeStyler()
    }

    func styleDrawerViewController(drawerViewController: SSDrawerViewController, paneClosedFraction: CGFloat, forDirection: SSDrawerDirection) {
        if (forDirection & SSDrawerDirection.All) != SSDrawerDirection.None {
            drawerViewController.drawerView?.alpha = (1.0 - self.closeAlpha) * (1.0 - paneClosedFraction)
        } else {
            drawerViewController.drawerView?.alpha = 1.0
        }
    }

    func sylterWasRemovedFromDynamicDrawerViewController(drawerViewController: SSDrawerViewController, forDirection: SSDrawerDirection) {
        drawerViewController.drawerView?.alpha = 1.0
    }
}

class SSDrawerScaleStyler: SSDrawerStyler {
    var closedScale: CGFloat = 0.0

    init() {
        self.closedScale = 0.1
    }

    static func styler() -> SSDrawerStyler {
        return SSDrawerScaleStyler()
    }

    func styleDrawerViewController(drawerViewController: SSDrawerViewController, paneClosedFraction: CGFloat, forDirection: SSDrawerDirection) {
        var scale: CGFloat = 0.0
        if (forDirection & SSDrawerDirection.All) != SSDrawerDirection.None {
            scale = 1.0 - paneClosedFraction * self.closedScale
        } else {
            scale = 1.0
        }
        let scaleTransform: CGAffineTransform = CGAffineTransformMakeScale(scale, scale)
        var drawerViewTransform: CGAffineTransform = (drawerViewController.drawerView?.transform)!
        drawerViewTransform.a = scaleTransform.a
        drawerViewTransform.d = scaleTransform.d
        drawerViewController.drawerView?.transform = drawerViewTransform
    }
}

class SSDrawerResizeStyler: SSDrawerStyler {
    var minimumResizeRevealWidth: CGFloat {
        get {
            return self.minimumResizeRevealWidth
        }
        set {
            if newValue == 0.0 {
                self.useRevealWidthAsMinimumResizeRevealWidth = true
            } else {
                self.useRevealWidthAsMinimumResizeRevealWidth = false
            }
            self.minimumResizeRevealWidth = newValue
        }
    }
    var useRevealWidthAsMinimumResizeRevealWidth: Bool

    init() {
        self.useRevealWidthAsMinimumResizeRevealWidth = true
        self.minimumResizeRevealWidth = 0.0
    }

    static func styler() -> SSDrawerStyler {
        return SSDrawerResizeStyler()
    }

    func styleDrawerViewController(drawerViewController: SSDrawerViewController, paneClosedFraction: CGFloat, forDirection: SSDrawerDirection) {
        if forDirection == SSDrawerDirection.None {
            return
        }

        var drawerViewFrame: CGRect = drawerViewController.drawerViewControllerForDirection(forDirection)!.view.frame
        let minimumResizeRevealWidth: CGFloat = self.useRevealWidthAsMinimumResizeRevealWidth ? drawerViewController.revealWidthForDirection(forDirection) : self.minimumResizeRevealWidth
        if drawerViewController.currentRevealWidth() < minimumResizeRevealWidth {
            drawerViewFrame.size.width = drawerViewController.revealWidthForDirection(forDirection)
        } else {
            if (forDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
                drawerViewFrame.size.width = CGFloat(drawerViewController.currentRevealWidth())
            } else if (forDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
                drawerViewFrame.size.height = CGFloat(drawerViewController.currentRevealWidth())
            }
        }

        let paneViewFrame: CGRect = (drawerViewController.mainView?.frame)!
        switch forDirection {
        case SSDrawerDirection.Right:
            drawerViewFrame.origin.x = CGRectGetMaxX(paneViewFrame)
        case SSDrawerDirection.Bottom:
            drawerViewFrame.origin.y = CGRectGetMaxY(paneViewFrame)
        default:
            break
        }

        drawerViewController.drawerViewControllerForDirection(forDirection)?.view.frame = drawerViewFrame
    }

    func sylterWasRemovedFromDynamicDrawerViewController(drawerViewController: SSDrawerViewController, forDirection: SSDrawerDirection) {
        // Reset the drawer view controller's view to be the size of the drawerView (before the styler was added)
        var drawerViewFrame: CGRect = (drawerViewController.drawerViewControllerForDirection(forDirection)?.view.frame)!
        drawerViewFrame.size = (drawerViewController.drawerView?.frame.size)!
        drawerViewController.drawerViewControllerForDirection(forDirection)?.view.frame = drawerViewFrame
    }

// MARK: - SSDrawerResizeStyler
//    func setMinimumResizeRevealWidth(minimumResizeRevealWidth: Float) -> Void {
//        self.useRevealWidthAsMinimumResizeRevealWidth = false
//        self.minimumResizeRevealWidth = minimumResizeRevealWidth
//    }
}

class SSDrawerShadowStyler: SSDrawerStyler {
    var shadowColor: UIColor = UIColor.blackColor()
    var shadowRadius: CGFloat = 10.0
    var shadowOpacity: CGFloat = 1.0
    var shadowOffset: CGSize = CGSizeZero
    var shadowLayer: CALayer?

    init() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidChangeStatusBarOrientationNotification, object: nil, queue: nil) { (notification) in
            self.shadowLayer?.removeFromSuperlayer()
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    static func styler() -> SSDrawerStyler {
        return SSDrawerShadowStyler()
    }

    func styleDrawerViewController(drawerViewController: SSDrawerViewController, paneClosedFraction: CGFloat, forDirection: SSDrawerDirection) {
        if (forDirection & SSDrawerDirection.All) != SSDrawerDirection.None {
            if self.shadowLayer?.superlayer == nil {
                let paneViewSize: CGSize = (drawerViewController.mainView?.frame.size)!
                var shadowRect: CGRect = CGRectMake(0, 0, paneViewSize.width, paneViewSize.height)
                if (forDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
                    shadowRect = CGRectInset(shadowRect, 0.0, -self.shadowRadius)
                } else if (forDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
                    shadowRect = CGRectInset(shadowRect, -self.shadowRadius, 0.0)
                }
                self.shadowLayer?.shadowPath = UIBezierPath(rect: shadowRect).CGPath
                drawerViewController.mainView?.layer.insertSublayer(self.shadowLayer!, atIndex: 0)
            }
        } else {
            self.shadowLayer?.removeFromSuperlayer()
        }
    }
}