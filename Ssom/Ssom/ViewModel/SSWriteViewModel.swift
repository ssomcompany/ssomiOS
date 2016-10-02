//
//  SSWriteViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 1. 17..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import Foundation

enum SSAgeType: UInt
{
    case AgeAll = 0
    case AgeEarly20 = 20
    case AgeMiddle20 = 25
    case AgeLate20 = 29
    case Age30 = 30
    case Unknown = 99

    init(rawValue: UInt) {
        switch rawValue {
        case 0:
            self = .AgeAll
        case 20..<25:
            self = .AgeEarly20
        case 25..<29:
            self = .AgeMiddle20
        case 29..<30:
            self = .AgeLate20
        default:
            self = .Age30
        }
    }
}

enum SSAgeAreaType: String
{
    case AgeAll = "전체"
    case AgeEarly20 = "20대 초"
    case AgeMiddle20 = "20대 중"
    case AgeLate20 = "20대 후"
    case Age30 = "30대"
    case Unknown = "알수없음"

    func toIntType() -> SSAgeType {
        switch self {
        case AgeAll:
            return SSAgeType.AgeAll
        case AgeEarly20:
            return SSAgeType.AgeEarly20
        case AgeMiddle20:
            return SSAgeType.AgeMiddle20
        case AgeLate20:
            return SSAgeType.AgeLate20
        case Age30:
            return SSAgeType.Age30
        default:
            return SSAgeType.Unknown
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

    func toIntType() -> SSPeopleCountType {
        switch self {
        case All:
            return SSPeopleCountType.All
        case OnePerson:
            return SSPeopleCountType.OnePerson
        case TwoPeople:
            return SSPeopleCountType.TwoPeople
        case ThreePeople:
            return SSPeopleCountType.ThreePeople
        case OverFourPeople:
            return SSPeopleCountType.OverFourPeople
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
