import XCTest
@testable import TravelCore

final class TravelCoreTests: XCTestCase {
    func testFlightErrorsDecodeCurrentAndLegacyProviderEnvelopes() {
        let current = Data(#"{"error":{"code":"function_access_restricted","message":"Private diagnostic"}}"#.utf8)
        let legacy = Data(#"{"success":false,"error":{"code":104,"type":"usage_limit_reached","info":"Private diagnostic"}}"#.utf8)
        XCTAssertEqual(FlightService.providerError(from: current), .subscriptionRestriction)
        XCTAssertEqual(FlightService.providerError(from: legacy), .requestLimitReached)
        XCTAssertNil(FlightService.providerError(from: Data(#"{"data":[]}"#.utf8)))
    }

    func testFlightProviderDiagnosticsCannotBecomeUserFacingMessages() {
        let payload = Data(#"{"success":false,"error":{"code":"private-provider-type","type":"private-provider-type","info":"private-provider-diagnostic","message":"private-provider-diagnostic"}}"#.utf8)
        let error = FlightService.providerError(from: payload)
        XCTAssertEqual(error, .providerFailure)
        XCTAssertFalse(error?.localizedDescription.contains("private-provider") ?? true)
    }

    func testUnverifiedAirportEnrichmentRequiresExplicitOptIn() {
        XCTAssertFalse(ConfigurationPolicy.allowsExperimentalAirportEnrichment(enabled: nil))
        XCTAssertFalse(ConfigurationPolicy.allowsExperimentalAirportEnrichment(enabled: false))
        XCTAssertTrue(ConfigurationPolicy.allowsExperimentalAirportEnrichment(enabled: true))
    }

    func testRejectsMissingAndUnexpandedSecrets() {
        for value in ["", "  ", "$(RAPID_API_KEY)", "YOUR_API_KEY", "REPLACE_ME", "your-rapidapi-key", "your-aviationstack-key"] {
            XCTAssertNil(ConfigurationPolicy.value(environment: value, bundled: nil))
        }
    }

    func testEnvironmentOverridesBundleAndWhitespaceIsTrimmed() {
        XCTAssertEqual(ConfigurationPolicy.value(environment: " runtime ", bundled: "bundled"), "runtime")
        XCTAssertEqual(ConfigurationPolicy.value(environment: " ", bundled: " bundled "), "bundled")
    }

    func testRequiresHTTPSWithoutEmbeddedCredentials() {
        for value in ["http://example.com", "https:/path", "https://user:secret@example.com"] {
            XCTAssertNil(ConfigurationPolicy.secureURL(value))
        }
        XCTAssertNotNil(ConfigurationPolicy.secureURL("https://example.com/api"))
    }

    func testRevokedExpiredAndUpgradedPurchasesDoNotGrantAccess() {
        let now = Date(timeIntervalSince1970: 100)
        XCTAssertFalse(PurchaseEntitlementPolicy.isActive(revocationDate: now, expirationDate: nil, isUpgraded: false, now: now))
        XCTAssertFalse(PurchaseEntitlementPolicy.isActive(revocationDate: nil, expirationDate: now, isUpgraded: false, now: now))
        XCTAssertFalse(PurchaseEntitlementPolicy.isActive(revocationDate: nil, expirationDate: nil, isUpgraded: true, now: now))
    }

    func testActiveSubscriptionsAndNonConsumablesGrantAccess() {
        let now = Date(timeIntervalSince1970: 100)
        XCTAssertTrue(PurchaseEntitlementPolicy.isActive(revocationDate: nil, expirationDate: now.addingTimeInterval(1), isUpgraded: false, now: now))
        XCTAssertTrue(PurchaseEntitlementPolicy.isActive(revocationDate: nil, expirationDate: nil, isUpgraded: false, now: now))
    }
}
