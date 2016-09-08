//
//  SSNetworkErrorHandler.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 15..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

enum SSNetworkError:Int {
    case ErrorDuplicatedData = 502
}

public struct SSNetworkErrorHandler {
    static let sharedInstance: SSNetworkErrorHandler = SSNetworkErrorHandler()

    let kSSErrorTable: String = "SSError"
    let kSSErrorCodeKey: String = "errorCode"
    let kSSErrorDescriptionKey: String = "description"

    func getErrorInfo(errorKey: String) -> (Int, String)? {
        if let errorTableFilePath: String = NSBundle.mainBundle().pathForResource(kSSErrorTable, ofType: "plist") {
            guard let errorTableMap = NSDictionary(contentsOfFile: errorTableFilePath) else {
                return nil
            }

            if let errorInfo = errorTableMap[errorKey] {
                return (Int(errorInfo[kSSErrorCodeKey] as! String)!, errorInfo[kSSErrorDescriptionKey] as! String)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}