//
//  File.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 3. 21..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

extension String {
    static func encodeSpaceCharacter(rawString: String) -> String {
        var str: String = rawString

        if let rangeOfPlus = rawString.rangeOfString("+") {
            str.replaceRange(rangeOfPlus, with: "%20")

            if (rawString.rangeOfString("+") != nil) {
                return String.encodeSpaceCharacter(str)
            } else {
                return str
            }
        } else {
            return str
        }
    }
}
