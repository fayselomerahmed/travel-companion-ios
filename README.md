# Travel Companion

My native iPhone travel-planning project. I bring flight lookup, entry-requirement checks, saved trips, and airport guidance into one SwiftUI interface, with a focus on clear loading states, useful error messages, and locally stored trip information.

**SwiftUI · SwiftData · Swift Concurrency · URLSession · MapKit · StoreKit 2**

## What the app does

- Search flights and inspect status details.
- Check visa and entry requirements by nationality and destination.
- Save trips locally with SwiftData.
- Open airport and route guidance with MapKit and Apple Maps.
- StoreKit-based premium UI and purchase restoration.
- Localized interface resources for 22 languages.
- Async networking with user-facing configuration and response errors.

## Engineering decisions

I separate feature views and their state from provider-specific networking. Main-actor view models manage search input, loading, results, and errors; service classes handle API requests and response decoding. Flight search retries without the date parameter when a provider plan does not support it, and can enrich Frankfurt departures with airport status information.

Saved trips use SwiftData, while recent flight searches and requirement checks use lightweight local preferences. Startup presents a recovery screen if persistent storage cannot be opened, instead of silently pretending temporary in-memory trips were saved.

The StoreKit 2 manager observes transaction updates, verifies results, filters revoked/expired/upgraded entitlements, and supports restoration. Premium capabilities are preview plans; purchases remain disabled by default until the advertised features and payment flows are verified.

## Start reading the code

- [App entry point](TravelCompanion/TravelCompanionApp.swift) — startup and SwiftData recovery.
- [Flight view model](TravelCompanion/Features/Flights/FlightViewModel.swift) — search normalization, provider fallback, and result ranking.
- [Requirements view model](TravelCompanion/Features/Requirements/RequirmentsViewModel.swift) — selection, validation, and recent checks.
- [API client](TravelCompanion/Networking/APIClient.swift) — configuration, request timeouts, and response errors.
- [Saved trip model](TravelCompanion/SavedTrip.swift) — local persistence.
- [Purchase manager](TravelCompanion/SharedUI/PurchaseManager.swift) — StoreKit products, transactions, and restoration.

## Requirements

- Xcode 16 or newer with an iOS SDK installed (deployment target: iOS 17)
- A RapidAPI subscription for the visa-requirement service
- An Aviationstack API key for flight data

## Local setup

1. Copy `Secrets.example.xcconfig` to `Secrets.local.xcconfig`.
2. Replace the example values in `Secrets.local.xcconfig` with your own keys.
3. Open `TravelCompanion.xcodeproj` in Xcode.
4. Select the `TravelCompanion` scheme and run on an iPhone simulator or device.

`Secrets.xcconfig` contains safe empty defaults and optionally imports the ignored local file. API-backed screens report missing configuration until local keys are supplied.

Never commit `Secrets.local.xcconfig` or put production credentials directly in Swift source. A production release should proxy paid APIs through a backend so app users cannot extract reusable provider keys.

## Project structure

- [`TravelCompanion/Features/`](TravelCompanion/Features) — home, flights, requirements, saved trips, profile, and premium screens.
- [`TravelCompanion/Models/`](TravelCompanion/Models) — API request and response models.
- [`TravelCompanion/Networking/`](TravelCompanion/Networking) — configuration, clients, and provider integrations.
- [`TravelCompanion/SharedUI/`](TravelCompanion/SharedUI) — navigation, localization, reusable controls, and visual system.

## Validation and current status

Five regression tests cover configuration and purchase-entitlement policy (`swift test`). The [hosted build](https://github.com/fayselomerahmed/travel-companion-ios/actions/runs/39033459044) passed both core tests and a complete Release iOS simulator build on 2026-10-17. Runtime behavior and live provider responses are not yet verified.

See [release readiness](PRODUCTION_READINESS.md) for the explicit backend, premium-feature, device, privacy, and App Store gates. This is a development project, not a claim of completed production deployment.
