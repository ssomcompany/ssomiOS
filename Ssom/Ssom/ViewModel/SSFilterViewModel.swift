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

        self.ssomType = ssomType == nil ? [.SSOM, .SSOSEYO] : [ssomType]
        self.ageTypes.append(ageType)
        self.peopleCountTypes.append(peopleCount)
    }

    // MARK: Validation
    func includedAgeAreaTypes(_ ageTypeRawValue: UInt) -> Bool {
        let ageType = SSAgeType(rawValue: ageTypeRawValue)

        for filterAgeAreaType in self.ageTypes {
            if filterAgeAreaType.toInt() == ageType {
                return true
            }
        }

        return false
    }

    func includedAgeAreaTypes(_ ageType: SSAgeType) -> Bool {
        for filterAgeAreaType in self.ageTypes {
            if filterAgeAreaType.toInt() == ageType {
                return true
            }
        }

        return false
    }

    func includedAgeAreaTypes(_ ageAreaType: SSAgeAreaType) -> Bool {
        for filterAgeAreaType in self.ageTypes {
            if filterAgeAreaType == ageAreaType {
                return true
            }
        }

        return false
    }

    func includedPeopleCountStringTypes(_ peopleCountTypeRawValue: Int) -> Bool {
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
        for filterPeopleCountStringType in self.peopleCountTypes {
            if filterPeopleCountStringType.toInt() == peopleCountType {
                return true
            }
        }

        return false
    }

    func includedPeopleCountStringTypes(_ peopleCountStringType: SSPeopleCountStringType) -> Bool {
        for filterPeopleCountStringType in self.peopleCountTypes {
            if filterPeopleCountStringType == peopleCountStringType {
                return true
            }
        }

        return false
    }
}
