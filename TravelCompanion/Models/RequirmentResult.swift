//
//  RequirmentResult.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//

import Foundation

struct RequirementResult: Codable, Identifiable {
    let id: String

    let origin: String
    let destination: String
    let date: String
    let nationality: String?

    let passportValidity: String?
    let visa: String?
    let health: String?
    let customs: String?

    let dataSource: String?
    let lastUpdated: String?
}
