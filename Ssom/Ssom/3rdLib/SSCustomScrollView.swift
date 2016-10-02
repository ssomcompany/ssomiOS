//
//  SSCustomScrollView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 10. 2..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

class SSCustomScrollView: UIScrollView {
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view is UIButton {
            return true
        }

        return super.touchesShouldCancelInContentView(view)
    }
}
