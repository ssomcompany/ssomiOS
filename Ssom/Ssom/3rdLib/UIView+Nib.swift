//
//  UIView+Nib.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 30..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }

    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil, owner: AnyObject) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(owner, options: nil)[0] as? UIView
    }

    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil, className: AnyClass) -> UIView? {
        let loadedViews = UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil, options: nil)
        for loadedView in loadedViews {
            if loadedView.dynamicType === className {
                return loadedView as? UIView
            }
        }

        return nil
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
