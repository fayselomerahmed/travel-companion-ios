//
//  SavedTripDetailScreen.swift
//  TravelCompanion
//
//  Created by User on 4/2/26.
//

import SwiftUI
import SwiftData

struct SavedTripDetailScreen: View {
    let trip: SavedTrip

    @SwiftUI.Environment(\.modelContext) private var modelContext
    @SwiftUI.Environment(\.dismiss) private var dismiss

    @State private var appeared = false
    @State private var errorMessage: String?

    private let contentMaxWidth: CGFloat = 440

    var body: some View {
        ZStack(alignment: .top) {
            PremiumBackgroundView()

            TopTravelHeader(title: "Saved Trip", color: .white)
                .padding(.top, -8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroSection
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.05), value: appeared)

                    summaryCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.14), value: appeared)

                    detailCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.22), value: appeared)

                    deleteCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.30), value: appeared)
                }
                .padding(.horizontal, 20)
                .padding(.top, 92)
                .padding(.bottom, 44)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                appeared = true
            }
        }
        .alert("Unable to Save Changes", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: heroGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: heroShadowColor, radius: 26, x: 0, y: 16)
                .shadow(color: Color.white.opacity(0.03), radius: 12, x: 0, y: 2)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.048), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )

            RadialGradient(
                colors: [Color.white.opacity(0.12), .clear],
                center: UnitPoint(x: 0.92, y: 0.08),
                startRadius: 10,
                endRadius: 200
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    typeCapsule
                    Spacer()
                    iconBadge
                }

                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(PremiumPalette.gold.opacity(0.65))
                        .frame(width: 24, height: 1.5)
                        .cornerRadius(1)

                    Text("Saved item")
                        .font(.system(size: 14, weight: .medium))
                        .tracking(0.2)
                        .foregroundStyle(.white.opacity(0.55))

                    Text(trip.title)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .tracking(-0.9)
                        .foregroundStyle(.white)
                        .lineSpacing(2)

                    Text(trip.subtitle)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.84))
                        .fixedSize(horizontal: false, vertical: true)
                }

                PremiumDivider()

                VStack(spacing: 10) {
                    heroInfoLine("Route", trip.route)
                    heroInfoLine("Saved", formattedDate(trip.savedAt))
                }
            }
            .padding(24)
        }
        .frame(minHeight: 260)
    }

    // MARK: - Content

    private var summaryCard: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Saved summary",
                    subtitle: "A quick view of the stored result",
                    symbol: iconName
                )

                Text(trip.summary)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.60))
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var detailCard: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Saved details",
                    subtitle: "What was stored in your Trips tab",
                    symbol: "tray.full.fill"
                )

                VStack(spacing: 10) {
                    detailRow("Type", typeLabel)
                    PremiumDivider()
                    detailRow("Title", trip.title)
                    PremiumDivider()
                    detailRow("Subtitle", trip.subtitle)
                    PremiumDivider()
                    detailRow("Route", trip.route)
                    PremiumDivider()
                    detailRow("Saved", formattedDate(trip.savedAt))
                }
            }
        }
    }

    private var deleteCard: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.14))
                            .frame(width: 34, height: 34)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.red)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remove from Trips")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("Delete this saved item if you no longer need it.")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white.opacity(0.56))
                    }

                    Spacer()
                }

                Button {
                    deleteTrip()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.78, green: 0.18, blue: 0.22),
                                        Color(red: 0.95, green: 0.25, blue: 0.30)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.10), .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )

                        Text("Delete saved trip")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    // MARK: - Shared Bits

    private var typeCapsule: some View {
        Text(typeLabel.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(.white.opacity(0.14))
            .foregroundStyle(.white)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .clipShape(Capsule())
    }

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 34, height: 34)

            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func heroInfoLine(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.82))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.90))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(.white.opacity(0.62))
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Data

    private var typeLabel: String {
        switch trip.type.lowercased() {
        case "flight":
            return "Saved Flight"
        case "requirement":
            return "Saved Requirement Check"
        default:
            return "Saved Item"
        }
    }

    private var iconName: String {
        switch trip.type.lowercased() {
        case "flight":
            return "airplane"
        case "requirement":
            return "doc.text.magnifyingglass"
        default:
            return "bookmark"
        }
    }

    private var heroGradient: [Color] {
        switch trip.type.lowercased() {
        case "flight":
            return [
                PremiumPalette.navy,
                PremiumPalette.royal,
                PremiumPalette.blue
            ]
        case "requirement":
            return [
                Color(red: 0.15, green: 0.14, blue: 0.33),
                Color(red: 0.24, green: 0.23, blue: 0.50),
                Color(red: 0.35, green: 0.39, blue: 0.72)
            ]
        default:
            return [
                Color(red: 0.24, green: 0.26, blue: 0.33),
                Color(red: 0.34, green: 0.37, blue: 0.44)
            ]
        }
    }

    private var heroShadowColor: Color {
        switch trip.type.lowercased() {
        case "flight":
            return PremiumPalette.accentBlueLight.opacity(0.18)
        case "requirement":
            return Color.indigo.opacity(0.18)
        default:
            return Color.black.opacity(0.12)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Actions

    private func deleteTrip() {
        modelContext.delete(trip)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Unable to delete this trip. Please try again."
            return
        }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SavedTripDetailScreen(
            trip: SavedTrip(
                type: "flight",
                title: "LH400",
                subtitle: "Lufthansa",
                route: "FRA → JFK",
                summary: "Status: On time, Reported gate: A23, Terminal: 1"
            )
        )
        .modelContainer(for: SavedTrip.self, inMemory: true)
    }
}
