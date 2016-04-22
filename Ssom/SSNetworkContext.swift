//
//  SSNetworkContext.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 15..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

class SSNetworkContext {
    static let serverUrlPrefixt: String = "http://54.64.154.188/"

    static let sharedInstance = SSNetworkContext()

    func saveSharedAttribute(value: AnyObject, forKey: String) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(value, forKey: forKey)

        defaults.synchronize()
    }

    func saveSharedAttributes(attr: [String: AnyObject!]) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        for (key, value) in attr {
            defaults.setObject(value, forKey: key)
        }

        defaults.synchronize()
    }

    func getSharedAttribute(key: String) -> AnyObject? {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

        return defaults.objectForKey(key)
    }
}