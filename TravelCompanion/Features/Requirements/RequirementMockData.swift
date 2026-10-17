//
//  RequirementMockData.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//

import Foundation

enum RequirementMockData {
    static let sample: [TravelRequirement] = [
        TravelRequirement(
            title: "Valid passport",
            description: "Passport must be valid for at least 6 months beyond travel date.",
            isRequired: true,
            category: .passport
        ),
        TravelRequirement(
            title: "Visa check",
            description: "Passenger may need a visa depending on nationality and destination.",
            isRequired: true,
            category: .visa
        ),
        TravelRequirement(
            title: "Return ticket",
            description: "Some countries require proof of onward or return travel at check-in or border control.",
            isRequired: false,
            category: .checkIn
        ),
        TravelRequirement(
            title: "Vaccination / health documents",
            description: "Health certificates may be required depending on destination and transit country.",
            isRequired: false,
            category: .health
        ),
        TravelRequirement(
            title: "Customs declaration",
            description: "Passenger may need to declare cash, goods, or restricted items on arrival.",
            isRequired: false,
            category: .customs
        )
    ]
}
