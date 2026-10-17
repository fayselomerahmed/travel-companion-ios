//
//  FlightResponse.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//

import Foundation

struct FlightResponse: Codable {
    let data: [FlightItem]
}

struct FlightItem: Codable, Identifiable {
    let id = UUID()
    let flightDate: String?
    let flightStatus: String?
    let departure: FlightEndpoint?
    let arrival: FlightEndpoint?
    let airline: AirlineInfo?
    let flight: FlightInfo?
    let officialDepartureGate: String?
    let officialDepartureTerminal: String?
    let officialDataSourceName: String?
    let officialDataSourceURL: String?

    enum CodingKeys: String, CodingKey {
        case flightDate = "flight_date"
        case flightStatus = "flight_status"
        case departure
        case arrival
        case airline
        case flight
    }

    init(
        flightDate: String?,
        flightStatus: String?,
        departure: FlightEndpoint?,
        arrival: FlightEndpoint?,
        airline: AirlineInfo?,
        flight: FlightInfo?,
        officialDepartureGate: String? = nil,
        officialDepartureTerminal: String? = nil,
        officialDataSourceName: String? = nil,
        officialDataSourceURL: String? = nil
    ) {
        self.flightDate = flightDate
        self.flightStatus = flightStatus
        self.departure = departure
        self.arrival = arrival
        self.airline = airline
        self.flight = flight
        self.officialDepartureGate = officialDepartureGate
        self.officialDepartureTerminal = officialDepartureTerminal
        self.officialDataSourceName = officialDataSourceName
        self.officialDataSourceURL = officialDataSourceURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        flightDate = try container.decodeFlexibleStringIfPresent(forKey: .flightDate)
        flightStatus = try container.decodeFlexibleStringIfPresent(forKey: .flightStatus)
        departure = try container.decodeIfPresent(FlightEndpoint.self, forKey: .departure)
        arrival = try container.decodeIfPresent(FlightEndpoint.self, forKey: .arrival)
        airline = try container.decodeIfPresent(AirlineInfo.self, forKey: .airline)
        flight = try container.decodeIfPresent(FlightInfo.self, forKey: .flight)
        officialDepartureGate = nil
        officialDepartureTerminal = nil
        officialDataSourceName = nil
        officialDataSourceURL = nil
    }

    func enrichedWithFrankfurtStatus(_ status: FrankfurtFlightStatus) -> FlightItem {
        FlightItem(
            flightDate: flightDate,
            flightStatus: status.status ?? flightStatus,
            departure: departure,
            arrival: arrival,
            airline: airline,
            flight: flight,
            officialDepartureGate: status.gate,
            officialDepartureTerminal: status.terminal,
            officialDataSourceName: status.sourceName,
            officialDataSourceURL: status.sourceURL.absoluteString
        )
    }
}

struct FlightEndpoint: Codable {
    let airport: String?
    let timezone: String?
    let iata: String?
    let icao: String?
    let terminal: String?
    let gate: String?
    let delay: Int?
    let scheduled: String?
    let estimated: String?
    let actual: String?

    enum CodingKeys: String, CodingKey {
        case airport
        case timezone
        case iata
        case icao
        case terminal
        case gate
        case delay
        case scheduled
        case estimated
        case actual
    }

    init(
        airport: String?,
        timezone: String?,
        iata: String?,
        icao: String?,
        terminal: String?,
        gate: String?,
        delay: Int?,
        scheduled: String?,
        estimated: String?,
        actual: String?
    ) {
        self.airport = airport
        self.timezone = timezone
        self.iata = iata
        self.icao = icao
        self.terminal = terminal
        self.gate = gate
        self.delay = delay
        self.scheduled = scheduled
        self.estimated = estimated
        self.actual = actual
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        airport = try container.decodeFlexibleStringIfPresent(forKey: .airport)
        timezone = try container.decodeFlexibleStringIfPresent(forKey: .timezone)
        iata = try container.decodeFlexibleStringIfPresent(forKey: .iata)
        icao = try container.decodeFlexibleStringIfPresent(forKey: .icao)
        terminal = try container.decodeFlexibleStringIfPresent(forKey: .terminal)
        gate = try container.decodeFlexibleStringIfPresent(forKey: .gate)
        delay = try container.decodeFlexibleIntIfPresent(forKey: .delay)
        scheduled = try container.decodeFlexibleStringIfPresent(forKey: .scheduled)
        estimated = try container.decodeFlexibleStringIfPresent(forKey: .estimated)
        actual = try container.decodeFlexibleStringIfPresent(forKey: .actual)
    }
}

extension FlightEndpoint {
    var normalizedGate: String? {
        guard let value = Self.normalizedTravelValue(gate) else { return nil }
        guard Self.looksLikePassengerGate(value, airportCode: iata) else { return nil }
        return value
    }

    var rawGateWasRejectedForPassenger: Bool {
        guard let value = Self.normalizedTravelValue(gate) else { return false }
        return !Self.looksLikePassengerGate(value, airportCode: iata)
    }

    var normalizedTerminal: String? {
        Self.normalizedTravelValue(terminal)
    }

    static func normalizedPassengerGate(_ value: String?, airportCode: String?) -> String? {
        guard let value = normalizedTravelValue(value) else { return nil }
        guard looksLikePassengerGate(value, airportCode: airportCode) else { return nil }
        return value
    }

    private static func looksLikePassengerGate(_ value: String, airportCode: String?) -> Bool {
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: " ", with: "")

        guard !normalized.isEmpty else { return false }

        let nonPassengerWords = ["STAND", "POSITION", "PARKING", "BAY", "BELT", "COUNTER", "DESK"]
        if nonPassengerWords.contains(where: { normalized.contains($0) }) {
            return false
        }

        if airportCode?.uppercased() == "FRA",
           normalized.range(of: #"^[0-9]{2,4}$"#, options: .regularExpression) != nil {
            return false
        }

        return normalized.range(of: #"^[A-Z]{1,3}[0-9]{1,3}[A-Z]?$|^[0-9]{1,3}[A-Z]$|^[A-Z]{1,3}[/-]?[0-9]{1,3}$"#, options: .regularExpression) != nil
    }

    static func normalizedTravelValue(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let invalidValues = ["-", "—", "n/a", "na", "none", "null", "unknown", "not available"]
        guard !invalidValues.contains(trimmed.lowercased()) else { return nil }
        return trimmed
    }
}

extension FlightItem {
    var reportedDepartureGate: String? {
        if let officialGate = FlightEndpoint.normalizedPassengerGate(officialDepartureGate, airportCode: departure?.iata) {
            return officialGate
        }
        return departure?.normalizedGate
    }

    var reportedArrivalGate: String? {
        arrival?.normalizedGate
    }

    var reportedDepartureTerminal: String? {
        FlightEndpoint.normalizedTravelValue(officialDepartureTerminal) ?? departure?.normalizedTerminal
    }

    var hasRawDepartureGateRejectedForPassenger: Bool {
        departure?.rawGateWasRejectedForPassenger ?? false
    }

    var passengerGateAreaHint: String? {
        guard reportedDepartureGate == nil else { return nil }

        let departureCode = departure?.iata?.uppercased()
        let airlineCode = flight?.iata?.prefix(2).uppercased()
        if departureCode == "FRA", airlineCode == "KU" {
            return "J gates"
        }

        return nil
    }

    var hasReportedDepartureGate: Bool {
        reportedDepartureGate != nil
    }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleStringIfPresent(forKey key: Key) throws -> String? {
        guard contains(key), !(try decodeNil(forKey: key)) else {
            return nil
        }
        if let value = try? decode(String.self, forKey: key) {
            return value
        }
        if let value = try? decode(Int.self, forKey: key) {
            return String(value)
        }
        if let value = try? decode(Double.self, forKey: key) {
            return value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
        }
        return nil
    }

    func decodeFlexibleIntIfPresent(forKey key: Key) throws -> Int? {
        guard contains(key), !(try decodeNil(forKey: key)) else {
            return nil
        }
        if let value = try? decode(Int.self, forKey: key) {
            return value
        }
        if let value = try? decode(Double.self, forKey: key) {
            return Int(value)
        }
        if let value = try? decode(String.self, forKey: key) {
            return Int(value.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return nil
    }
}

struct AirlineInfo: Codable {
    let name: String?
    let iata: String?
    let icao: String?
}

struct FlightInfo: Codable {
    let number: String?
    let iata: String?
    let icao: String?
}
