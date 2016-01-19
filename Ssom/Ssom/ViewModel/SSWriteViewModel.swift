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
    case AgeEarly20 = 1
    case AgeMiddle20
    case AgeLate20
    case Age30
}

enum SSPeopleCountType: Int
{
    case OnePerson = 1
    case TwoPeople
    case ThreePeople
    case OverFourPeople
}

public struct SSWriteViewModel
{
    var ageType: SSAgeType
    var peopleCountType: SSPeopleCountType
}