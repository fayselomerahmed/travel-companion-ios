# Travel Companion

Travel Companion is a native SwiftUI trip-planning app for iPhone. It brings flight lookup, entry-requirement checks, saved trips, airport guidance, and premium feature flows into one interface.

## Highlights

- Search flights and inspect status details.
- Check visa and entry requirements by nationality and destination.
- Save trips locally with SwiftData.
- Open airport and route guidance with MapKit and Apple Maps.
- StoreKit-based premium UI and purchase restoration.
- Localized interface resources for 22 languages.
- Async networking with user-facing configuration and response errors.

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

- `Features/` — home, flights, requirements, saved trips, profile, and premium screens
- `Models/` — API and persistence models
- `Networking/` — configuration, clients, and service integrations
- `SharedUI/` — navigation, localization, reusable controls, and visual system

## Validation

All Swift source files passed syntax parsing with Swift 6.3. A simulator build was attempted with Xcode 26.4 but could not start because the iOS platform is not installed on the preparation machine. A full build, runtime behavior, and live API responses remain unverified.
