# Travel Companion

A native iOS travel-planning app that connects flight lookup, entry-requirement checks, airport information, and locally saved trips.

Swift · SwiftUI · SwiftData · Swift Concurrency · URLSession · MapKit · StoreKit 2

[![Build and tests](https://github.com/fayselomerahmed/travel-companion-ios/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/fayselomerahmed/travel-companion-ios/actions/workflows/build.yml)

## The problem

Preparing a trip means combining information from several providers while keeping essential details easy to find. This project brings those tasks into one interface and treats missing configuration, provider failures, local persistence, and purchase state as explicit application states.

## Implemented

- Flight-code search, result prioritization, and flight-detail screens.
- Visa/entry-requirement lookup by passport country and destination through RapidAPI.
- Saved trips backed by SwiftData, plus recent searches stored locally.
- Airport maps and links to Apple Maps; best-effort Frankfurt departure-board enrichment.
- Interface resources for 22 languages and an in-app language selector.
- StoreKit 2 product loading, verified entitlement handling, and purchase restoration. Premium sales remain disabled while planned features are unfinished.

## Engineering highlights

**Feature state separated from provider requests.** Main-actor [flight](TravelCompanion/Features/Flights/FlightViewModel.swift) and [requirements](TravelCompanion/Features/Requirements/RequirmentsViewModel.swift) view models own loading, results, and errors. Provider-specific services handle requests and decoding through the shared [API client](TravelCompanion/Networking/APIClient.swift).

**Defensive configuration and persistence.** [ConfigurationPolicy](TravelCompanion/Networking/ConfigurationPolicy.swift) rejects placeholders and unresolved build variables. Requests have bounded timeouts and user-facing failures. If the persistent store cannot open, [startup](TravelCompanion/TravelCompanionApp.swift) shows a recovery screen instead of pretending in-memory trips were permanently saved.

**Purchase access follows verified state.** The [purchase manager](TravelCompanion/SharedUI/PurchaseManager.swift) refreshes current entitlements after transaction updates and excludes revoked, expired, or upgraded purchases. Planned premium features are labeled as a preview, and purchases are disabled by default.

The provider fallback is a deliberate trade-off: flight search retries without a date when the provider plan rejects that parameter. Airport-board enrichment is best-effort, not a guaranteed official operational feed.

## Verified build and tests

The [verified CI run](https://github.com/fayselomerahmed/travel-companion-ios/actions/runs/39037288743) passed a complete Release iOS simulator build and **5 core regression tests** on 2026-10-17. Tests cover configuration precedence, missing/placeholder credentials, HTTPS validation, and active versus expired/revoked purchase policy.

```bash
swift test
```

These are focused policy tests, not UI or live-provider integration tests. The [CI configuration](.github/workflows/build.yml) includes the exact Release build command.

## Run locally

Use Xcode 26.4 (the verified CI toolchain); the app's deployment target is iOS 17.

```bash
git clone https://github.com/fayselomerahmed/travel-companion-ios.git
cd travel-companion-ios
cp Secrets.example.xcconfig Secrets.local.xcconfig
open TravelCompanion.xcodeproj
```

Add your RapidAPI visa-service key and Aviationstack key to the ignored `Secrets.local.xcconfig`, then select the `TravelCompanion` scheme and an iPhone simulator. The app builds without keys; API-backed screens report missing configuration until valid credentials are supplied. Physical-device builds require your own signing team.

`Secrets.xcconfig` supplies empty defaults and imports the local file optionally. Never commit local credentials. Reusable paid-provider keys must move behind a controlled backend before public distribution; an app bundle cannot keep them secret.

## Release scope

This portfolio project has a verified simulator build, not a production-service or App Store release claim. Live-provider/device checks, privacy declarations, and distribution requirements are tracked in [release readiness](PRODUCTION_READINESS.md). Live alerts, a document wallet, and premium offline tools remain planned and are not sold as completed features. Entry requirements must be confirmed with official destination authorities.

[Feature screens](TravelCompanion/Features) · [API models](TravelCompanion/Models) · [Networking](TravelCompanion/Networking) · [Shared UI](TravelCompanion/SharedUI) · [Security](SECURITY.md)
