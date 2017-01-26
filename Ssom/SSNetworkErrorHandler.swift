//
//  SSNetworkErrorHandler.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 15..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

enum SSNetworkError:Int {
    case errorDuplicatedData = 502
}

public struct SSNetworkErrorHandler {
    static let sharedInstance: SSNetworkErrorHandler = SSNetworkErrorHandler()

    let kSSErrorTable: String = "SSError"
    let kSSErrorCodeKey: String = "errorCode"
    let kSSErrorDescriptionKey: String = "description"

    func getErrorInfo(_ errorKey: String) -> (Int, String)? {
        if let errorTableFilePath: String = Bundle.main.path(forResource: kSSErrorTable, ofType: "plist") {
            guard let errorTableMap = NSDictionary(contentsOfFile: errorTableFilePath) else {
                return nil
            }

            if let errorInfo = errorTableMap[errorKey] as? [String: String] {
                return (Int(errorInfo[kSSErrorCodeKey]!)!, errorInfo[kSSErrorDescriptionKey]!)
            }
        }

        return nil
    }

    func getErrorInfo(_ errorCode: Int) -> (Int, String)? {
        if let errorTableFilePath: String = Bundle.main.path(forResource: kSSErrorTable, ofType: "plist") {
            guard let errorTableMap = NSDictionary(contentsOfFile: errorTableFilePath) else {
                return nil
            }

            for errorKey in errorTableMap.allKeys {
                guard let errorInfo = errorTableMap[errorKey as! String] as? [String: String] else { continue }

                if Int(errorInfo[kSSErrorCodeKey]!)! == errorCode {
                    return (Int(errorInfo[kSSErrorCodeKey]!)!, errorInfo[kSSErrorDescriptionKey]!)
                }
            }
        }

        return nil
    }
}
