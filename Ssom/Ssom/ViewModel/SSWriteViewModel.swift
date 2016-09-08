//
//  SSWriteViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 17..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

enum SSAgeType: Int
{
    case AgeAll = 0
    case AgeEarly20 = 20
    case AgeMiddle20 = 24
    case AgeLate20 = 27
    case Age30 = 30
}

enum SSAgeAreaType: String
{
    case AgeAll = "전체"
    case AgeEarly20 = "20대 초반"
    case AgeMiddle20 = "20대 중반"
    case AgeLate20 = "20대 후반"
    case Age30 = "30대"

    func toInt() -> Int {
        switch self {
        case AgeAll:
            return 0
        case AgeEarly20:
            return 20
        case AgeMiddle20:
            return 24
        case AgeLate20:
            return 27
        case Age30:
            return 30
        }
    }
}

enum SSPeopleCountType: Int
{
    case All = 0
    case OnePerson = 1
    case TwoPeople
    case ThreePeople
    case OverFourPeople
}

enum SSPeopleCountStringType: String
{
    case All = "전체"
    case OnePerson = "1명"
    case TwoPeople = "2명"
    case ThreePeople = "3명"
    case OverFourPeople = "4명 이상"

    func toInt() -> Int {
        switch self {
        case All:
            return 0
        case OnePerson:
            return 1
        case TwoPeople:
            return 2
        case ThreePeople:
            return 3
        case OverFourPeople:
            return 4
        }
    }
}

public struct SSWriteViewModel
{
    var userId: String      //userId

    var content: String     //content

    var peopleCountType: SSPeopleCountType  //userCount
    var ageType: SSAgeType  //minAge, maxAge

    var profilePhotoUrl: NSURL?  //imageUrl

    var myLatitude: Double  //latitude
    var myLongitude: Double //longitude

    var menuType: String    //category

    var ssomType: SSType    //ssom

    init() {
        userId = ""

        content = ""

        peopleCountType = .OnePerson

        ageType = .AgeEarly20

        profilePhotoUrl = nil

        myLatitude = 0
        myLongitude = 0

        menuType = "" //data["menu"] as! String

        ssomType = .SSOM
    }

    init(userId: String
        , content: String
        , peopleCount: SSPeopleCountType
        , age: SSAgeType
        , profilePhotoUrl: NSURL
        , myLatitude: Double
        , myLongitude: Double
        , isSell: Bool)
    {
        self.userId = userId
        self.content = content
        self.peopleCountType = peopleCount
        self.ageType = age
        self.profilePhotoUrl = profilePhotoUrl
        self.myLatitude = myLatitude
        self.myLongitude = myLongitude
        self.menuType = ""
        self.ssomType = isSell ? .SSOM : .SSOSEYO
    }

    init(data: [String: AnyObject]) {
        userId = data["userId"] as! String

        content = data["content"] as! String

        peopleCountType = data["peopleCount"] as! SSPeopleCountType

        ageType = data["age"] as! SSAgeType

        profilePhotoUrl = data["profilePhotoUrl"] as? NSURL

        myLatitude = data["latitude"] as! Double
        myLongitude = data["longitude"] as! Double

        menuType = "" //data["menu"] as! String

        ssomType = data["ssomType"] as! SSType
    }
}