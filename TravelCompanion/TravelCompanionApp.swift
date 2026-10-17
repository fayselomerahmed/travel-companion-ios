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
            assertionFailure("Could not create persistent ModelContainer: \(error)")
        }

        do {
            let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [fallbackConfiguration])
            return .ready(container)
        } catch {
            return .unavailable("Travel Companion could not prepare local trip storage. Restart the app or reinstall if the issue continues.")
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
