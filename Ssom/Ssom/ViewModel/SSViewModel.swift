//
//  SSViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 2. 26..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

public struct SSViewModel {
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
        self.content    = modelDict["content"] as! String
        self.imageUrl   = modelDict["imageUrl"] as! String
        self.latitude   = modelDict["latitude"] as! Double
        self.longitude  = modelDict["longitude"] as! Double
        if let distance: Int = modelDict["distance"] as? Int {
            self.distance = distance
        } else {
            self.distance = 0
        }
        self.maxAge     = modelDict["maxAge"] as! Int
        self.minAge     = modelDict["minAge"] as! Int
        self.postId     = modelDict["postId"] as! String
        let ssomType = modelDict["ssom"] as! String
        self.ssomType   = SSType(rawValue: ssomType)!
        self.userId     = modelDict["userId"] as! String
        self.userCount  = modelDict["userCount"] as! Int
    }
}
