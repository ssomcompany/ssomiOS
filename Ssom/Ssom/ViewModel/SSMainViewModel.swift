//
//  SSMainViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 10..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

enum SSType : String {
    case SSOM = "ssom"
    case SSOSEYO = "ssoseyo"
}

public struct SSMainViewModel {
    var datas: [[String: AnyObject]]

    var isSell: Bool

    var nowLatitude: Double
    var nowLongitude: Double

    init() {
        self.datas = []
        self.isSell = true
        self.nowLatitude = 0
        self.nowLongitude = 0
    }

    init(datas:[[String: AnyObject]], isSell: Bool) {
        self.datas = datas
        self.isSell = isSell
        self.nowLatitude = 0
        self.nowLongitude = 0
    }

    init(datas:[[String: AnyObject]], isSell: Bool, nowLatitude: Double, nowLongitude: Double) {
        self.datas = datas
        self.isSell = isSell
        self.nowLatitude = nowLatitude
        self.nowLongitude = nowLongitude
    }
}
