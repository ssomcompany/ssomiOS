//
//  SSFilterViewModel.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 12. 8..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation

public struct SSFilterViewModel {
    var ssomType: [SSType]
    var ageTypes: [SSAgeAreaType]

    var peopleCountTypes: [SSPeopleCountStringType]

    init() {
        self.ssomType = []
        self.ageTypes = []
        self.peopleCountTypes = []
    }

    init(ssomType: SSType! = nil, ageType: SSAgeAreaType, peopleCount: SSPeopleCountStringType) {
        self.init()

        self.ssomType = ssomType == nil ? SSType.allValues : [ssomType]
        self.ageTypes.append(ageType)
        self.peopleCountTypes.append(peopleCount)
    }

    // MARK: Validation
    func includedSsomTypes(_ ssomType: SSType) -> Bool {
        var validated: Bool = true

        for filterSsomType in self.ssomType {
            validated = validated && (filterSsomType == ssomType)
        }

        return validated
    }

    func includedAgeAreaTypes(_ ageTypeRawValue: UInt) -> Bool {
        if self.ageTypes == [.AgeAll] {
            return true
        }

        let ageType = SSAgeType(rawValue: ageTypeRawValue)

        for filterAgeAreaType in self.ageTypes {
            if filterAgeAreaType.toInt() == ageType {
                return true
            }
        }

        return false
    }

    func includedAgeAreaTypes(_ ageType: SSAgeType) -> Bool {
        if self.ageTypes == [.AgeAll] {
            return true
        }

        for filterAgeAreaType in self.ageTypes {
            if filterAgeAreaType.toInt() == ageType {
                return true
            }
        }

        return false
    }

    func includedAgeAreaTypes(_ ageAreaType: SSAgeAreaType) -> Bool {
        if self.ageTypes == [.AgeAll] {
            return true
        }

        for filterAgeAreaType in self.ageTypes {
            if filterAgeAreaType == ageAreaType {
                return true
            }
        }

        return false
    }

    func includedPeopleCountStringTypes(_ peopleCountTypeRawValue: Int) -> Bool {
        if self.peopleCountTypes == [.All] {
            return true
        }

        if let peopleCountType = SSPeopleCountType(rawValue: peopleCountTypeRawValue) {
            for filterPeopleCountStringType in self.peopleCountTypes {
                if filterPeopleCountStringType.toInt() == peopleCountType {
                    return true
                }
            }
        }

        return false
    }

    func includedPeopleCountStringTypes(_ peopleCountType: SSPeopleCountType) -> Bool {
        if self.peopleCountTypes == [.All] {
            return true
        }

        for filterPeopleCountStringType in self.peopleCountTypes {
            if filterPeopleCountStringType.toInt() == peopleCountType {
                return true
            }
        }

        return false
    }

    func includedPeopleCountStringTypes(_ peopleCountStringType: SSPeopleCountStringType) -> Bool {
        if self.peopleCountTypes == [.All] {
            return true
        }

        for filterPeopleCountStringType in self.peopleCountTypes {
            if filterPeopleCountStringType == peopleCountStringType {
                return true
            }
        }

        return false
    }
}
