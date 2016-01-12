//
//  SSFilterViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 12. 8..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

enum SSFilterAgeType {
    case k20begin
    case k20middle
    case k20late
    case k30over
}

public struct SSFilterViewModel {
    var ageType: SSFilterAgeType

    var personCount: Int
}