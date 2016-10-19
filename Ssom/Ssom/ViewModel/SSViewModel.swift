//
//  SSViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 2. 26..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

public class SSViewModel {
    var category: String!
    var content: String!
    var imageUrl: String!
    var latitude: Double
    var longitude: Double
    var distance: Int!
    var maxAge: UInt
    var minAge: UInt
    var postId: String
    var ssomType: SSType
    var userId: String
    var userCount: Int!
    var createdDatetime: NSDate
    var assignedChatroomId: String?
    var meetRequestUserId: String?
    var meetRequestStatus: SSMeetRequestOptions = .NotRequested

    init() {
        self.category = ""
        self.content = ""
        self.imageUrl = ""
        self.latitude = 0
        self.longitude = 0
        self.distance = 0
        self.maxAge = 0
        self.minAge = 0
        self.postId = ""
        self.ssomType = .SSOM
        self.userId = ""
        self.userCount = 0
        self.createdDatetime = NSDate()
    }

    init(modelDict:[String: AnyObject!]) {
        if let category = modelDict["category"] as? String {
            self.category = category
        }
        if let content = modelDict["content"] as? String {
            self.content  = String.encodeSpaceCharacter(content).stringByRemovingPercentEncoding
        }
        if let imageUrl = modelDict["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        if let latitude = modelDict["latitude"] as? Double {
            self.latitude = latitude
        } else {
            self.latitude = 0.0
        }
        if let longitude = modelDict["longitude"] as? Double {
            self.longitude = longitude
        } else {
            self.longitude = 0.0
        }
        if let distance: Int = modelDict["distance"] as? Int {
            self.distance = distance
        } else {
            self.distance = 0
        }
        if let maxAge: UInt = modelDict["maxAge"] as? UInt {
            self.maxAge = maxAge
        } else {
            self.maxAge = 0
        }
        if let minAge: UInt = modelDict["minAge"] as? UInt {
            self.minAge = minAge
        } else {
            self.minAge = 0
        }
        if let postId = modelDict["postId"] as? String {
            self.postId = postId
        } else {
            self.postId = ""
        }
        if let ssomType = modelDict["ssomType"] as? String {
            self.ssomType = SSType(rawValue: ssomType)!
        } else {
            self.ssomType = .SSOM
        }
        if let userId = modelDict["userId"] as? String {
            self.userId = userId
        } else {
            self.userId = ""
        }
        if let userCount: Int = modelDict["userCount"] as? Int {
            self.userCount = userCount
        } else {
            self.userCount = 0
        }

        if let createdDatetime = modelDict["createdTimestamp"] as? Int {
            self.createdDatetime = NSDate(timeIntervalSince1970: NSTimeInterval(createdDatetime)/1000.0)
        } else {
            self.createdDatetime = NSDate()
        }

        if let chatroomId = modelDict["chatroomId"] as? String {
            self.assignedChatroomId = chatroomId
        } else {
            if let chatroomId = modelDict["chatroomId"] as? Int {
                self.assignedChatroomId = String(chatroomId)
            }
        }

        if let requestUserId = modelDict["fromUserId"] as? String {
            self.meetRequestUserId = requestUserId
        }
        if let requestStatus = modelDict["status"] as? String {
            self.meetRequestStatus = SSMeetRequestOptions(rawValue: requestStatus)!
        }
    }
}
