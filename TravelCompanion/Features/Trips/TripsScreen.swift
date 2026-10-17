//
//  TripsScreen.swift
//  TravelCompanion
//
//  Created by User on 3/16/26.
//

import SwiftUI
import SwiftData
import UIKit

struct TripsScreen: View {
    @SwiftUI.Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \SavedTrip.savedAt, order: .reverse) private var savedTrips: [SavedTrip]

    @State private var appeared = false

    private let contentMaxWidth: CGFloat = 440

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                PremiumBackgroundView()

                TopTravelHeader(title: "Trips", color: .white)
                    .padding(.top, -8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        libraryHero
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.05), value: appeared)

                        if savedTrips.isEmpty {
                            emptyTripsCard
                                .frame(maxWidth: contentMaxWidth)
                                .frame(maxWidth: .infinity)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 16)
                                .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.14), value: appeared)

                            ideasSection
                                .frame(maxWidth: contentMaxWidth)
                                .frame(maxWidth: .infinity)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 16)
                                .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.22), value: appeared)

                            trustSection
                                .frame(maxWidth: contentMaxWidth)
                                .frame(maxWidth: .infinity)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 16)
                                .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.30), value: appeared)
                        } else {
                            savedTripsSection
                                .frame(maxWidth: contentMaxWidth)
                                .frame(maxWidth: .infinity)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 16)
                                .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.14), value: appeared)

                            trustSection
                                .frame(maxWidth: contentMaxWidth)
                                .frame(maxWidth: .infinity)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 16)
                                .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.22), value: appeared)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 92)
                    .padding(.bottom, 44)
                }

                if let message = router.globalBannerMessage {
                    bannerView(message)
                        .padding(.horizontal, 20)
                        .padding(.top, 58)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .animation(.spring(response: 0.35, dampingFraction: 0.80), value: router.globalBannerMessage)
            .onAppear {
                autoDismissBannerIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    appeared = true
                }
            }
            .onChange(of: router.globalBannerMessage) { _, _ in
                autoDismissBannerIfNeeded()
            }
        }
    }

    // MARK: - Hero

    private var libraryHero: some View {
        PremiumHeroCard(
            tags: ["SAVED", "FLIGHTS", "REQUIREMENTS"],
            eyebrow: "Your collection",
            title: "Saved travel\nlibrary",
            description: "Keep important flight checks and requirement results in one calm place.",
            minHeight: 230
        ) {
            HStack(spacing: 16) {
                libraryMetric(title: "Saved", value: "\(savedTrips.count)")
                libraryMetric(title: "Flights", value: "\(savedTrips.filter { $0.type.lowercased() == "flight" }.count)")
                libraryMetric(title: "Checks", value: "\(savedTrips.filter { $0.type.lowercased() == "requirement" }.count)")
            }
        }
    }

    // MARK: - Saved Trips

    private var savedTripsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PremiumSectionHeader(
                title: "Saved items",
                subtitle: "\(savedTrips.count) saved \(savedTrips.count == 1 ? "item" : "items")"
            )

            VStack(spacing: 14) {
                ForEach(savedTrips) { trip in
                    NavigationLink {
                        SavedTripDetailScreen(trip: trip)
                    } label: {
                        savedTripCard(trip)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = shareText(for: trip)
                            router.showBanner("Copied trip summary")
                        } label: {
                            Label { LText("Copy Summary") } icon: { Image(systemName: "doc.on.doc") }
                        }

                        Button(role: .destructive) {
                            deleteTrip(trip)
                        } label: {
                            Label { LText("Delete") } icon: { Image(systemName: "trash") }
                        }
                    }
                }
            }
        }
    }

    private func savedTripCard(_ trip: SavedTrip) -> some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(iconColor(for: trip.type).opacity(0.14))
                            .frame(width: 46, height: 46)

                        Image(systemName: iconName(for: trip.type))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(iconColor(for: trip.type))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        Text(trip.subtitle)
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(.white.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.28))
                        .padding(.top, 4)
                }

                HStack(spacing: 8) {
                    infoPill(label: "Route", value: trip.route)
                    infoPill(label: "Saved", value: formattedDateShort(trip.savedAt))
                }

                PremiumDivider()

                VStack(alignment: .leading, spacing: 8) {
                    LText("SUMMARY")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(0.7)
                        .foregroundStyle(.white.opacity(0.36))

                    Text(trip.summary)
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineSpacing(1.5)
                }

                HStack {
                    LText("Long press to delete")
                        .font(.system(size: 11.5, weight: .light))
                        .foregroundStyle(.white.opacity(0.45))

                    Spacer()

                    Text(trip.type.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.7)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(iconColor(for: trip.type).opacity(0.13))
                        .foregroundStyle(iconColor(for: trip.type))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyTripsCard: some View {
        PremiumEmptyStateCard(
            title: "No saved trips yet",
            message: "Saved flights and requirement checks will appear here for quick access later."
        ) {
            Image(systemName: "bookmark")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(.white.opacity(0.60))
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 10) {
                suggestionPill("Saved flights")
                suggestionPill("Saved checks")
                suggestionPill("Trip history")
            }
            .padding(.bottom, 26)
        }
    }

    // MARK: - Supporting Sections

    private var ideasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PremiumSectionHeader(
                title: "What this becomes",
                subtitle: "A more useful travel memory space"
            )

            VStack(spacing: 14) {
                featureCard(
                    title: "Saved flight checks",
                    subtitle: "Keep important flight lookups and reopen them quickly.",
                    symbol: "airplane"
                )

                featureCard(
                    title: "Saved requirement checks",
                    subtitle: "Store destination rules and document guidance for future reference.",
                    symbol: "doc.text.magnifyingglass"
                )

                featureCard(
                    title: "Trip history",
                    subtitle: "See the routes and checks you looked up most recently.",
                    symbol: "clock.arrow.circlepath"
                )
            }
        }
    }

    private var trustSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Why this matters",
                    subtitle: "A premium travel product should remember what matters",
                    symbol: "sparkles"
                )

                LText("A saved trips area gives the app memory. Instead of repeating searches, travellers can return to useful details instantly.")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Banner

    private func bannerView(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text(LocalizedStringKey(message))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                router.clearBanner()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.60))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 8)
    }

    private func autoDismissBannerIfNeeded() {
        guard router.globalBannerMessage != nil else { return }

        Task {
            try? await Task.sleep(for: .seconds(2.2))
            await MainActor.run {
                router.clearBanner()
            }
        }
    }

    // MARK: - Actions

    private func deleteTrip(_ trip: SavedTrip) {
        modelContext.delete(trip)
        do {
            try modelContext.save()
        } catch {
            router.showBanner("Unable to save changes")
            return
        }
        router.showBanner("Removed from Trips")
    }

    private func shareText(for trip: SavedTrip) -> String {
        """
        \(trip.title)
        \(trip.subtitle)
        Route: \(trip.route)
        \(trip.summary)
        """
    }

    // MARK: - Components

    private func featureCard(title: String, subtitle: String, symbol: String) -> some View {
        PremiumContentCard {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 50, height: 50)

                    Image(systemName: symbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(.white)

                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.58))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1.5)
                }

                Spacer()
            }
        }
    }

    private func libraryMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.52))

            Text(value)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func suggestionPill(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.system(size: 11, weight: .medium))
            .tracking(0.2)
            .foregroundStyle(.white.opacity(0.65))
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.07))
            .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
            .clipShape(Capsule())
    }

    private func infoPill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.36))

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))
                .lineLimit(1)
                .minimumScaleFactor(0.80)
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }

    // MARK: - Data Helpers

    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "flight":
            return "airplane"
        case "requirement":
            return "doc.text.magnifyingglass"
        default:
            return "bookmark"
        }
    }

    private func iconColor(for type: String) -> Color {
        switch type.lowercased() {
        case "flight":
            return PremiumPalette.accentBlueLight
        case "requirement":
            return .indigo
        default:
            return .gray
        }
    }

    private func formattedDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        TripsScreen()
            .modelContainer(for: SavedTrip.self, inMemory: true)
            .environmentObject(AppRouter())
    }
}
