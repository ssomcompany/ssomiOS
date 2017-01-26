//
//  SSUserModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 31..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

public struct SSUserModel {

    var email: String
    var gender: String
    var userId: String
    var nickName: String
    var profileImageUrl: String?    // profileImgUrl

    init() {
        self.email = ""
        self.gender = ""
        self.userId = ""
        self.nickName = ""
    }

    init(modelDict: [String: AnyObject?]) {
        if let email = modelDict["email"] as? String {
            self.email = email
        } else {
            self.email = ""
        }

        if let gender = modelDict["gender"] as? String {
            self.gender = gender
        } else {
            self.gender = ""
        }

        if let userId = modelDict["id"] as? String {
            self.userId = userId
        } else {
            self.userId = ""
        }

        if let nickName = modelDict["nickname"] as? String {
            self.nickName = nickName
        } else {
            self.nickName = ""
        }

        if let imageUrl = modelDict["profileImgUrl"] as? String {
            self.profileImageUrl = imageUrl
        }
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [String: Any]()

        dict["email"] = self.email
        dict["gender"] = self.gender
        dict["id"] = self.userId
        dict["nickname"] = self.nickName

        return dict
    }
}
