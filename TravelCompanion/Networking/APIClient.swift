//
//  APIClient.swift
//  TravelCompanion
//
//  Created by User on 3/4/26.
//

import Foundation

enum APIConfigurationError: LocalizedError {
    case missingValue(String)
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case .missingValue(let name):
            return "Missing API configuration for \(name). Add it to the app Info.plist or the Xcode scheme environment."
        case .invalidURL(let value):
            return "Invalid API URL: \(value)"
        }
    }
}

enum NetworkServiceError: LocalizedError {
    case invalidResponse
    case httpStatus(Int, String?)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server response was not valid. Please try again."
        case .httpStatus(let code, let message):
            if let message, !message.isEmpty {
                return message
            }
            return "The server returned HTTP \(code). Please try again in a moment."
        case .decodingFailed(let context):
            return "The app could not read the \(context) response. Please try again."
        }
    }
}

enum APIKeys {
    static let travelBuddyHost = "visa-requirement.p.rapidapi.com"

    static func rapidAPIKey() throws -> String {
        try configuredValue(named: "RAPID_API_KEY")
    }

    static func aviationStackKey() throws -> String {
        try configuredValue(named: "AVIATIONSTACK_API_KEY")
    }

    static func isConfigured(_ name: String) -> Bool {
        (try? configuredValue(named: name)) != nil
    }

    private static func configuredValue(named name: String) throws -> String {
        if let value = ProcessInfo.processInfo.environment[name], !value.isEmpty {
            return value
        }

        if let value = Bundle.main.object(forInfoDictionaryKey: name) as? String, !value.isEmpty {
            return value
        }

        throw APIConfigurationError.missingValue(name)
    }
}

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = true
        session = URLSession(configuration: configuration)
    }

    func get(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            if let http = response as? HTTPURLResponse {
                throw NetworkServiceError.httpStatus(http.statusCode, trimmedServerMessage(from: data))
            }
            throw NetworkServiceError.invalidResponse
        }

        return data
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkServiceError.invalidResponse
        }

        return (data, http)
    }

    static func trimmedServerMessage(from data: Data) -> String? {
        guard let message = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !message.isEmpty else {
            return nil
        }

        return message.count > 240 ? String(message.prefix(240)) + "..." : message
    }

    private func trimmedServerMessage(from data: Data) -> String? {
        Self.trimmedServerMessage(from: data)
    }
}
