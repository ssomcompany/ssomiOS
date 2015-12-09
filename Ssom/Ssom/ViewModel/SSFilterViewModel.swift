//
//  SSFilterViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 12. 8..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

enum SSFilterPayType {
    case All
    case IPay
    case YouPay
}

public struct SSFilterViewModel {
    var payType: SSFilterPayType

    var minPerson: Int
    var maxPerson: Int

    var minAge: Int
    var maxAge: Int
}