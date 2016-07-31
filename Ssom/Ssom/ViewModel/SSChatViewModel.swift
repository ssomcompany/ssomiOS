//
//  SSChatViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

public struct SSChatViewModel {
    var fromUserId: String
    var toUserId: String
    var message: String
    var messageDateTime: NSDate

    init() {
        self.fromUserId = ""
        self.toUserId = ""
        self.message = ""
        self.messageDateTime = NSDate()
    }

    init(modelDict: [String: AnyObject]) {
        if let fromUserId = modelDict["fromUserId"] as? String {
            self.fromUserId = fromUserId
        } else {
            self.fromUserId = ""
        }

        if let toUserId = modelDict["toUserId"] as? String {
            self.toUserId = toUserId
        } else {
            self.toUserId = ""
        }

        if let message = modelDict["message"] as? String {
            self.message = message
        } else {
            self.message = ""
        }

        if let timestamp = modelDict["timestamp"] as? Int {
            self.messageDateTime = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp)/1000.0)
        } else {
            self.messageDateTime = NSDate()
        }
    }
}
