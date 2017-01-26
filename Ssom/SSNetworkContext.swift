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
    static let serverUrlPrefixt: String = DEVELOPMENT_MODE ? "http://localhost:3000/" : "http://api.myssom.com/"

    static let sharedInstance = SSNetworkContext()

    func getSharedAttribute(_ key: String) -> Any? {
        let defaults: UserDefaults = UserDefaults.standard

        return defaults.object(forKey: key)
    }

    func saveSharedAttribute(_ value: Any, forKey: String) {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: forKey)

        defaults.synchronize()
    }

    func saveSharedAttributes(_ attr: [String: Any?]) {
        let defaults: UserDefaults = UserDefaults.standard
        for (key, value) in attr {
            defaults.set(value, forKey: key)
        }

        defaults.synchronize()
    }

    func deleteSharedAttribute(_ key: String) {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: key)

        defaults.synchronize()
    }
}
