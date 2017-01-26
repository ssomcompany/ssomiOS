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
    case ageAll = 0
    case ageEarly20 = 20
    case ageMiddle20 = 25
    case ageLate20 = 29
    case age30 = 30
    case unknown = 99

    init(rawValue: UInt) {
        switch rawValue {
        case 0:
            self = .ageAll
        case 20..<25:
            self = .ageEarly20
        case 25..<29:
            self = .ageMiddle20
        case 29..<30:
            self = .ageLate20
        default:
            self = .age30
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
    case Unknown = "정보가 없어요..."

    func toInt() -> SSAgeType {
        switch self {
        case .AgeAll:
            return SSAgeType.ageAll
        case .AgeEarly20:
            return SSAgeType.ageEarly20
        case .AgeMiddle20:
            return SSAgeType.ageMiddle20
        case .AgeLate20:
            return SSAgeType.ageLate20
        case .Age30:
            return SSAgeType.age30
        default:
            return SSAgeType.unknown
        }
    }
}

enum SSPeopleCountType: Int
{
    case all = 0
    case onePerson = 1
    case twoPeople
    case threePeople
    case overFourPeople

    func toSting() -> SSPeopleCountStringType {
        switch self {
        case .all:
            return SSPeopleCountStringType.All
        case .onePerson:
            return SSPeopleCountStringType.OnePerson
        case .twoPeople:
            return SSPeopleCountStringType.TwoPeople
        case .threePeople:
            return SSPeopleCountStringType.ThreePeople
        case .overFourPeople:
            return SSPeopleCountStringType.OverFourPeople
        }
    }
}

enum SSPeopleCountStringType: String
{
    case All = "전체"
    case OnePerson = "1명"
    case TwoPeople = "2명"
    case ThreePeople = "3명"
    case OverFourPeople = "4명 이상"

    func toInt() -> SSPeopleCountType {
        switch self {
        case .All:
            return SSPeopleCountType.all
        case .OnePerson:
            return SSPeopleCountType.onePerson
        case .TwoPeople:
            return SSPeopleCountType.twoPeople
        case .ThreePeople:
            return SSPeopleCountType.threePeople
        case .OverFourPeople:
            return SSPeopleCountType.overFourPeople
        }
    }
}

public struct SSWriteViewModel
{
    var userId: String      //userId

    var content: String     //content

    var peopleCountType: SSPeopleCountType  //userCount
    var ageType: SSAgeType  //minAge, maxAge

    var profilePhotoUrl: URL?  //imageUrl

    var myLatitude: Double  //latitude
    var myLongitude: Double //longitude

    var menuType: String    //category

    var ssomType: SSType    //ssom

    init() {
        userId = ""

        content = ""

        peopleCountType = .onePerson

        ageType = .ageEarly20

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
        , profilePhotoUrl: URL
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

        profilePhotoUrl = data["profilePhotoUrl"] as? URL

        myLatitude = data["latitude"] as! Double
        myLongitude = data["longitude"] as! Double

        menuType = "" //data["menu"] as! String

        ssomType = data["ssomType"] as! SSType
    }
}
