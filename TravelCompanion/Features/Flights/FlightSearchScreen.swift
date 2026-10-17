//
//  FlightSearchScreen.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//

import SwiftUI

struct FlightSearchScreen: View {
    @StateObject private var vm = FlightViewModel()
    @EnvironmentObject private var router: AppRouter
    @State private var appeared = false

    private let contentMaxWidth: CGFloat = 440

    private var canSearch: Bool {
        !vm.flightIATA.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !vm.isLoading
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                backgroundView

                TopTravelHeader(title: "Flights", color: .white)
                    .padding(.top, -8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        searchHeroSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.05), value: appeared)

                        recentSearchesSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.14), value: appeared)

                        messageSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)

                        contentSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.22), value: appeared)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 92)
                    .padding(.bottom, 44)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { router.openTrips() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 38, height: 38)
                                .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.90))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.80), value: vm.isLoading)
            .animation(.spring(response: 0.35, dampingFraction: 0.80), value: vm.flights.count)
            .animation(.spring(response: 0.35, dampingFraction: 0.80), value: vm.errorMessage != nil)
            .onAppear {
                applyPendingFlightCodeIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { appeared = true }
            }
        }
    }

    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            Color(red: 0.03, green: 0.04, blue: 0.07).ignoresSafeArea()

            RadialGradient(
                colors: [Color(red: 0.16, green: 0.32, blue: 0.72).opacity(0.28), .clear],
                center: .topTrailing, startRadius: 20, endRadius: 400
            ).ignoresSafeArea()

            RadialGradient(
                colors: [Color(red: 0.52, green: 0.38, blue: 0.14).opacity(0.16), .clear],
                center: .bottomLeading, startRadius: 20, endRadius: 320
            ).ignoresSafeArea()
        }
    }

    // MARK: - Search Hero
    private var searchHeroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            searchHeroCard
            searchButton
        }
    }

    private var searchHeroCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Base gradient
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.15, blue: 0.28),
                        Color(red: 0.15, green: 0.25, blue: 0.46),
                        Color(red: 0.22, green: 0.36, blue: 0.62)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .black.opacity(0.38), radius: 26, x: 0, y: 16)
                .shadow(color: Color(red: 0.20, green: 0.50, blue: 1.0).opacity(0.08), radius: 12, x: 0, y: 2)

            // Inner shimmer
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.048), .clear],
                    startPoint: .topLeading, endPoint: .center
                ))

            // Top-right glow
            RadialGradient(
                colors: [Color(red: 0.42, green: 0.72, blue: 1.0).opacity(0.18), .clear],
                center: UnitPoint(x: 0.92, y: 0.08), startRadius: 10, endRadius: 200
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

            // Gold bottom-left glow
            RadialGradient(
                colors: [Color(red: 0.83, green: 0.72, blue: 0.49).opacity(0.10), .clear],
                center: UnitPoint(x: 0.08, y: 0.92), startRadius: 10, endRadius: 180
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

            // Border
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)

            VStack(alignment: .leading, spacing: 20) {
                // Tags
                HStack(spacing: 7) {
                    premiumTag("LIVE")
                    premiumTag("STATUS")
                    premiumTag("GATE")
                }

                // Headline
                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(Color(red: 0.83, green: 0.72, blue: 0.49).opacity(0.65))
                        .frame(width: 24, height: 1.5)
                        .cornerRadius(1)

                    LText("Find any flight")
                        .font(.system(size: 14, weight: .medium))
                        .tracking(0.2)
                        .foregroundStyle(.white.opacity(0.55))

                    LText("Track in\nreal time")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .tracking(-1.0)
                        .foregroundStyle(.white)
                        .lineSpacing(2)

                    LText("Search by flight code to review timing, terminal, gate, and live status in one place.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.64))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }

                // Input
                VStack(alignment: .leading, spacing: 8) {
                    LText("Flight code")
                        .font(.system(size: 13, weight: .medium))
                        .tracking(0.2)
                        .foregroundStyle(.white.opacity(0.75))

                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))

                        TextField("e.g. LH400, BA007…", text: $vm.flightIATA)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .tint(.white)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                            .onSubmit {
                                if canSearch { Task { await vm.search() } }
                            }

                        if !vm.flightIATA.isEmpty {
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    vm.flightIATA = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.45))
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.07))
                            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1))
                    )
                }

                // Info chips
                HStack(spacing: 8) {
                    infoChip("IATA code")
                    infoChip("Live status")
                    infoChip("Gate may change")
                }
            }
            .padding(24)
        }
        .frame(minHeight: 310)
    }

    private var searchButton: some View {
        Button {
            Task { await vm.search() }
        } label: {
            ZStack {
                // Active gradient
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(
                        colors: canSearch
                        ? [Color(red: 0.22, green: 0.46, blue: 0.90), Color(red: 0.40, green: 0.68, blue: 1.0)]
                        : [Color.white.opacity(0.10), Color.white.opacity(0.07)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))

                // Top shine
                if canSearch {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color.white.opacity(0.10), .clear],
                            startPoint: .top, endPoint: .center
                        ))
                }

                HStack(spacing: 10) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    }
                    LText(vm.isLoading ? "Searching…" : "Search flight")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canSearch ? .white : .white.opacity(0.35))

                    if !vm.isLoading {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(canSearch ? .white.opacity(0.85) : .white.opacity(0.30))
                    }
                }
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .shadow(
                color: canSearch ? Color(red: 0.22, green: 0.46, blue: 0.90).opacity(0.30) : .clear,
                radius: 16, x: 0, y: 8
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!canSearch)
    }

    // MARK: - Recent Searches
    @ViewBuilder
    private var recentSearchesSection: some View {
        if !vm.recentSearches.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(title: "Recent searches", subtitle: "Quick access to your latest lookups")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(vm.recentSearches, id: \.self) { code in
                            recentChip(code)
                        }
                    }
                    .padding(.vertical, 2)
                }

                HStack {
                    Spacer()
                    Button("Clear all") { vm.clearRecentSearches() }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
        }
    }

    private func recentChip(_ code: String) -> some View {
        HStack(spacing: 8) {
            Button {
                vm.applyRecentSearch(code)
                Task { await vm.search() }
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                    Text(code)
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.3)
                        .foregroundStyle(.white.opacity(0.90))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    Capsule().fill(Color.white.opacity(0.06))
                        .overlay(Capsule().stroke(Color.white.opacity(0.09), lineWidth: 1))
                )
            }
            .buttonStyle(ScaleButtonStyle())

            Button { vm.removeRecentSearch(code) } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.32))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Messages
    @ViewBuilder
    private var messageSection: some View {
        if let error = vm.errorMessage {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle().fill(Color.red.opacity(0.14)).frame(width: 38, height: 38)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.red.opacity(0.90))
                }
                VStack(alignment: .leading, spacing: 3) {
                    LText("Something needs attention")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red.opacity(0.90))
                    Text(error)
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.red.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.red.opacity(0.16), lineWidth: 1))
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Content
    @ViewBuilder
    private var contentSection: some View {
        if vm.flights.isEmpty && !vm.isLoading && vm.errorMessage == nil {
            emptyStateCard
        } else if !vm.flights.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(
                    title: "Results",
                    subtitle: "\(vm.flights.count) flight\(vm.flights.count == 1 ? "" : "s") found"
                )
                ForEach(vm.flights) { flight in
                    NavigationLink {
                        FlightDetailScreen(flight: flight)
                    } label: {
                        FlightCard(flight: flight)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
                Image(systemName: "airplane")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(.white.opacity(0.60))
            }

            VStack(spacing: 6) {
                LText("Ready to search?")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .tracking(-0.4)
                    .foregroundStyle(.white)

                LText("Enter a flight code above to see live timing,\nterminal, gate and status.")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(.white.opacity(0.52))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .padding(.vertical, 36)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }

    // MARK: - Subviews Helpers

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Rectangle()
                .fill(Color(red: 0.83, green: 0.72, blue: 0.49).opacity(0.55))
                .frame(width: 24, height: 1.5)
                .cornerRadius(1)
            LText(title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .tracking(-0.4)
                .foregroundStyle(.white)
            LText(subtitle)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(.white.opacity(0.40))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func premiumTag(_ text: String) -> some View {
        LText(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.2)
            .foregroundStyle(.white.opacity(0.75))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.07))
            .overlay(Capsule().stroke(Color.white.opacity(0.09), lineWidth: 1))
            .clipShape(Capsule())
    }

    private func infoChip(_ text: String) -> some View {
        LText(text)
            .font(.system(size: 11, weight: .medium))
            .tracking(0.2)
            .foregroundStyle(.white.opacity(0.65))
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.07))
            .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
            .clipShape(Capsule())
    }

    private func applyPendingFlightCodeIfNeeded() {
        let code = router.consumePendingFlightCode()
        let shouldAutoRun = router.consumeShouldAutoRunFlightSearch()
        guard let code, !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        vm.applyRecentSearch(code)
        if shouldAutoRun { Task { await vm.search() } }
    }
}

// MARK: - Flight Card (standalone for reuse)
struct FlightCard: View {
    let flight: FlightItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.airline?.name ?? "Unknown Airline")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.50))

                    Text(flight.flight?.iata ?? flight.flight?.number ?? "Flight")
                        .font(.system(size: 22, weight: .bold))
                        .tracking(0.3)
                        .foregroundStyle(.white)

                    Text("\(flight.departure?.iata ?? "–") → \(flight.arrival?.iata ?? "–")")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.62))
                }
                Spacer()
                FlightStatusBadge(status: flight.flightStatus)
            }

            // Info pills grid
            HStack(spacing: 8) {
                infoPill(label: "Gate",     value: reportedGateText(for: flight))
                infoPill(label: "Terminal", value: displayValue(flight.departure?.terminal, fallback: "Check"))
                infoPill(label: "Delay",    value: readableDelay(flight.departure?.delay))
            }

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 1)

            // Route times
            HStack(spacing: 16) {
                timeBlock(label: "Departure",
                          time: readableDateTime(flight.departure?.scheduled),
                          airport: flight.departure?.airport)
                Spacer()
                timeBlock(label: "Arrival",
                          time: readableDateTime(flight.arrival?.scheduled),
                          airport: flight.arrival?.airport,
                          trailing: true)
            }

            // Gate trust note + arrow
            HStack(alignment: .top) {
                gateNoteText(for: flight)
                    .font(.system(size: 11.5, weight: .light))
                    .foregroundStyle(.white.opacity(0.45))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(1.5)
                Spacer(minLength: 12)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.28))
                    .padding(.top, 1)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
        .shadow(color: .black.opacity(0.22), radius: 14, x: 0, y: 8)
    }

    private func infoPill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            LText(label).textCase(.uppercase)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.36))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
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
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }

    private func timeBlock(label: String, time: String, airport: String?, trailing: Bool = false) -> some View {
        VStack(alignment: trailing ? .trailing : .leading, spacing: 4) {
            LText(label).textCase(.uppercase)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.36))
            Text(time)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))
            if let airport {
                Text(airport)
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(2)
                    .multilineTextAlignment(trailing ? .trailing : .leading)
            }
        }
    }

    // MARK: - Display Helpers
    private func displayValue(_ value: String?, fallback: String = "–") -> String {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return fallback }
        return value
    }

    private func reportedGateText(for flight: FlightItem) -> String {
        flight.reportedDepartureGate ?? flight.passengerGateAreaHint ?? "Check"
    }

    @ViewBuilder
    private func gateNoteText(for flight: FlightItem) -> some View {
        if let gate = flight.reportedDepartureGate {
            if flight.officialDataSourceName != nil {
                LTemplateText("Frankfurt source gate {gate}. Verify on airport screens before boarding.", replacements: ["{gate}": gate])
            } else {
                LTemplateText(gateNoteTemplate(for: flight), replacements: ["{gate}": gate])
            }
        } else if let area = flight.passengerGateAreaHint {
            LTemplateText("Likely gate area {area}. Confirm the exact gate on airport screens.", replacements: ["{area}": area])
        } else if flight.hasRawDepartureGateRejectedForPassenger {
            LText("Provider returned a stand number, not a passenger gate. Check airport screens.")
        } else {
            LText("No gate reported yet. Check airport screens closer to boarding.")
        }
    }

    private func gateNoteTemplate(for flight: FlightItem) -> String {
        switch flight.flightStatus?.lowercased() {
        case "delayed": return "Reported gate {gate}. Flight is delayed — gate may still change."
        case "active":  return "Reported gate {gate}. Verify on airport screens before boarding."
        default:        return "Reported gate {gate}. Always confirm with airport screens."
        }
    }

    private func readableDelay(_ delay: Int?) -> String {
        guard let delay else { return "No data" }
        if delay == 0 { return "On time" }
        return "\(delay) min\(delay == 1 ? "" : "s")"
    }

    private func readableDateTime(_ value: String?) -> String {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Not available"
        }
        let isoFull = ISO8601DateFormatter()
        isoFull.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoBasic = ISO8601DateFormatter()
        isoBasic.formatOptions = [.withInternetDateTime]

        guard let date = isoFull.date(from: value) ?? isoBasic.date(from: value) else { return value }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }
}

// MARK: - Flight Status Badge
struct FlightStatusBadge: View {
    let status: String?

    var label: String {
        switch status?.lowercased() {
        case "active":    return "In the air"
        case "scheduled": return "On time"
        case "delayed":   return "Running late"
        case "cancelled": return "Cancelled"
        default:          return status?.capitalized ?? "Unknown"
        }
    }

    var tint: Color {
        switch status?.lowercased() {
        case "active":    return Color(red: 0.20, green: 0.78, blue: 0.35)
        case "scheduled": return Color(red: 0.35, green: 0.63, blue: 1.0)
        case "delayed":   return Color(red: 1.0, green: 0.62, blue: 0.04)
        case "cancelled": return Color(red: 1.0, green: 0.27, blue: 0.23)
        default:          return .white.opacity(0.50)
        }
    }

    var body: some View {
        LText(label).textCase(.uppercase)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(tint)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(tint.opacity(0.13))
            .overlay(Capsule().stroke(tint.opacity(0.25), lineWidth: 1))
            .clipShape(Capsule())
    }
}
