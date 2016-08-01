//
//  SSNetworkContext.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 15..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

public struct SSNetworkContext {
    static let DEVELOPMENT_MODE: Bool = false;
    static let serverUrlPrefixt: String = DEVELOPMENT_MODE ? "http://localhost:3000/" : "http://54.64.154.188/"

    static let sharedInstance = SSNetworkContext()

    func getSharedAttribute(key: String) -> AnyObject? {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

        return defaults.objectForKey(key)
    }

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

    func deleteSharedAttribute(key: String) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(key)

        defaults.synchronize()
    }
}