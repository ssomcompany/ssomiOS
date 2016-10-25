//
//  SSChatroomViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

enum SSMeetRequestOptions: String {
    case NotRequested = "NotRequested"
    case Cancelled = "Cancelled"
    case Requested = "Requested"
    case Received = "request"
    case Accepted = "approve"
}

public struct SSChatroomViewModel {
    var chatroomId: String                  // id
    var ownerUserId: String                 // ownerId
    var ownerImageUrl: String?              // ownerImageUrl
    var participantUserId: String           // participantId
    var participantImageUrl: String?        // participantImageUrl
    var createdDateTime: NSDate             // createdTimestamp
    var unreadCount: Int
    var lastMessage: String                 // lastMsg
    var lastMessageType: SSChatMessageType  // lastMsgType
    var ssomViewModel: SSViewModel
    var meetRequestUserId: String?          // requestId
    var meetRequestStatus: SSMeetRequestOptions = .NotRequested // status =  ['request', 'approve']

    init() {
        self.chatroomId = ""
        self.ownerUserId = ""
        self.participantUserId = ""
        self.createdDateTime = NSDate()
        self.unreadCount = 0
        self.lastMessage = ""
        self.lastMessageType = .Normal
        self.ssomViewModel = SSViewModel()
    }

    init(modelDict: [String: AnyObject]) {
        if let chatroomId = modelDict["id"] as? String {
            self.chatroomId = chatroomId
        } else {
            if let chatroomId = modelDict["id"] as? Int {
                self.chatroomId = String(chatroomId)
            } else {
                if let chatroomId = modelDict["chatroomId"] as? String {
                    self.chatroomId = chatroomId
                } else if let chatroomId = modelDict["chatroomId"] as? Int {
                    self.chatroomId = String(chatroomId)
                } else {
                    self.chatroomId = ""
                }
            }
        }

        if let ownerUserId = modelDict["ownerId"] as? String {
            self.ownerUserId = ownerUserId
        } else {
            self.ownerUserId = ""
        }

        if let imageUrl = modelDict["ownerImageUrl"] as? String {
            self.ownerImageUrl = imageUrl
        }

        if let participantUserId = modelDict["participantId"] as? String {
            self.participantUserId = participantUserId
        } else {
            self.participantUserId = ""
        }

        if let imageUrl = modelDict["participantImageUrl"] as? String {
            self.participantImageUrl = imageUrl
        }

        if let createdDateTime = modelDict["lastTimestamp"] as? Int {
            self.createdDateTime = NSDate(timeIntervalSince1970: NSTimeInterval(createdDateTime)/1000.0)
        } else {
            self.createdDateTime = NSDate()
        }

        if let unreadCount = modelDict["unreadCount"] as? Int {
            self.unreadCount = unreadCount
        } else {
            self.unreadCount = 0
        }

        if let lastMessage = modelDict["lastMsg"] as? String {
            self.lastMessage = lastMessage
        } else {
            self.lastMessage = ""
        }

        if let lastMessageType = modelDict["lastMsgType"] as? String {
            self.lastMessageType = SSChatMessageType(rawValue: lastMessageType)!
        } else {
            self.lastMessageType = .Normal
        }

        self.ssomViewModel = SSViewModel(modelDict: modelDict)

        if let requestUserId = modelDict["requestId"] as? String {
            self.meetRequestUserId = requestUserId
        } else if let fromUserId = modelDict["fromUserId"] as? String {
            self.meetRequestUserId = fromUserId
        } else if let userId = modelDict["userId"] as? String {
            self.meetRequestUserId = userId
        }

        if let requestStatus = modelDict["status"] as? String {
            self.meetRequestStatus = SSMeetRequestOptions(rawValue: requestStatus)!
        } else if let _ = modelDict["deletedTimestamp"] {
            self.meetRequestStatus = .Cancelled
        }
    }
}
