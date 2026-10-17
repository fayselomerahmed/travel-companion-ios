//
//  Enviroment.swift
//  TravelCompanion
//
//  Created by User on 3/4/26.
//

import Foundation

enum Environment {
    static func baseURL() throws -> URL {
        let value = ProcessInfo.processInfo.environment["API_BASE_URL"]
            ?? Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String

        guard let value, !value.isEmpty else {
            throw APIConfigurationError.missingValue("API_BASE_URL")
        }

        guard let url = URL(string: value) else {
            throw APIConfigurationError.invalidURL(value)
        }

        return url
    }
}
