//
//  SSChatroomViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 28..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

public struct SSChatroomViewModel {
    var chatroomId: String              // id
    var ownerUserId: String             // ownerId
    var participantUserId: String       // participantId
    var createdDateTime: NSDate         // createdTimestamp
    var ssomViewModel: SSViewModel

    init() {
        self.chatroomId = ""
        self.ownerUserId = ""
        self.participantUserId = ""
        self.createdDateTime = NSDate()
        self.ssomViewModel = SSViewModel()
    }

    init(modelDict: [String: AnyObject]) {
        if let chatroomId = modelDict["id"] as? String {
            self.chatroomId = chatroomId
        } else {
            self.chatroomId = ""
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

        self.ssomViewModel = SSViewModel(modelDict: modelDict)
    }
}