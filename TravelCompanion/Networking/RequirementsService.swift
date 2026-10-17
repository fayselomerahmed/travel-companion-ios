//
//  RequirementsService.swift
//  TravelCompanion
//
//  Created by User on 3/16/26.
//

import Foundation

protocol RequirementsChecking {
    func checkVisaRequirements(passportCode: String, destinationCode: String) async throws -> VisaCheckResponse
}

final class RequirementsService: RequirementsChecking {
    static let shared = RequirementsService()
    private init() {}

    func checkVisaRequirements(
        passportCode: String,
        destinationCode: String
    ) async throws -> VisaCheckResponse {
        guard let url = URL(string: "https://visa-requirement.p.rapidapi.com/v2/visa/check") else {
            throw APIConfigurationError.invalidURL("visa-requirement.p.rapidapi.com/v2/visa/check")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(try APIKeys.rapidAPIKey(), forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(APIKeys.travelBuddyHost, forHTTPHeaderField: "X-RapidAPI-Host")

        let body = VisaCheckRequest(
            passport: passportCode,
            destination: destinationCode
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, http) = try await APIClient.shared.data(for: request)

        guard (200...299).contains(http.statusCode) else {
            throw NetworkServiceError.httpStatus(http.statusCode, APIClient.trimmedServerMessage(from: data))
        }

        do {
            return try JSONDecoder().decode(VisaCheckResponse.self, from: data)
        } catch {
            throw NetworkServiceError.decodingFailed("requirements")
        }
    }
}
