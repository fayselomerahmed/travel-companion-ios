//
//  FlightService.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//

import Foundation

enum FlightServiceError: LocalizedError, Equatable {
    case subscriptionRestriction
    case authorizationFailed
    case requestLimitReached
    case providerFailure
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .subscriptionRestriction:
            return "This flight service subscription does not support the requested search."
        case .authorizationFailed:
            return "The flight service could not authorize this request. Check the API configuration and subscription."
        case .requestLimitReached:
            return "The flight service request limit was reached. Please try again later."
        case .providerFailure:
            return "The flight service could not complete the request. Please try again later."
        case .httpStatus(let statusCode):
            return "Flight provider returned HTTP \(statusCode). Please try again in a moment."
        }
    }
}

private struct AviationStackErrorResponse: Decodable {
    let error: AviationStackErrorPayload?
}

private struct AviationStackErrorPayload: Decodable {
    let code: String?
    let type: String?

    private enum CodingKeys: String, CodingKey { case code, type }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Older envelopes use a numeric code alongside a string type.
        // Neither provider diagnostics nor messages are rendered to the user.
        code = try? container.decode(String.self, forKey: .code)
        type = try? container.decode(String.self, forKey: .type)
    }
}

protocol FlightSearching {
    func searchFlight(iataCode: String, flightDate: String?) async throws -> FlightResponse
}

final class FlightService: FlightSearching {
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
            throw Self.providerError(from: data) ?? FlightServiceError.httpStatus(http.statusCode)
        }

        if let apiError = Self.providerError(from: data) {
            throw apiError
        }

        do {
            return try JSONDecoder().decode(FlightResponse.self, from: data)
        } catch {
            throw NetworkServiceError.decodingFailed("flight")
        }
    }

    static func providerError(from data: Data) -> FlightServiceError? {
        guard let response = try? JSONDecoder().decode(AviationStackErrorResponse.self, from: data),
              let error = response.error else {
            return nil
        }

        switch error.type ?? error.code {
        case "function_access_restricted":
            return .subscriptionRestriction
        case "missing_access_key", "invalid_access_key", "inactive_user", "https_access_restricted":
            return .authorizationFailed
        case "usage_limit_reached", "monthly_limit_reached", "rate_limit_reached":
            return .requestLimitReached
        default:
            return .providerFailure
        }
    }
}
