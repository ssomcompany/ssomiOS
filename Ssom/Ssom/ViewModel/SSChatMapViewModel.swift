//
//  SSChatMapViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 9. 3..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

public struct SSChatMapViewModel {
    var myImageUrl: String?
//    var partnerUserModel: SSUserModel
//    var partnerUserId: String
    var partnerImageUrl: String?
    var partnerLatitude: Double
    var partnerLongitude: Double

    var ssomType: SSType = .SSOM

    var meetRequestedStatus: SSMeetRequestOptions = .NotRequested

    init() {
//        self.partnerUserModel = SSUserModel()
//        self.partnerUserId = ""
        self.partnerImageUrl = ""
        self.partnerLatitude = 0.0
        self.partnerLongitude = 0.0
    }

    init(modelDict: [String: Any?]) {
        if let imageUrl = modelDict["myImageUrl"] as? String {
            self.myImageUrl = imageUrl
        }

//        self.partnerUserModel = SSUserModel(modelDict: modelDict)

//        if let userId = modelDict["partnerUserId"] as? String {
//            self.partnerUserId = userId
//        } else {
//            self.partnerUserId = ""
//        }

        if let imageUrl = modelDict["partnerImageUrl"] as? String {
            self.partnerImageUrl = imageUrl
        }

        if let latitude = modelDict["partnerLatitude"] as? String {
            self.partnerLatitude = Double(latitude)!
        } else {
            self.partnerLatitude = 0.0
        }

        if let longitudue = modelDict["partnerLongitude"] as? String {
            self.partnerLongitude = Double(longitudue)!
        } else {
            self.partnerLongitude = 0.0
        }

        if let rawSsomType = modelDict["ssomType"] as? String {
            self.ssomType = SSType(rawValue: rawSsomType)!
        }

        if let rawSSMeetRequestOptions = modelDict["ssomMeetRequestOptions"] as? String {
            self.meetRequestedStatus = SSMeetRequestOptions(rawValue: rawSSMeetRequestOptions)!
        }
    }
}
