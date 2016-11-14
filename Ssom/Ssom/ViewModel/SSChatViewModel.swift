//
//  SSChatViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

enum SSChatMessageType: String {
    case Normal = "NORMAL"
    case System = "SYSTEM"
    case Request = "request"
    case Approve = "approve"
    case Cancel = "cancel"
    case Unknown = "UNKNOWN"
}

public struct SSChatViewModel {
    var chatroomId: String?
    var fromUserId: String
    var profileImageUrl: String?
    var toUserId: String
    var message: String
    var messageDateTime: NSDate
    var messageType: SSChatMessageType

    init() {
        self.fromUserId = ""
        self.toUserId = ""
        self.message = ""
        self.messageDateTime = NSDate()
        self.messageType = .Normal
    }

    init(modelDict: [String: AnyObject]) {
        if let chatroomId = modelDict["chatroomId"] as? String {
            self.chatroomId = chatroomId
        } else {
            if let chatroomId = modelDict["chatroomId"] as? Int {
                self.chatroomId = String(chatroomId)
            } else if let id = modelDict["id"] as? Int {
                self.chatroomId = String(id)
            }
        }

        if let fromUserId = modelDict["fromUserId"] as? String {
            self.fromUserId = fromUserId
        } else if let userId = modelDict["userId"] as? String {
            self.fromUserId = userId
        } else {
            self.fromUserId = ""
        }

        if let imageUrl = modelDict["profileImgUrl"] as? String {
            self.profileImageUrl = imageUrl
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
        } else if let messageType = modelDict["status"] as? String {
            self.messageType = SSChatMessageType(rawValue: messageType)!
        } else if let _ = modelDict["deletedTimestamp"] {
            self.messageType = .Cancel
        } else {
            self.messageType = .Normal
        }
    }
}
