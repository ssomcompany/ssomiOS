//
//  Util.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 8..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation
import UIKit

public class Util {
    class func convertScreenSize(isWidth:Bool, size:Float, fromWidth:Float, fromHeight:Float) -> CGFloat {

        let bounds: CGRect = UIScreen.mainScreen().bounds;

        if (isWidth) {
            return CGFloat(size)*bounds.width/CGFloat(fromWidth);
        } else {
            return CGFloat(size)*bounds.height/CGFloat(fromHeight);
        }
        
    }
}
