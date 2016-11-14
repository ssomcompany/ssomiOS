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

    var guideText: String {
        switch self {
        case .SSOM:
            return "오늘은 내가 쏜다!\n쏘고 싶은 메뉴와 센스 있는 멘트를\n적어보세요. 좋은 쏨을 만날 확률이\n훨씬 높아 집니다. : )"
        case .SSOSEYO:
            return "한턱 쏠 사람을 찾아보세요!\n사진, 멘트에 매력이 넘칠수록\n멋진 쏨을 만날 확률이 높아집니다!"
        }
    }

    var shortTitle: String {
        switch self {
        case .SSOM:
            return "내가 쏠게요!"
        case .SSOSEYO:
            return "쏘실 분 찾아요!"
        }
    }
}

public struct SSMainViewModel {
    var datas: [SSViewModel]

    var isSell: Bool

    var nowLatitude: Double
    var nowLongitude: Double

    init() {
        self.datas = []
        self.isSell = true
        self.nowLatitude = 0
        self.nowLongitude = 0
    }

    init(datas:[SSViewModel], isSell: Bool, nowLatitude: Double = 0, nowLongitude: Double = 0) {
        self.datas = datas
        self.isSell = isSell
        self.nowLatitude = nowLatitude
        self.nowLongitude = nowLongitude
    }
}
