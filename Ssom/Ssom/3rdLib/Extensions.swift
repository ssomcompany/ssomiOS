//
//  Extensions.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 11. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation
import CoreLocation

extension NSMutableSet {
    func union(with otherSet: NSSet) {
        for other in otherSet {
            if !self.contains(other) {
                self.add(other)
            }
        }
    }
}

func == (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool {
    return (left.latitude == right.latitude) && (left.longitude == right.longitude)
}
