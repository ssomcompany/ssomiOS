//
//  SSMainViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 10..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

enum SStype : String {
    case SSOM = "ssom"
    case SSOSEYO = "ssoseyo"
}

public struct SSMainViewModel {
    var dataArray: [[String: AnyObject]]

    var isSell: Bool

    var nowLatitude: Double
    var nowLongitude: Double
}
