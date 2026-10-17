import Foundation
import XCTest
@testable import TravelCore

private actor ControlledFlights: FlightSearching {
    private var pending: [String: CheckedContinuation<FlightResponse, Error>] = [:]
    private(set) var calls: [(String, String?)] = []
    private let onRequest: (String) -> Void
    init(onRequest: @escaping (String) -> Void) { self.onRequest = onRequest }

    func searchFlight(iataCode: String, flightDate: String?) async throws -> FlightResponse {
        calls.append((iataCode, flightDate))
        return try await withCheckedThrowingContinuation { continuation in
            pending[iataCode] = continuation
            onRequest(iataCode)
        }
    }
    func succeed(_ code: String, response: FlightResponse) { pending.removeValue(forKey: code)?.resume(returning: response) }
    func fail(_ code: String, error: Error) { pending.removeValue(forKey: code)?.resume(throwing: error) }
}

private actor ControlledRequirements: RequirementsChecking {
    private var pending: [String: CheckedContinuation<VisaCheckResponse, Error>] = [:]
    private let onRequest: (String) -> Void
    init(onRequest: @escaping (String) -> Void) { self.onRequest = onRequest }

    func checkVisaRequirements(passportCode: String, destinationCode: String) async throws -> VisaCheckResponse {
        return try await withCheckedThrowingContinuation { continuation in
            pending[destinationCode] = continuation
            onRequest(destinationCode)
        }
    }
    func succeed(_ destination: String, response: VisaCheckResponse) { pending.removeValue(forKey: destination)?.resume(returning: response) }
}

final class SearchStateTests: XCTestCase {
    private func flight(_ code: String) throws -> FlightResponse {
        try JSONDecoder().decode(FlightResponse.self, from: Data(#"{"data":[{"flight":{"iata":"CODE"}}]}"#.replacingOccurrences(of: "CODE", with: code).utf8))
    }

    private func visa(destination: String) throws -> VisaCheckResponse {
        let json = #"{"data":{"passport":{"code":"DE","name":"Germany"},"destination":{"code":"DESTINATION","name":"Destination"},"visa_rules":{"primary_rule":{"name":"Check official rules"}}},"meta":{}}"#
        return try JSONDecoder().decode(VisaCheckResponse.self, from: Data(json.replacingOccurrences(of: "DESTINATION", with: destination).utf8))
    }

    private func isolatedDefaults() -> UserDefaults { UserDefaults(suiteName: "SearchTests.\(UUID())")! }

    @MainActor func testOlderFlightSearchCannotReplaceNewerResult() async throws {
        let first = expectation(description: "First flight requested")
        let second = expectation(description: "Second flight requested")
        let service = ControlledFlights { code in (code == "LH400" ? first : second).fulfill() }
        let defaults = isolatedDefaults()
        let model = FlightViewModel(service: service, defaults: defaults, airportStatus: { _ in nil })
        model.flightIATA = " lh 400 "
        let older = Task { await model.search() }
        await fulfillment(of: [first], timeout: 2)
        model.flightIATA = "BA123"
        let newer = Task { await model.search() }
        await fulfillment(of: [second], timeout: 2)
        await service.succeed("BA123", response: try flight("BA123"))
        await newer.value
        await service.succeed("LH400", response: try flight("LH400"))
        await older.value
        XCTAssertEqual(model.flights.first?.flight?.iata, "BA123")
        XCTAssertEqual(model.recentSearches, ["BA123"])
        XCTAssertFalse(model.isLoading)
    }

    @MainActor func testCancelledFlightRequestDoesNotRetryOrShowAnError() async {
        let requested = expectation(description: "Flight requested")
        let service = ControlledFlights { _ in requested.fulfill() }
        let model = FlightViewModel(service: service, defaults: isolatedDefaults(), airportStatus: { _ in nil })
        model.flightIATA = "LH400"
        let request = Task { await model.search() }
        await fulfillment(of: [requested], timeout: 2)
        await service.fail("LH400", error: CancellationError())
        await request.value
        let calls = await service.calls
        XCTAssertEqual(calls.count, 1)
        XCTAssertNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
    }

    @MainActor func testCountryChangeDiscardsInFlightRequirements() async throws {
        let requested = expectation(description: "Requirements requested")
        let service = ControlledRequirements { _ in requested.fulfill() }
        let model = RequirementsViewModel(service: service, defaults: isolatedDefaults())
        model.nationality = Country(name: "Germany", code: "DE")
        model.destination = Country(name: "United Kingdom", code: "GB")
        let request = Task { await model.checkRequirements() }
        await fulfillment(of: [requested], timeout: 2)
        model.destination = Country(name: "United States", code: "US")
        await service.succeed("GB", response: try visa(destination: "GB"))
        await request.value
        XCTAssertNil(model.visaResponse)
        XCTAssertTrue(model.recentChecks.isEmpty)
        XCTAssertFalse(model.isLoading)
    }

    @MainActor func testResetInvalidatesInFlightRequirements() async throws {
        let requested = expectation(description: "Requirements requested")
        let service = ControlledRequirements { _ in requested.fulfill() }
        let model = RequirementsViewModel(service: service, defaults: isolatedDefaults())
        model.nationality = Country(name: "Germany", code: "DE")
        model.destination = Country(name: "United Kingdom", code: "GB")
        let request = Task { await model.checkRequirements() }
        await fulfillment(of: [requested], timeout: 2)
        model.clearResults()
        await service.succeed("GB", response: try visa(destination: "GB"))
        await request.value
        XCTAssertNil(model.visaResponse)
        XCTAssertFalse(model.isLoading)
    }

    @MainActor func testWrongProviderRouteIsRejected() async throws {
        let requested = expectation(description: "Requirements requested")
        let service = ControlledRequirements { _ in requested.fulfill() }
        let model = RequirementsViewModel(service: service, defaults: isolatedDefaults())
        model.nationality = Country(name: "Germany", code: "DE")
        model.destination = Country(name: "United Kingdom", code: "GB")
        let request = Task { await model.checkRequirements() }
        await fulfillment(of: [requested], timeout: 2)
        await service.succeed("GB", response: try visa(destination: "US"))
        await request.value
        XCTAssertNil(model.visaResponse)
        XCTAssertNotNil(model.errorMessage)
        XCTAssertTrue(model.recentChecks.isEmpty)
    }

    func testProviderErrorBodyIsNotDisplayed() {
        let responseBody = #"{"debug":"private-provider-diagnostic"}"#
        for code in [401, 403, 429, 500] {
            let message = NetworkServiceError.httpStatus(code, responseBody).localizedDescription
            XCTAssertFalse(message.contains("private-provider-diagnostic"))
        }
    }
}
