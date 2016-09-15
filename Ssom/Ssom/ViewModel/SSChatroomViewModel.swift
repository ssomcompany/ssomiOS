//
//  SSChatroomViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

enum SSMeetRequestOptions: Int {
    case NotRequested
    case Cancelled
    case Requested
    case Received
}

public struct SSChatroomViewModel {
    var chatroomId: String              // id
    var ownerUserId: String             // ownerId
    var participantUserId: String       // participantId
    var createdDateTime: NSDate         // createdTimestamp
    var unreadCount: Int
    var lastMessage: String             // lastMsg
    var ssomViewModel: SSViewModel
    var meetRequestUserId: String?          // requestId

    init() {
        self.chatroomId = ""
        self.ownerUserId = ""
        self.participantUserId = ""
        self.createdDateTime = NSDate()
        self.unreadCount = 0
        self.lastMessage = ""
        self.ssomViewModel = SSViewModel()
    }

    init(modelDict: [String: AnyObject]) {
        if let chatroomId = modelDict["id"] as? String {
            self.chatroomId = chatroomId
        } else {
            if let chatroomId = modelDict["id"] as? Int {
                self.chatroomId = String(chatroomId)
            } else {
                self.chatroomId = ""
            }
        }

        if let ownerUserId = modelDict["ownerId"] as? String {
            self.ownerUserId = ownerUserId
        } else {
            self.ownerUserId = ""
        }

        if let participantUserId = modelDict["participantId"] as? String {
            self.participantUserId = participantUserId
        } else {
            self.participantUserId = ""
        }

        if let createdDateTime = modelDict["createdTimestamp"] as? Int {
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

        self.ssomViewModel = SSViewModel(modelDict: modelDict)

        if let requestUserId = modelDict["requestId"] as? String {
            self.meetRequestUserId = requestUserId
        } else if let requestUserId = modelDict["reuqestId"] as? String {
            self.meetRequestUserId = requestUserId
        }
    }
}