//
//  SSFilterViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 12. 8..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

@objc public class SSFilterViewModel: NSObject {
    var ageType: SSAgeType

    var personCount: Int = 0

    init(ageType: SSAgeType, personCount: Int) {
        self.ageType = ageType
        self.personCount = personCount
    }
}