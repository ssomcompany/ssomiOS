//
//  SSFilterViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 12. 8..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

@objc public class SSFilterViewModel: NSObject {
    var ageType: SSAgeAreaType

    var peopleCountType: SSPeopleCountStringType

    init(ageType: SSAgeAreaType, peopleCount: SSPeopleCountStringType) {
        self.ageType = ageType
        self.peopleCountType = peopleCount
    }
}