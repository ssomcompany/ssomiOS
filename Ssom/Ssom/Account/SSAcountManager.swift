//
//  SSAcountManager.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 4. 23..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

class SSAccountManager {
    static let sharedInstance = SSAccountManager()

    func isAuthorized() -> Bool {
        if SSNetworkContext.sharedInstance.getSharedAttribute("token") != nil {
            return true
        } else {
            return false
        }
    }
}