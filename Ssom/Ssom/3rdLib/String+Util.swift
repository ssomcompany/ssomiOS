//
//  File.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 3. 21..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

extension String {
    static func encodeSpaceCharacter(var rawString: String) -> String {
        if let rangeOfPlus = rawString.rangeOfString("+") {
            rawString.replaceRange(rangeOfPlus, with: "%20")

            if (rawString.rangeOfString("+") != nil) {
                return String.encodeSpaceCharacter(rawString)
            } else {
                return rawString
            }
        } else {
            return rawString
        }
    }
}
