import XCTest
@testable import TravelCore

final class TravelCoreTests: XCTestCase {
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
