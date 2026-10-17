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

Five host-runnable configuration and purchase-entitlement tests pass with `swift test`. On 2026-10-17 the [hosted workflow](https://github.com/fayselomerahmed/travel-companion-ios/actions/runs/39033459044) passed both these tests and a complete Release simulator build at `1960c785`. Local app builds are still blocked by the unavailable iOS runtime; the hosted build provides compilation evidence, not runtime or live-service validation.

## Release gates

- [x] Green hosted Release simulator build.
- [ ] Physical-device smoke tests for each feature and supported iOS version.
- [ ] Missing-key, timeout, malformed response, offline, empty-results, provider-rate-limit, and cancellation checks.
- [ ] Move reusable provider credentials behind an authenticated, rate-limited backend. Values embedded in an app bundle cannot be kept secret.
- [ ] Verify trip save/reopen/delete behavior and persistence migrations without data loss.
- [ ] Reconcile advertised premium features with implemented functionality. Live alerts, document wallet, and premium offline tools remain planned; keep purchases disabled until delivered.
- [ ] Sandbox-test purchase, restore, cancellation, refund, revocation, and subscription expiry. Replace the non-consumable "Trip Pass" model if the product is truly intended to expire per journey.
- [ ] Review visa content with official destination authorities; provider responses are guidance, not a guarantee of admission.
- [ ] Confirm airport-source accuracy and terms. Scraped status enrichment is best-effort and must not be represented as official live operational data.
- [ ] Accessibility, 22-language content review, privacy declarations, app icon/screenshots, support policy, signing, and App Store metadata.
