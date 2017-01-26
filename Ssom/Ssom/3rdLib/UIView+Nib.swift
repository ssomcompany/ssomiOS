//
//  UIView+Nib.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 30..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

extension UIView {
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }

    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil, owner: AnyObject) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: owner, options: nil)[0] as? UIView
    }

    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil, className: AnyClass) -> UIView? {
        let loadedViews = UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil)
        for loadedView in loadedViews {
            if type(of: (loadedView) as AnyObject) === className {
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
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
