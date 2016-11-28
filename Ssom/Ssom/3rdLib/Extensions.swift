//
//  Extensions.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 11. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

extension NSMutableSet {
    func union(with otherSet: NSSet) {
        for other in otherSet {
            if !self.contains(other) {
                self.add(other)
            }
        }
    }
}
