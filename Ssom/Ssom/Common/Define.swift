//
//  Define.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 12..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

public class PreDefine {
    static let GoogleMapKey: String = "AIzaSyCrQIOi-sQBvikxrc577aXER7Rl0wEnROQ"
    static let OneSignalKey: String = "b0c678d6-45d3-4868-96bd-2e28f0340e10"
}

enum SSInternalNotification: String {
    case PurchasedHeart = "PurchasedHeart"
}

let SSDefaultHeartCount = 2
let SSDefaultHeartRechargeTimeInterval: NSTimeInterval = 4*60*60
let SSDefaultHeartRechargeHour: Int = Int(SSDefaultHeartRechargeTimeInterval/60/60)
