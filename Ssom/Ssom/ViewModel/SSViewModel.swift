//
//  SSViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 2. 26..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

public class SSViewModel {
    var category: String
    var content: String!
    var imageUrl: String!
    var latitude: Double
    var longitude: Double
    var distance: Int!
    var maxAge: Int!
    var minAge: Int!
    var postId: String
    var ssomType: SSType
    var userId: String
    var userCount: Int!

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
    }

    init(modelDict:[String: AnyObject!]) {
        self.category   = modelDict["category"] as! String
        self.content    = String.encodeSpaceCharacter(modelDict["content"] as! String).stringByRemovingPercentEncoding
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
        if let maxAge: Int = modelDict["maxAge"] as? Int {
            self.maxAge = maxAge
        } else {
            self.maxAge = 0
        }
        if let minAge: Int = modelDict["minAge"] as? Int {
            self.minAge = minAge
        } else {
            self.minAge = 0
        }
        self.postId     = modelDict["postId"] as! String
        let ssomType = modelDict["ssomType"] as! String
        self.ssomType   = SSType(rawValue: ssomType)!
        self.userId     = modelDict["userId"] as! String
        if let userCount: Int = modelDict["userCount"] as? Int {
            self.userCount = userCount
        } else {
            self.userCount = 0
        }
    }
}
