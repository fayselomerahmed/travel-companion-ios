//
//  TravelRequirement.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//

import Foundation

struct TravelRequirement: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let isRequired: Bool
    let category: RequirementCategory

    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case isRequired
        case category
    }
}

enum RequirementCategory: String, Codable, CaseIterable {
    case passport = "Passport"
    case visa = "Visa"
    case health = "Health"
    case customs = "Customs"
    case checkIn = "Check-In"
}
