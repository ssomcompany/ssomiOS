//
//  SSChatViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

enum SSChatMessageType: String {
    case NORMAL = "NORMAL"
    case UNKNOWN = "UNKNOWN"
}

public struct SSChatViewModel {
    var fromUserId: String
    var toUserId: String
    var message: String
    var messageDateTime: NSDate
    var messageType: SSChatMessageType

    init() {
        self.fromUserId = ""
        self.toUserId = ""
        self.message = ""
        self.messageDateTime = NSDate()
        self.messageType = .NORMAL
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

        if let message = modelDict["msg"] as? String {
            self.message = message
        } else {
            self.message = ""
        }

        if let timestamp = modelDict["timestamp"] as? Int {
            self.messageDateTime = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp)/1000.0)
        } else {
            self.messageDateTime = NSDate()
        }

        if let messageType = modelDict["msgType"] as? String {
            self.messageType = SSChatMessageType(rawValue: messageType)!
        } else {
            self.messageType = .UNKNOWN
        }
    }
}
