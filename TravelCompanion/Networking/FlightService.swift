//
//  FlightService.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//

import Foundation

enum FlightServiceError: LocalizedError {
    case providerMessage(String)
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .providerMessage(let message):
            return message
        case .httpStatus(let statusCode):
            return "Flight provider returned HTTP \(statusCode). Please try again in a moment."
        }
    }
}

private struct AviationStackErrorResponse: Decodable {
    let success: Bool?
    let error: AviationStackErrorPayload?
}

private struct AviationStackErrorPayload: Decodable {
    let code: String?
    let type: String?
    let info: String?
}

final class FlightService {
    static let shared = FlightService()
    private init() {}

    func searchFlight(iataCode: String, flightDate: String? = nil) async throws -> FlightResponse {
        guard var components = URLComponents(string: "https://api.aviationstack.com/v1/flights") else {
            throw APIConfigurationError.invalidURL("api.aviationstack.com/v1/flights")
        }

        var queryItems = [
            URLQueryItem(name: "access_key", value: try APIKeys.aviationStackKey()),
            URLQueryItem(name: "flight_iata", value: iataCode)
        ]

        if let flightDate {
            queryItems.append(URLQueryItem(name: "flight_date", value: flightDate))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIConfigurationError.invalidURL(components.string ?? "aviationstack flights endpoint")
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        let (data, http) = try await APIClient.shared.data(for: request)

        if !(200...299).contains(http.statusCode) {
            throw providerError(from: data) ?? FlightServiceError.httpStatus(http.statusCode)
        }

        if let apiError = providerError(from: data) {
            throw apiError
        }

        do {
            return try JSONDecoder().decode(FlightResponse.self, from: data)
        } catch {
            throw NetworkServiceError.decodingFailed("flight")
        }
    }

    private func providerError(from data: Data) -> FlightServiceError? {
        guard let response = try? JSONDecoder().decode(AviationStackErrorResponse.self, from: data),
              response.success == false,
              let error = response.error else {
            return nil
        }

        if let info = error.info, !info.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .providerMessage(info)
        }

        if let type = error.type, !type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .providerMessage("Flight provider error: \(type).")
        }

        return .providerMessage("Flight provider could not complete the request.")
    }
}
