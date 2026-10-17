//
//  VisaCheckResponse.swift
//  TravelCompanion
//
//  Created by User on 3/16/26.
//

import Foundation

struct VisaCheckResponse: Codable {
    let data: VisaCheckData
    let meta: VisaCheckMeta
}

struct VisaCheckData: Codable {
    let passport: VisaCountryInfo
    let destination: VisaDestinationInfo
    let mandatoryRegistration: MandatoryRegistration?
    let visaRules: VisaRules

    enum CodingKeys: String, CodingKey {
        case passport
        case destination
        case mandatoryRegistration = "mandatory_registration"
        case visaRules = "visa_rules"
    }
}

struct VisaCountryInfo: Codable {
    let code: String
    let name: String
    let currencyCode: String?

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case currencyCode = "currency_code"
    }
}

struct VisaDestinationInfo: Codable {
    let code: String
    let name: String
    let continent: String?
    let capital: String?
    let currencyCode: String?
    let currency: String?
    let exchange: String?
    let passportValidity: String?
    let phoneCode: String?
    let timezone: String?
    let population: Int?
    let areaKm2: Int?
    let embassyURL: String?

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case continent
        case capital
        case currencyCode = "currency_code"
        case currency
        case exchange
        case passportValidity = "passport_validity"
        case phoneCode = "phone_code"
        case timezone
        case population
        case areaKm2 = "area_km2"
        case embassyURL = "embassy_url"
    }
}

struct MandatoryRegistration: Codable {
    let name: String?
    let color: String?
    let link: String?
}

struct VisaRules: Codable {
    let primaryRule: VisaRule
    let secondaryRule: VisaRule?

    enum CodingKeys: String, CodingKey {
        case primaryRule = "primary_rule"
        case secondaryRule = "secondary_rule"
    }
}

struct VisaRule: Codable {
    let name: String?
    let duration: String?
    let color: String?
    let link: String?
}

struct VisaCheckMeta: Codable {
    let version: String?
    let language: String?
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case version
        case language
        case generatedAt = "generated_at"
    }
}
