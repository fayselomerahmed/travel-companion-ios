# Release readiness

Status: development candidate. Premium functionality is a preview, not a ready-to-sell product.

## Implemented safeguards

- Missing, placeholder, and unresolved build-variable API keys are rejected before requests.
- Configuration accepts HTTPS endpoints without embedded credentials.
- Paid-product access refreshes from verified current StoreKit entitlements, excluding revoked, expired, and upgraded transactions.
- Purchases default to disabled. Do not enable `TravelPlusPurchasesEnabled` until advertised capabilities and payment flows are verified.
- Persistent-storage failure opens an error screen instead of silently saving trips in memory.
- The app target explicitly supports iPhone/iPad rather than unverified Mac/visionOS platforms.

## Validation

Run `swift test` for the host-runnable configuration and purchase-entitlement regression suite. The hosted build workflow also performs a Release simulator build. Local full simulator build attempts on 2026-10-17 were blocked by an unavailable iOS platform/runtime; syntax or core tests are not a substitute for an app build.

## Release gates

- [ ] Green hosted Release build, then physical-device smoke tests for each feature and supported iOS version.
- [ ] Missing-key, timeout, malformed response, offline, empty-results, provider-rate-limit, and cancellation checks.
- [ ] Move reusable provider credentials behind an authenticated, rate-limited backend. Values embedded in an app bundle cannot be kept secret.
- [ ] Verify trip save/reopen/delete behavior and persistence migrations without data loss.
- [ ] Reconcile advertised premium features with implemented functionality. Live alerts, document wallet, and premium offline tools remain planned; keep purchases disabled until delivered.
- [ ] Sandbox-test purchase, restore, cancellation, refund, revocation, and subscription expiry. Replace the non-consumable "Trip Pass" model if the product is truly intended to expire per journey.
- [ ] Review visa content with official destination authorities; provider responses are guidance, not a guarantee of admission.
- [ ] Confirm airport-source accuracy and terms. Scraped status enrichment is best-effort and must not be represented as official live operational data.
- [ ] Accessibility, 22-language content review, privacy declarations, app icon/screenshots, support policy, signing, and App Store metadata.
