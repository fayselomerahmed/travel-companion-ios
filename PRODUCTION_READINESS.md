# Release readiness

Status: development candidate with a verified Release simulator build. Unfinished upsells are hidden and purchases remain disabled by default.

## Implemented safeguards

- Missing, placeholder, and unresolved build-variable API keys are rejected before requests.
- Configuration accepts HTTPS endpoints without embedded credentials.
- Out-of-order flight results cannot overwrite newer searches; cancellation does not retry or display an error. Country-selection changes and reset invalidate in-flight requirements responses.
- Requirements responses must match the selected passport/destination route; provider diagnostic bodies are not displayed to the user.
- Frankfurt HTML enrichment is disabled unless `ExperimentalFrankfurtHTMLEnrichmentEnabled` is explicitly true. Provider flight data, airport maps, and official-airport links remain available without it.
- Paid-product access refreshes from verified current StoreKit entitlements, excluding revoked, expired, and upgraded transactions.
- Purchases and unfinished upsell sections default to disabled. Do not enable `TravelPlusPurchasesEnabled` until advertised capabilities and payment flows are verified.
- Persistent-storage failure opens an error screen instead of silently saving trips in memory.
- The app target explicitly supports iPhone/iPad rather than unverified Mac/visionOS platforms.

## Validation

On 2026-10-17 the [hosted workflow](https://github.com/fayselomerahmed/travel-companion-ios/actions/runs/39064138104) passed a complete Release simulator build and 12 host-runnable regression tests at `9b6e488`. Run `swift test` to repeat the configuration, entitlement, enrichment opt-in, concurrency/cancellation, request invalidation, route-matching, and error-redaction checks using controlled services.

A separate [screenshot workflow](https://github.com/fayselomerahmed/travel-companion-ios/actions/runs/39063950747) built and launched the app in an iPhone simulator and captured the [home screen](docs/screenshots/home.png). This confirms that the captured interface rendered; it does not establish live-provider behavior or physical-device readiness.

## Release gates

- [x] Green hosted Release simulator build.
- [ ] Physical-device smoke tests for each feature and supported iOS version.
- [x] Deterministic configuration, entitlement, request-ordering, cancellation, invalidation, route-matching, and enrichment opt-in regression tests.
- [ ] End-to-end missing-key, timeout, malformed response, offline, empty-results, rate-limit, and cancellation checks against the intended provider deployment.
- [ ] Move reusable provider credentials behind an authenticated, rate-limited backend. Values embedded in an app bundle cannot be kept secret.
- [ ] Verify trip save/reopen/delete behavior and persistence migrations without data loss.
- [ ] Complete planned live alerts, document wallet, and premium offline tools before exposing their upsells or enabling purchases.
- [ ] Sandbox-test purchase, restore, cancellation, refund, revocation, and subscription expiry. Replace the non-consumable "Trip Pass" model if the product is truly intended to expire per journey.
- [ ] Review visa content with official destination authorities; provider responses are guidance, not a guarantee of admission.
- [ ] Confirm airport-source accuracy and terms before opting into experimental HTML enrichment; scraped matches must not be represented as verified official live operational data.
- [ ] Accessibility, 22-language content review, privacy declarations, app icon/screenshots, support policy, signing, and App Store metadata.
