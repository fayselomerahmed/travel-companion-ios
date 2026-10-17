//
//  TravelCompanionApp.swift
//  TravelCompanion
//
//  Created by User on 3/4/26.
//
import SwiftUI
import SwiftData

@main
struct TravelCompanionApp: App {
    private let modelContainerState = AppModelContainerState.make()

    var body: some Scene {
        WindowGroup {
            switch modelContainerState {
            case .ready(let container):
                RootView()
                    .modelContainer(container)
            case .unavailable(let message):
                StartupUnavailableView(message: message)
            }
        }
    }
}

private enum AppModelContainerState {
    case ready(ModelContainer)
    case unavailable(String)

    static func make() -> AppModelContainerState {
        let schema = Schema([
            SavedTrip.self
        ])

        let persistentConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [persistentConfiguration]
            )
            return .ready(container)
        } catch {
            // Never pretend a trip was saved when persistence is unavailable.
            return .unavailable("Travel Companion could not open saved-trip storage. No existing data has been deleted. Restart the app and contact support if the issue continues; do not reinstall without a backup.")
        }
    }
}

private struct StartupUnavailableView: View {
    let message: String

    var body: some View {
        ZStack {
            PremiumBackgroundView()

            PremiumContentCard {
                VStack(alignment: .leading, spacing: 14) {
                    PremiumIconHeader(
                        title: "Storage unavailable",
                        subtitle: "The app could not start safely",
                        symbol: "externaldrive.badge.exclamationmark"
                    )

                    Text(message)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(PremiumPalette.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
        }
    }
}
