//
//  FlightViewModel.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//

import Foundation
import Combine

@MainActor
final class FlightViewModel: ObservableObject {
    @Published var flightIATA = ""
    @Published var isLoading = false
    @Published var flights: [FlightItem] = []
    @Published var errorMessage: String?
    @Published var recentSearches: [String] = []

    private let recentSearchesKey = "recent_flight_searches"
    private let maxRecentSearches = 8
    private let service: FlightSearching
    private let airportStatus: (String) async -> FrankfurtFlightStatus?
    private let defaults: UserDefaults
    private var requestID = UUID()

    init(
        service: FlightSearching = FlightService.shared,
        defaults: UserDefaults = .standard,
        airportStatus: @escaping (String) async -> FrankfurtFlightStatus? = { await FrankfurtAirportService.shared.status(for: $0) }
    ) {
        self.service = service
        self.defaults = defaults
        self.airportStatus = airportStatus
        loadRecentSearches()
    }

    func search() async {
        let id = UUID()
        requestID = id
        let trimmed = normalizedFlightCode(from: flightIATA)

        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a flight code like LH400."
            flights = []
            isLoading = false
            return
        }

        flightIATA = trimmed
        isLoading = true
        errorMessage = nil
        flights = []

        defer { if requestID == id { isLoading = false } }

        do {
            let response = try await searchBestAvailableFlight(trimmed)
            try Task.checkCancellation()
            let enrichedFlights = await enrichWithFrankfurtDataIfAvailable(response.data, matching: trimmed)
            guard requestID == id, normalizedFlightCode(from: flightIATA) == trimmed, !Task.isCancelled else { return }
            flights = prioritizedFlights(from: enrichedFlights, matching: trimmed)

            if flights.isEmpty {
                errorMessage = "No flights found."
            } else {
                addRecentSearch(trimmed)
            }
        } catch {
            guard requestID == id, normalizedFlightCode(from: flightIATA) == trimmed, !Task.isCancelled else { return }
            if error is CancellationError || (error as? URLError)?.code == .cancelled { return }
            errorMessage = error.localizedDescription
        }
    }

    func applyRecentSearch(_ code: String) {
        flightIATA = normalizedFlightCode(from: code)
    }

    func removeRecentSearch(_ code: String) {
        recentSearches.removeAll { $0 == code }
        saveRecentSearches()
    }

    func clearRecentSearches() {
        recentSearches = []
        saveRecentSearches()
    }

    private func normalizedFlightCode(from value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .filter { !$0.isWhitespace }
    }

    private func searchBestAvailableFlight(_ code: String) async throws -> FlightResponse {
        do {
            let datedResponse = try await service.searchFlight(iataCode: code, flightDate: todayFlightDate)
            if !datedResponse.data.isEmpty {
                return datedResponse
            }
        } catch {
            if error is CancellationError || (error as? URLError)?.code == .cancelled { throw error }
            // Some AviationStack plans reject flight_date. Keep flight search working by retrying with the base query.
        }

        try Task.checkCancellation()
        return try await service.searchFlight(iataCode: code, flightDate: nil)
    }

    private func enrichWithFrankfurtDataIfAvailable(_ items: [FlightItem], matching code: String) async -> [FlightItem] {
        guard items.contains(where: { $0.departure?.iata?.uppercased() == "FRA" }) else {
            return items
        }

        guard let frankfurtStatus = await airportStatus(code) else {
            return items
        }

        return items.map { item in
            guard item.departure?.iata?.uppercased() == "FRA",
                  item.flight?.iata?.uppercased() == code
            else { return item }
            return item.enrichedWithFrankfurtStatus(frankfurtStatus)
        }
    }

    private var todayFlightDate: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func prioritizedFlights(from items: [FlightItem], matching code: String) -> [FlightItem] {
        items.sorted { lhs, rhs in
            let lhsExact = lhs.flight?.iata?.uppercased() == code
            let rhsExact = rhs.flight?.iata?.uppercased() == code
            if lhsExact != rhsExact { return lhsExact }

            if lhs.hasReportedDepartureGate != rhs.hasReportedDepartureGate {
                return lhs.hasReportedDepartureGate
            }

            let lhsScheduled = lhs.departure?.scheduled ?? ""
            let rhsScheduled = rhs.departure?.scheduled ?? ""
            return lhsScheduled > rhsScheduled
        }
    }

    private func addRecentSearch(_ code: String) {
        recentSearches.removeAll { $0 == code }
        recentSearches.insert(code, at: 0)

        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }

        saveRecentSearches()
    }

    private func loadRecentSearches() {
        guard let stored = defaults.array(forKey: recentSearchesKey) as? [String] else {
            recentSearches = []
            return
        }

        recentSearches = stored
            .map { normalizedFlightCode(from: $0) }
            .filter { !$0.isEmpty }
    }

    private func saveRecentSearches() {
        defaults.set(recentSearches, forKey: recentSearchesKey)
    }
}
